import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/service_haptic.dart';
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
    systemInputController = TextEditingController(text: prefs.getString("system") ?? "您是一位提供一般醫療資訊和指導的人工智慧醫生。您可以提供事實，提出常見病症的可能原因和治療方法，並提倡健康的習慣。然而，您無法取代專業的醫療建議、診斷或治療。始終提醒使用者諮詢合格的醫療保健提供者以獲得個人化護理。");
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
    prefs.setString("system", systemInputController.text.isNotEmpty ? systemInputController.text : "您是一位提供一般醫療資訊和指導的人工智慧醫生。您可以提供事實，提出常見病症的可能原因和治療方法，並提倡健康的習慣。然而，您無法取代專業的醫療建議、診斷或治療。始終提醒使用者諮詢合格的醫療保健提供者以獲得個人化護理。");
  }

  @override
  Widget build(BuildContext context) {
    /// 使用行為設置組件構建界面
    return WidgetBehavior(
      systemInputController: systemInputController,
      useSystem: useSystem,
      noMarkdown: noMarkdown,
      onUseSystemChanged: _onUseSystemChanged,
      onNoMarkdownChanged: _onNoMarkdownChanged,
      onSystemMessageSaved: _onSystemMessageSaved,
    );
  }
}
