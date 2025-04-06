import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/service_haptic.dart';
import '../../services/service_ollama.dart'; // 添加 Ollama 服務引用

import '../../widgets/widgets_screens/widgets_settings/widget_behavior.dart';

/// 行為設置頁面
/// 用於配置系統提示詞和 Markdown 相關選項
class ScreenSettingsBehavior extends StatefulWidget {
  const ScreenSettingsBehavior({super.key});
  @override
  State<ScreenSettingsBehavior> createState() => _ScreenSettingsBehaviorState();
}

class _ScreenSettingsBehaviorState extends State<ScreenSettingsBehavior> {
  /// 系統提示詞輸入控制器
  late final TextEditingController systemInputController;

  /// 是否使用系統提示詞
  late bool useSystem;

  /// 是否禁用 Markdown 格式
  late bool noMarkdown;
  
  /// 是否使用 OpenAI API
  late bool useOpenAI;

  /// 連接錯誤信息
  String? connectionError;

  @override
  void initState() {
    super.initState();
    // 初始化系統提示詞和相關設置
    systemInputController = TextEditingController(
        text: prefs.getString("system") ??
            "您是一位在臨床推理、診斷和治療計劃方面擁有高級知識的醫學專家。必需使用**繁體中文**回答。由造成原因、自行解決方案，尋求專業建議三個方向回答在回答之前，請仔細思考問題，確保回答 合乎邏輯且準確。 合乎邏輯且準確。您是一位在臨床推理、診斷和治療計劃方面擁有高級知識的醫學專家。");
    useSystem = prefs.getBool("useSystem") ?? true;
    noMarkdown = prefs.getBool("noMarkdown") ?? false;
    
    // 獲取 OpenAI 模式設置
    useOpenAI = prefs.getBool("use_openai") ?? true;

    // 初始化時檢查連接狀態
    _checkConnectionStatus();
  }

  @override
  void dispose() {
    /// 釋放輸入控制器資源
    systemInputController.dispose();
    super.dispose();
  }

  /// 處理系統提示詞開關變更
  void _onUseSystemChanged(bool value) {
    selectionHaptic();
    setState(() {
      useSystem = value;
      prefs.setBool("useSystem", value);
    });
  }

  /// 處理 Markdown 格式開關變更
  void _onNoMarkdownChanged(bool value) {
    selectionHaptic();
    setState(() {
      noMarkdown = value;
      prefs.setBool("noMarkdown", value);
    });
  }

  /// 處理 API 提供者切換 (OpenAI/Ollama)
  void _onUseOpenAIChanged(bool value) {
    selectionHaptic();
    setState(() {
      useOpenAI = value;
      prefs.setBool("use_openai", value);
      // 檢查連接狀態
      _checkConnectionStatus();
    });
  }

  /// 儲存系統提示詞設置
  void _onSystemMessageSaved() {
    selectionHaptic();
    // 保存系統提示詞
    String systemMessage = systemInputController.text.trim();
    if (systemMessage.isNotEmpty) {
      prefs.setString("system", systemMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.save ?? "已保存"),
          showCloseIcon: true,
        ),
      );
    }
  }

  /// 檢查連接狀態
  void _checkConnectionStatus() {
    if (useOpenAI) {
      // 檢查 OpenAI 設置
      String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        setState(() {
          connectionError = "OpenAI API 金鑰未設置";
        });
      } else {
        setState(() {
          connectionError = null;
        });
      }
    } else {
      // 檢查 Ollama 設置
      String ollamaHost = prefs.getString("host") ?? host ?? "http://localhost:11434";
      if (ollamaHost.isEmpty) {
        setState(() {
          connectionError = "Ollama 伺服器地址未設置";
        });
      } else {
        setState(() {
          connectionError = null;
        });
      }
    }
  }

  /// 設置模型
  void setModel() async {
    selectionHaptic();
    
    if (useOpenAI) {
      // 顯示提示，告知用戶需要在 OpenAI 頁面進行編輯
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.editInOpenAIPage ?? "請在 OpenAI 設置頁面中編輯模型設定"),
          showCloseIcon: true,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // 對於 Ollama 模式，顯示可用模型列表
      try {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)?.dialogSelectModel ?? "選擇模型"),
              content: Text(AppLocalizations.of(context)?.loadingModels ?? "正在加載模型列表..."),
            );
          },
        );
        
        // 獲取 Ollama 模型列表
        final modelList = await ServiceOllama.getOllamaModels();
        
        // 關閉加載對話框
        Navigator.of(context).pop();
        
        // 顯示模型選擇對話框
        if (modelList.isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)?.dialogSelectModel ?? "選擇模型"),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: ListView.builder(
                    itemCount: modelList.length,
                    itemBuilder: (context, index) {
                      final isRecommended = recommendedModels.contains(modelList[index]);
                      return ListTile(
                        title: Text(
                          modelList[index] + (isRecommended ? " ⭐" : "")
                        ),
                        onTap: () {
                          // 保存選擇的模型
                          prefs.setString("ollama_model", modelList[index]);
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.noModelsFound ?? "未找到可用的模型"),
              showCloseIcon: true,
            ),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // 關閉加載對話框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("無法獲取模型列表: $e"),
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 獲取當前使用的模型
    String currentModel = "";
    if (useOpenAI) {
      currentModel = prefs.getString("openai_model") ?? (dotenv.env['model'] ?? "gpt-4o");
    } else {
      currentModel = prefs.getString("ollama_model") ?? (fixedModel);
    }
    
    return WidgetBehavior(
      systemInputController: systemInputController,
      useSystem: useSystem,
      noMarkdown: noMarkdown,
      useOpenAI: useOpenAI,
      onUseSystemChanged: _onUseSystemChanged,
      onNoMarkdownChanged: _onNoMarkdownChanged,
      onUseOpenAIChanged: _onUseOpenAIChanged,
      onSystemMessageSaved: _onSystemMessageSaved,
      onModelSelected: setModel,
      model: currentModel,
      connectionError: connectionError,
    );
  }
}
