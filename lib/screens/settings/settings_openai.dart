import 'package:flutter/material.dart';
import '../../services/service_haptic.dart';
import '../../widgets/widgets_units/widget_title.dart';
import '../../main.dart';

/// OpenAI 設置頁面
/// 用於配置 OpenAI API 的相關設置
class ScreenSettingsOpenAI extends StatefulWidget {
  const ScreenSettingsOpenAI({super.key});

  @override
  State<ScreenSettingsOpenAI> createState() => _ScreenSettingsOpenAIState();
}

class _ScreenSettingsOpenAIState extends State<ScreenSettingsOpenAI> {
  final apiKeyController = TextEditingController();
  final baseUrlController = TextEditingController();
  final modelController = TextEditingController();
  final maxTokensController = TextEditingController();
  final temperatureController = TextEditingController();

  bool _useOpenAI = false;
  double _temperature = 0.7;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void dispose() {
    apiKeyController.dispose();
    baseUrlController.dispose();
    modelController.dispose();
    maxTokensController.dispose();
    temperatureController.dispose();
    super.dispose();
  }

  /// 載入 OpenAI 設置
  Future<void> _loadSettings() async {
    _useOpenAI = prefs.getBool("use_openai") ?? false;
    apiKeyController.text = prefs.getString("openai_api_key") ?? '';
    baseUrlController.text = prefs.getString("openai_base_url") ?? 'https://openrouter.ai/api';
    
    // 獲取保存的模型
    String savedModel = prefs.getString("openai_model") ?? 'gpt-4o';
    modelController.text = savedModel;
    

    
    maxTokensController.text = prefs.getString("openai_max_tokens") ?? '2000';
    _temperature = prefs.getDouble("openai_temperature") ?? 0.7;
    setState(() {});
  }

  /// 保存 OpenAI 設置
  Future<void> _saveSettings() async {
    prefs.setBool("use_openai", _useOpenAI);
    prefs.setString("openai_api_key", apiKeyController.text);
    prefs.setString("openai_base_url", baseUrlController.text);
    
    // 保存當前模型
    String modelToSave = modelController.text.isNotEmpty ? modelController.text : 'gpt-4o';
    prefs.setString("openai_model", modelToSave);
    
    prefs.setString("openai_max_tokens", maxTokensController.text);
    prefs.setDouble("openai_temperature", _temperature);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("OpenAI 設置已儲存"),
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OpenAI 設置"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleDivider(top: 8, bottom: 8),
            SwitchListTile(
              title: const Text("使用 OpenAI API"),
              subtitle: const Text("啟用後將使用 OpenAI API 而不是 Ollama"),
              value: _useOpenAI,
              onChanged: (value) {
                setState(() {
                  _useOpenAI = value;
                });
                prefs.setBool("use_openai", value);
                selectionHaptic();
              },
            ),
            titleDivider(top: 8, bottom: 8),
            
            const SizedBox(height: 16),
            Text("API 設置", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: "API Key",
                hintText: "sk-...",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: _useOpenAI,
            ),
            
            const SizedBox(height: 16),
            TextField(
              controller: baseUrlController,
              decoration: const InputDecoration(
                labelText: "API 網址 (可選)",
                hintText: "https://openrouter.ai/api",
                border: OutlineInputBorder(),
              ),
              enabled: _useOpenAI,
            ),
            
            const SizedBox(height: 24),
            Text("模型設置", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            
            // 模型輸入
            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: "模型名稱",
                hintText: "輸入模型名稱（例如: gpt-4o, gpt-4-turbo, gpt-3.5-turbo）",
                border: OutlineInputBorder(),
              ),
              enabled: _useOpenAI,
            ),
            
            const SizedBox(height: 16),
            TextField(
              controller: maxTokensController,
              decoration: const InputDecoration(
                labelText: "最大 Tokens",
                hintText: "2000",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              enabled: _useOpenAI,
            ),
            
            const SizedBox(height: 16),
            Text("溫度: ${_temperature.toStringAsFixed(1)}", style: Theme.of(context).textTheme.bodyLarge),
            Slider(
              value: _temperature,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: _temperature.toStringAsFixed(1),
              onChanged: _useOpenAI ? (double value) {
                setState(() {
                  _temperature = value;
                });
              } : null,
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _useOpenAI ? () {
                  selectionHaptic();
                  _saveSettings();
                } : null,
                child: const Text("儲存設置"),
              ),
            ),
            
            const SizedBox(height: 16),
            if (_useOpenAI) 
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("注意事項", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text("• 常用模型: gpt-4o, gpt-4-turbo, gpt-3.5-turbo"),
                    const Text("• 使用 OpenAI API 需要有效的 API Key"),
                    const Text("• API 調用可能會產生費用，請參考 OpenAI 官方價格"),
                    const Text("• 您的數據將被發送到 OpenAI 服務器進行處理"),
                    const Text("• API Key 僅儲存在您的設備上，不會被發送到其他地方"),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}