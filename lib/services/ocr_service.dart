import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class OcrService {
  // 將Uint8List轉換為臨時文件
  static Future<String> _saveImageToTempFile(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/temp_certificate.jpg';
    await File(tempFilePath).writeAsBytes(imageBytes);
    return tempFilePath;
  }

  // 執行OCR文本識別
  static Future<String> recognizeText(Uint8List imageBytes) async {
    final tempFilePath = await _saveImageToTempFile(imageBytes);
    
    try {
      // 嘗試使用英文+繁體中文來避免空指針錯誤
      // 崩潰日誌顯示僅使用英文時出現空指針錯誤
      final recognizedText = await FlutterTesseractOcr.extractText(
        tempFilePath,
        language: 'eng+chi_tra',  // 回退到使用英文+繁體中文，避免崩潰
        args: {
          "preserve_interword_spaces": "1",
          "debug_file": "/dev/null",  // 禁用調試文件寫入
          "load_system_dawg": "0",    // 關閉某些導致崩潰的功能
        },
      );

      // 添加日誌以輸出原始 OCR 文本
      print('原始 OCR 文本:');
      print('==========');
      print(recognizedText);
      print('==========');

      return recognizedText;
    } catch (e) {
      print('OCR錯誤: $e');
      
      // 如果發生錯誤，嘗試使用基本設置
      try {
        print('嘗試使用基本設置進行OCR...');
        final simpleRecognizedText = await FlutterTesseractOcr.extractText(
          tempFilePath,
          language: 'eng',
          args: {
            "preserve_interword_spaces": "1",
          },
        );
        return simpleRecognizedText;
      } catch (fallbackError) {
        print('OCR後備方案錯誤: $fallbackError');
        return '';
      }
    }
  }

  // 解析醫療證明書文本
  static Map<String, dynamic> parseMedicalCertificate(String text) {
    final result = <String, dynamic>{};
    
    // 處理OCR文本，移除常見的錯誤字符
    text = _cleanOcrText(text);
    
    // 保存原始清理後的文本供參考
    result['rawText'] = text;
    
    // 記錄預處理後的原始文本
    print('預處理後的原始文本:');
    print('==========');
    print(text);
    print('==========');

    // 尋找證明編號 - 更寬鬆的正則表達式
    final certificateNumberRegex = RegExp(r'[Cc]ase\s*[Nn]o[.:]?\s*([A-Za-z0-9\-\(\)\/]+)');
    final certificateMatch = certificateNumberRegex.firstMatch(text);
    if (certificateMatch != null && certificateMatch.group(1) != null) {
      result['certificateNumber'] = certificateMatch.group(1)!.trim();
    }

    // 尋找醫院名稱 - 更寬鬆的匹配
    final hospitalRegex = RegExp(r"([A-Za-z\'\s]+[Hh]ospital[\s\w\(\)]*)", caseSensitive: false);
    final hospitalMatch = hospitalRegex.firstMatch(text);
    if (hospitalMatch != null && hospitalMatch.group(1) != null) {
      result['hospital'] = hospitalMatch.group(1)!.trim();
    }

    // 尋找就診日期 - 適應更多錯誤格式
    final attendedRegex = RegExp(r'attended\s+(?:here\s+)?on\s+([0-9]{1,2}[-\/\.﹒﹣][A-Za-z0-9]{1,9}[-\/\.﹒﹣][0-9]{2,4})');
    final attendedMatch = attendedRegex.firstMatch(text);
    if (attendedMatch != null && attendedMatch.group(1) != null) {
      final dateStr = attendedMatch.group(1)!;
      final cleanDate = _cleanDateString(dateStr);
      result['treatmentDate'] = _parseDate(cleanDate);
    }

    // 尋找住院期間 - 適應N/A和錯誤格式
    final inpatientRegex = RegExp(
        r'in-?patient\s+from\s+([0-9]{1,2}[-\/\.﹒﹣][A-Za-z0-9]{1,9}[-\/\.﹒﹣][0-9]{2,4}|[Nn]\/[Aa])\s+to\s+([0-9]{1,2}[-\/\.﹒﹣][A-Za-z0-9]{1,9}[-\/\.﹒﹣][0-9]{2,4}|[Nn]\/[Aa])');
    final inpatientMatch = inpatientRegex.firstMatch(text);
    if (inpatientMatch != null) {
      final startDateStr = inpatientMatch.group(1)!;
      final endDateStr = inpatientMatch.group(2)!;

      if (!_isNotApplicable(startDateStr)) {
        result['hospitalizationStartDate'] = _parseDate(_cleanDateString(startDateStr));
      }

      if (!_isNotApplicable(endDateStr)) {
        result['hospitalizationEndDate'] = _parseDate(_cleanDateString(endDateStr));
      }
    }

    // 尋找疾病 - 更寬鬆的匹配
    final illnessRegex = RegExp(r'suffering\s+from\s+([^\n\r\.]{1,50})');
    final illnessMatch = illnessRegex.firstMatch(text);
    if (illnessMatch != null && illnessMatch.group(1) != null) {
      result['diagnosis'] = illnessMatch.group(1)!.trim().replaceAll(RegExp(r'[\﹣﹏﹒`﹍ˍ]+'), '');
    }

    // 尋找病假期間 - 更寬鬆的匹配
    final sickLeaveRegex = RegExp(
        r'sick\s+leave\s+from\s+([0-9]{1,2}[-\/\.﹒﹣][A-Za-z0-9]{1,9}[-\/\.﹒﹣][0-9]{2,4}|[Nn]\/[Aa])\s+to\s+([0-9]{1,2}[-\/\.﹒﹣][A-Za-z0-9]{1,9}[-\/\.﹒﹣][0-9]{2,4}|[Nn]\/[Aa])');
    final sickLeaveMatch = sickLeaveRegex.firstMatch(text);
    if (sickLeaveMatch != null) {
      final startDateStr = sickLeaveMatch.group(1)!;
      final endDateStr = sickLeaveMatch.group(2)!;

      if (!_isNotApplicable(startDateStr)) {
        result['sickLeaveStartDate'] = _parseDate(_cleanDateString(startDateStr));
      }

      if (!_isNotApplicable(endDateStr)) {
        result['sickLeaveEndDate'] = _parseDate(_cleanDateString(endDateStr));
      }
    }

    // 尋找複診日期 - 處理更多錯誤格式
    final followUpRegex = RegExp(
        r'follow\s+up\s+on\s+([0-9]{1,2}[-\/\.﹒﹣][A-Za-z0-9]{1,9}[-\/\.﹒﹣][0-9]{2,4}|[Nn]\/[Aa]|尸\/[Aa])', 
        caseSensitive: false);
    final followUpMatch = followUpRegex.firstMatch(text);
    if (followUpMatch != null && followUpMatch.group(1) != null) {
      final dateStr = followUpMatch.group(1)!;
      if (!_isNotApplicable(dateStr) && !dateStr.contains('尸')) {
        result['followUpDate'] = _parseDate(_cleanDateString(dateStr));
      }
    }

    // 尋找備註
    final remarksRegex = RegExp(r'Remarks[^:]*:([^\n\r]+)');
    final remarksMatch = remarksRegex.firstMatch(text);
    if (remarksMatch != null && remarksMatch.group(1) != null) {
      final remarks = remarksMatch.group(1)!.trim();
      if (!_isNotApplicable(remarks)) {
        result['remarks'] = remarks;
      }
    }

    // 添加詳細日誌以輸出解析後的結果
    print('解析後的結構化數據:');
    print('==========');
    if (result.isEmpty) {
      print('警告: 未能從文本中提取任何有效數據');
    } else {
      result.forEach((key, value) {
        print('$key: $value');
      });
    }
    print('==========');
    
    // 添加分析結果摘要
    print('分析結果摘要:');
    print('==========');
    print('成功提取的欄位: ${result.keys.length - 1}'); // -1 是因為rawText欄位
    print('提取率: ${((result.keys.length - 1) / 9 * 100).toStringAsFixed(1)}%'); // 假設共有9個可能欄位
    if (result.containsKey('certificateNumber')) {
      print('證明編號: ${result['certificateNumber']}');
    }
    if (result.containsKey('treatmentDate')) {
      print('就診日期: ${result['treatmentDate']}');
    }
    print('==========');

    return result;
  }

  // 清理OCR文本
  static String _cleanOcrText(String text) {
    // 替換常見的錯誤字符
    return text
        .replaceAll('﹣', '-')
        .replaceAll('﹒', '.')
        .replaceAll('﹍', '')
        .replaceAll('ˍ', '')
        .replaceAll('﹏', '')
        .replaceAll('`', '')
        .replaceAll('‵', '')
        .replaceAll('﹚', ')')
        .replaceAll('﹙', '(');
  }

  // 清理日期字符串
  static String _cleanDateString(String dateStr) {
    // 修復月份錯誤識別
    return dateStr
        .replaceAll('Mz', 'Mar')
        .replaceAll('Vzz', 'Mar')
        .replaceAll('0元M3p', '03-Mar')
        .replaceAll(RegExp(r'[﹣﹒]'), '-');
  }

  // 檢查是否為N/A
  static bool _isNotApplicable(String text) {
    final naPattern = RegExp(r'[Nn]\/[Aa]|尸\/[Aa]|無|没有|不適用');
    return naPattern.hasMatch(text) || text.trim().isEmpty;
  }

  // 嘗試解析各種日期格式
  static String _parseDate(String dateStr) {
    if (dateStr == 'N/A') return '';

    try {
      // 嘗試格式 dd-MMM-yyyy (07-Mar-2023)
      final dateFormats = [
        DateFormat('dd-MMM-yyyy'),
        DateFormat('dd/MM/yyyy'),
        DateFormat('dd-MM-yyyy'),
        DateFormat('d-MMM-yyyy'),
        DateFormat('d/M/yyyy'),
      ];

      for (final format in dateFormats) {
        try {
          final date = format.parse(dateStr);
          return DateFormat('yyyy-MM-dd').format(date);
        } catch (_) {
          // 繼續嘗試下一個格式
        }
      }

      // 如果所有格式都失敗，返回原始字符串
      return dateStr;
    } catch (e) {
      print('日期解析錯誤: $e');
      return dateStr;
    }
  }
}
