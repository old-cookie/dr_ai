import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// OCR服務類，用於處理醫療證明文件的文字識別與解析
/// 
/// 該類提供兩個主要功能：
/// 1. 使用Tesseract OCR引擎進行文字識別 [recognizeText]
/// 2. 解析醫療證明中的關鍵信息 [parseMedicalCertificate]
class OcrService {
  static bool isDemoMode = false;
  /// 將圖像字節數組保存為臨時文件，以便Tesseract OCR處理
  /// 
  /// [imageBytes] 圖像的二進制數據
  /// 返回臨時文件的路徑
  static Future<String> _saveImageToTempFile(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/temp_certificate.jpg';
    await File(tempFilePath).writeAsBytes(imageBytes);
    return tempFilePath;
  }

  

  /// 對醫療證明圖像進行OCR識別，提取文字內容
  /// 
  /// [imageBytes] 醫療證明圖像的二進制數據
  /// 返回識別出的文字內容
  /// 
  /// 優先嘗試使用英文+繁體中文識別，如果失敗則退回到僅使用英文
  static Future<String> recognizeText(Uint8List imageBytes) async {

    // 如果處於演示模式，則返回演示文本
    if ( isDemoMode ) {
      log('Demo mode actvie');
      return _getDemoOcrText();
    }

    final tempFilePath = await _saveImageToTempFile(imageBytes);
    
    try {
      // 嘗試使用英文+繁體中文來避免空指針錯誤
      // 崩潰日誌顯示僅使用英文時出現空指針錯誤
      final recognizedText = await FlutterTesseractOcr.extractText(
        tempFilePath,
        language: 'eng+chi_tra',
        args: {
          "preserve_interword_spaces": "1",
          "debug_file": "/dev/null",
          "load_system_dawg": "0",
        },
      );

      // 添加日誌以輸出原始 OCR 文本
      log('原始 OCR 文本:');
      log('==========');
      log(recognizedText);
      log('==========');

      return recognizedText;
    } catch (e) {
      log('OCR錯誤: $e');
      
      // 如果發生錯誤，嘗試使用基本設置
      try {
        log('嘗試使用基本設置進行OCR...');
        final simpleRecognizedText = await FlutterTesseractOcr.extractText(
          tempFilePath,
          language: 'eng',
          args: {
            "preserve_interword_spaces": "1",
          },
        );
        return simpleRecognizedText;
      } catch (fallbackError) {
        log('OCR後備方案錯誤: $fallbackError');
        return '';
      }
    }
  }

  /// 從OCR識別的文本中提取醫療證明書的關鍵信息
  /// 
  /// [text] 待解析的OCR文本
  /// 返回包含解析結果的Map，鍵為字段名，值為相應的信息
  /// 
  /// 該方法嘗試提取以下信息：
  /// - 證明編號 (certificateNumber)
  /// - 醫院名稱 (hospital)
  /// - 就診日期 (treatmentDate)
  /// - 住院開始日期 (hospitalizationStartDate)
  /// - 住院結束日期 (hospitalizationEndDate)
  /// - 疾病診斷 (diagnosis)
  /// - 病假開始日期 (sickLeaveStartDate)
  /// - 病假結束日期 (sickLeaveEndDate)
  /// - 複診日期 (followUpDate)
  /// - 備註 (remarks)
  /// - 原始文本 (rawText)
  static Map<String, dynamic> parseMedicalCertificate(String text) {

    if ( isDemoMode && text.isEmpty) {
      return _getDemoCertificateDate();
    }

    final result = <String, dynamic>{};
    
    // 處理OCR文本，移除常見的錯誤字符
    text = _cleanOcrText(text);
    
    // 保存原始清理後的文本供參考
    result['rawText'] = text;
    
    // 記錄預處理後的原始文本
    log('預處理後的原始文本:');
    log('==========');
    log(text);
    log('==========');

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
    log('解析後的結構化數據:');
    log('==========');
    if (result.isEmpty) {
      log('警告: 未能從文本中提取任何有效數據');
    } else {
      result.forEach((key, value) {
        log('$key: $value');
      });
    }
    log('==========');
    
    // 添加分析結果摘要
    log('分析結果摘要:');
    log('==========');
    log('成功提取的欄位: ${result.keys.length - 1}');
    log('提取率: ${((result.keys.length - 1) / 9 * 100).toStringAsFixed(1)}%');
    if (result.containsKey('certificateNumber')) {
      log('證明編號: ${result['certificateNumber']}');
    }
    if (result.containsKey('treatmentDate')) {
      log('就診日期: ${result['treatmentDate']}');
    }
    log('==========');

    return result;
  }

   // 新添加方法開始
  static Future<Map<String, dynamic>> processImage(Uint8List imageBytes) async {
    if (isDemoMode) {
      log('Demo mode active');
      return _getDemoCertificateDate();
    }

    final recognizedText = await recognizeText(imageBytes);
    return parseMedicalCertificate(recognizedText);
  }

  // Demo data
  static String _getDemoOcrText() {
    return '''
    HOSPITAL AUTHORITY
    HONG KONG WEST CLUSTER
    Tuen Mun Hospital
    MEDICAL CERTIFICATE

    Name: CHAN TAI MAN
    Case No.: MED-21-10101(1)

    This is to certify that the above-named patient:
    - attended here on 07-Mar-2023
    - has beem an in-patient from 07-Mar-2023 to 14-Mar-2023
    - is suffering from Fever
    - is recommended for sick leave from 07-Mar-2023 to 14-Mar-2023
    - is required to follow up on 21-Mar-2023
    - is advised to avoid heavy physical duty for N/A

    Remarks: N/A

    Dr. CHAN Siu Ming
    Medical Officer
    Department of Medicine
    ''';
  }

  static Map<String, dynamic> _getDemoCertificateDate() {
    return {
      'certificateNumber': 'MED-21-10101(1)',
      'hospital': 'Tuen Mun Hospital',
      'treatmentDate': '2023-03-07',
      'hospitalizationStartDate': '2023-03-07',
      'hospitalizationEndDate': '2023-03-14',
      'diagnosis': 'Fever',
      'sickLeaveStartDate': '2023-03-07',
      'sickLeaveEndDate': '2023-03-14',
      'followUpDate': '2023-03-21',
      'remarks': 'N/A',
      'rawText': _getDemoOcrText(),
      'isDemoData': true,
    };
  }

  static void toggleDemoMode({bool? enable}) {
    if (enable != null) {
      isDemoMode = enable;
    } else {
      isDemoMode = !isDemoMode;
    }
    log('Demo mode is now ${isDemoMode ? 'enabled' : 'disabled'}');
  }
   // 新添加方法結束


  /// 清理OCR識別中的常見錯誤字符
  /// 
  /// [text] 原始OCR文本
  /// 返回清理後的文本
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

  /// 清理OCR識別的日期字符串中的常見錯誤
  /// 
  /// [dateStr] 原始日期字符串
  /// 返回清理後的日期字符串
  static String _cleanDateString(String dateStr) {
    // 修復月份錯誤識別
    return dateStr
        .replaceAll('Mz', 'Mar')
        .replaceAll('Vzz', 'Mar')
        .replaceAll('0元M3p', '03-Mar')
        .replaceAll(RegExp(r'[﹣﹒]'), '-');
  }

  /// 檢查文本是否表示"不適用"(N/A)
  /// 
  /// [text] 待檢查的文本
  /// 如果文本表示"不適用"則返回true，否則返回false
  static bool _isNotApplicable(String text) {
    final naPattern = RegExp(r'[Nn]\/[Aa]|尸\/[Aa]|無|没有|不適用');
    return naPattern.hasMatch(text) || text.trim().isEmpty;
  }

  /// 嘗試使用多種格式解析日期字符串
  /// 
  /// [dateStr] 待解析的日期字符串
  /// 返回標準格式(yyyy-MM-dd)的日期字符串，如果解析失敗則返回原始字符串
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
      log('日期解析錯誤: $e');
      return dateStr;
    }
  }
}


