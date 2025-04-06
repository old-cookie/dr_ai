import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    // 載入環境變數（特別是 OpenAI API 金鑰）
    await dotenv.load(fileName: '.env');
  });

  group('OpenAI Server Connection Tests', () {
    test('Ping to OpenAI Server - Models Endpoint', () async {
      // 從環境變數獲取 API 金鑰
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      final baseUrl = dotenv.env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';

      // 檢查 API 金鑰是否存在
      if (apiKey == null || apiKey.isEmpty) {
        print('OpenAI API Key is not configured in .env file. Test skipped.');
        return;
      }

      try {
        final response = await http.get(
          Uri.parse('$baseUrl/models'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        );
        
        // 檢查連接是否成功
        expect(response.statusCode, equals(200));
        
        // 檢查回應是否包含有效的 JSON
        final jsonResponse = jsonDecode(response.body);
        expect(jsonResponse, isNotNull);
        expect(jsonResponse['data'], isA<List>());
        
        print('OpenAI Server Connection Test Passed: ${jsonResponse['data'].length} models available');
      } catch (e) {
        // 如果連接失敗，則測試失敗
        fail('OpenAI Server connection failed: $e');
      }
    });

    test('Test OpenAI API Simple Completion', () async {
      // 從環境變數獲取 API 金鑰
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      final baseUrl = dotenv.env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';

      // 檢查 API 金鑰是否存在
      if (apiKey == null || apiKey.isEmpty) {
        print('OpenAI API Key is not configured in .env file. Test skipped.');
        return;
      }

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'google/gemma-3-12b-it:free', // 使用較小的模型進行測試
            'messages': [
              {'role': 'system', 'content': 'You are a test assistant. Please reply.'},
              {'role': 'user', 'content': 'This is a test. Please reply "OpenAI connection test successful".'}
            ],
            'max_tokens': 50,
          }),
        );
        
        // 檢查連接是否成功
        expect(response.statusCode, equals(200));
        
        // 檢查回應是否包含有效的 JSON
        final jsonResponse = jsonDecode(response.body);
        expect(jsonResponse, isNotNull);
        expect(jsonResponse['choices'], isA<List>());
        expect(jsonResponse['choices'].length, greaterThan(0));
        
        final content = jsonResponse['choices'][0]['message']['content'];
        print('OpenAI API Test Response: $content');
        // 修改期望檢查，使用 trim() 移除空白字符，然後進行包含檢查
        expect(content.trim().contains('OpenAI connection test successful'), isTrue);
        
      } catch (e) {
        // 如果連接失敗，則測試失敗
        fail('OpenAI API completion test failed: $e');
      }
    });
  });
}