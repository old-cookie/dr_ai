import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../main.dart';

/// 用於獲取 Ollama 模型列表的服務
class ServiceOllama {
  /// 獲取 Ollama 伺服器上可用的模型列表
  static Future<List<String>> getOllamaModels() async {
    try {
      // 從偏好設置中獲取 Ollama 主機地址
      final ollamaHost = prefs.getString("host") ?? host ?? "http://oldcookie2706.asuscomm.com:11434";
      
      // 發送請求獲取模型列表
      final response = await http.get(
        Uri.parse('$ollamaHost/api/tags'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 解析模型列表
        if (data['models'] != null) {
          return List<String>.from(
            data['models'].map((model) => model['name'] as String)
          );
        }
      }
      debugPrint('獲取 Ollama 模型列表失敗: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('獲取 Ollama 模型列表時發生錯誤: $e');
      return [];
    }
  }
}