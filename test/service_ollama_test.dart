import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:dr_ai/main.dart';
import 'dart:convert';

void main() {
  group('Ollama Server Connection Tests', () {
    final String ollamaServerUrl = fixedHost; // 從 main.dart 獲取
    final String backupServerUrl = backupHost; // 備用伺服器地址

    test('Ping to Ollama Server - Primary Endpoint', () async {
      try {
        final response = await http.get(Uri.parse('$ollamaServerUrl/api/version'));
        
        // 檢查連接是否成功
        expect(response.statusCode, equals(200));
        
        // 檢查回應是否包含有效的 JSON
        final jsonResponse = jsonDecode(response.body);
        expect(jsonResponse, isNotNull);
        expect(jsonResponse['version'], isNotNull);
        
        print('Primary Ollama Server Connection Test Passed: ${response.body}');
      } catch (e) {
        // 如果主要端點失敗，則測試是否可以連接到備用端點
        print('Primary Ollama Server Connection Failed: $e');
        
        try {
          final backupResponse = await http.get(Uri.parse('$backupServerUrl/api/version'));
          expect(backupResponse.statusCode, equals(200));
          
          final jsonResponse = jsonDecode(backupResponse.body);
          expect(jsonResponse, isNotNull);
          expect(jsonResponse['version'], isNotNull);
          
          print('Backup Ollama Server Connection Test Passed: ${backupResponse.body}');
        } catch (e) {
          // 如果備用端點也失敗，則標記測試失敗
          fail('Both Primary and Backup Ollama Server connections failed: $e');
        }
      }
    });

    test('List Ollama Models', () async {
      try {
        final response = await http.get(Uri.parse('$ollamaServerUrl/api/tags'));
        
        // 檢查連接是否成功
        expect(response.statusCode, equals(200));
        
        // 檢查回應是否包含有效的 JSON 和模型列表
        final jsonResponse = jsonDecode(response.body);
        expect(jsonResponse, isNotNull);
        expect(jsonResponse['models'], isA<List>());
        
        print('Ollama Models List Test Passed: ${jsonResponse['models'].length} models found');
      } catch (e) {
        // 如果主要端點失敗，則測試是否可以連接到備用端點
        print('Primary Ollama Server Models List Failed: $e');
        
        try {
          final backupResponse = await http.get(Uri.parse('$backupServerUrl/api/tags'));
          expect(backupResponse.statusCode, equals(200));
          
          final jsonResponse = jsonDecode(backupResponse.body);
          expect(jsonResponse, isNotNull);
          expect(jsonResponse['models'], isA<List>());
          
          print('Backup Ollama Server Models List Test Passed: ${jsonResponse['models'].length} models found');
        } catch (e) {
          // 如果備用端點也失敗，則標記測試失敗
          fail('Both Primary and Backup Ollama Server models list failed: $e');
        }
      }
    });
  });
}