import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  @override
  void initState() {
    super.initState();
    // 初始化系統提示詞和相關設置
    systemInputController = TextEditingController(text: prefs.getString("system") ?? "用繁體中文寫下一個適當完成請求的回答。由造成原因、自行解決方案，尋求專業建議三個方向回答在回答之前，請仔細思考問題，並建立逐步的思路鏈，以確保回答 合乎邏輯且準確。您是一位在臨床推理、診斷和治療計劃方面擁有高級知識的醫學專家。");
    useSystem = prefs.getBool("useSystem") ?? true;
    noMarkdown = prefs.getBool("noMarkdown") ?? false;
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

  void setModel() async {
    if (host == null) return;
    var result = await getModels();
    if (!mounted) return;
    
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
                  title: Text(result[index],
                      style: TextStyle(
                          fontWeight: (recommendedModels.contains(result[index]))
                              ? FontWeight.w900
                              : null)),
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
    );
  }
}
