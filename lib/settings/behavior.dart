import 'package:flutter/material.dart';
import '../main.dart';
import '../worker/haptic.dart';
import '../widgets/widgets_settings/widget_behavior.dart';

class ScreenSettingsBehavior extends StatefulWidget {
  const ScreenSettingsBehavior({super.key});

  @override
  State<ScreenSettingsBehavior> createState() => _ScreenSettingsBehaviorState();
}

class _ScreenSettingsBehaviorState extends State<ScreenSettingsBehavior> {
  final systemInputController = TextEditingController(text: prefs?.getString("system") ?? "You are a helpful assistant");

  @override
  void dispose() {
    systemInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetBehavior(
      systemInputController: systemInputController,
      useSystem: prefs!.getBool("useSystem") ?? true,
      noMarkdown: prefs!.getBool("noMarkdown") ?? false,
      onUseSystemChanged: (value) {
        selectionHaptic();
        prefs!.setBool("useSystem", value);
        setState(() {});
      },
      onNoMarkdownChanged: (value) {
        selectionHaptic();
        prefs!.setBool("noMarkdown", value);
        setState(() {});
      },
      onSystemMessageSaved: () {
        selectionHaptic();
        prefs?.setString("system",
            (systemInputController.text.isNotEmpty) ? systemInputController.text : "You are a helpful assistant");
      },
    );
  }
}
