import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

void main() {
  // 測試固定的主機和備用主機
  const String fixedHost = "http://oldcookie276.asuscomm.com:11434";
  const String backupHost = "http://100.64.50.3:11434";
  
  group('Ollama 服務器連接測試', () {
    test('主要伺服器和備用伺服器連接狀態', () async {
      // 檢查主要伺服器連接
      bool mainServerConnected = false;
      String mainServerMessage = "無法連接";
      
      try {
        final mainResponse = await http.get(Uri.parse(fixedHost));
        if (mainResponse.statusCode == 200) {
          mainServerConnected = true;
          mainServerMessage = mainResponse.body.trim();
        }
      } catch (e) {
        mainServerMessage = "錯誤: $e";
      }
      
      // 檢查備用伺服器連接(need VPN)
      bool backupServerConnected = false;
      String backupServerMessage = "無法連接";
      
      try {
        final backupResponse = await http.get(Uri.parse(backupHost));
        if (backupResponse.statusCode == 200) {
          backupServerConnected = true;
          backupServerMessage = backupResponse.body.trim();
        }
      } catch (e) {
        backupServerMessage = "錯誤: $e";
      }
      
      // 輸出連接狀態
      debugPrint('\n連接狀態測試結果:');
      debugPrint('主要伺服器: ${mainServerConnected ? "已連接" : "未連接"} - $mainServerMessage');
      debugPrint('備用伺服器: ${backupServerConnected ? "已連接" : "未連接"} - $backupServerMessage');
      
      // 確認至少一個伺服器能夠連接
      expect(mainServerConnected || backupServerConnected, true, reason: '主要伺服器和備用伺服器均無法連接');
    });
    
    test('獲取並列出可用模型', () async {
      String hostToUse;
      
      // 嘗試從主要伺服器獲取模型
      try {
        final response = await http.get(Uri.parse('$fixedHost/api/tags'));
        if (response.statusCode == 200) {
          hostToUse = fixedHost;
        } else {
          // 如果主要伺服器無法連接，嘗試備用伺服器
          final backupResponse = await http.get(Uri.parse('$backupHost/api/tags'));
          if (backupResponse.statusCode == 200) {
            hostToUse = backupHost;
          } else {
            fail('無法連接到任何伺服器');
          }
        }
      } catch (e) {
        try {
          // 如果主要伺服器出現異常，嘗試備用伺服器
          final backupResponse = await http.get(Uri.parse('$backupHost/api/tags'));
          if (backupResponse.statusCode == 200) {
            hostToUse = backupHost;
          } else {
            fail('無法連接到任何伺服器: $e');
          }
        } catch (e2) {
          fail('主要伺服器和備用伺服器均無法連接: $e, $e2');
        }
      }
      
      // 獲取模型列表
      final response = await http.get(Uri.parse('$hostToUse/api/tags'));
      final jsonResponse = jsonDecode(response.body);
      
      debugPrint('\n從 $hostToUse/api/tags 獲取的模型列表:');
      
      if (jsonResponse.containsKey('models')) {
        final models = jsonResponse['models'] as List;
        debugPrint('\n可用模型列表:');
        for (var model in models) {
          try {
            // 安全地訪問欄位，處理可能為 null 的情況
            final name = model['name'] ?? '未知';
            final size = model['size'] != null ? _formatFileSize(model['size']) : '未知';
            
            // 移除修改時間的顯示
            debugPrint('- $name (大小: $size)');
          } catch (e) {
            // 如果發生錯誤，打印模型資訊和錯誤信息
            debugPrint('處理模型時發生錯誤: $e');
            debugPrint('模型數據: $model');
          }
        }
        
        expect(models, isNotEmpty, reason: '沒有可用的模型');
      } else {
        debugPrint('回應中沒有找到 "models" 字段');
        fail('API 回應格式不符合預期');
      }
    });
  });
}

// 格式化檔案大小，將位元組轉換為更易讀的格式
String _formatFileSize(dynamic bytes) {
  // 確保傳入的是一個數字
  int size;
  if (bytes == null) {
    return '未知大小';
  } else if (bytes is int) {
    size = bytes;
  } else if (bytes is double) {
    size = bytes.toInt();
  } else if (bytes is String) {
    try {
      size = int.parse(bytes);
    } catch (e) {
      return '未知大小';
    }
  } else {
    return '未知大小';
  }
  
  if (size < 1024) return '$size B';
  if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(2)} KB';
  if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}