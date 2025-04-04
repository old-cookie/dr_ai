import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/service_haptic.dart';
import '../../services/service_setter.dart';
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

  /// 儲存系統提示詞設置
  void _onSystemMessageSaved() {
    selectionHaptic();
  }

  /// 檢查連接狀態
  void _checkConnectionStatus() {
    if (host == null) {
      setState(() {
        connectionError = "伺服器未配置";
      });
    } else {
      setState(() {
        connectionError = null;
      });
    }
  }

  void setModel() async {
    if (host == null) {
      setState(() {
        connectionError = "伺服器未配置";
      });
      
      // 顯示連接錯誤對話框
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)?.error ?? "錯誤"),
            content: Text(AppLocalizations.of(context)?.serverNotConfigured ?? "伺服器未配置"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)?.ok ?? "確定"),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // 顯示載入中對話框
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(AppLocalizations.of(context)?.loading ?? "載入中..."),
              ],
            ),
          );
        },
      );
      
      var result = await getModels();
      
      if (!mounted) return;
      Navigator.pop(context); // 關閉載入中對話框
      
      setState(() {
        connectionError = null;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.dialogSelectModel),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: result.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(result[index], style: TextStyle(fontWeight: (recommendedModels.contains(result[index])) ? FontWeight.w900 : null)),
                    onTap: () {
                      selectionHaptic();
                      model = result[index];
                      prefs.setString("model", model!);
                      chatAllowed = true;
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
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // 關閉載入中對話框
      
      setState(() {
        connectionError = e.toString();
      });
      
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)?.error ?? "錯誤"),
            content: Text("${AppLocalizations.of(context)?.serverConnectionError ?? "連接錯誤"}: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)?.ok ?? "確定"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetBehavior(
      systemInputController: systemInputController,
      useSystem: useSystem,
      noMarkdown: noMarkdown,
      onUseSystemChanged: _onUseSystemChanged,
      onNoMarkdownChanged: _onNoMarkdownChanged,
      onSystemMessageSaved: _onSystemMessageSaved,
      onModelSelected: setModel,
      model: model ?? fixedModel,
      connectionError: connectionError,
    );
  }
}
