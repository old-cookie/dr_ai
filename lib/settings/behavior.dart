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
  late final TextEditingController systemInputController;
  late bool useSystem;
  late bool noMarkdown;

  @override
  void initState() {
    super.initState();
    systemInputController = TextEditingController(text: prefs?.getString("system") ?? "You are a helpful assistant");
    useSystem = prefs?.getBool("useSystem") ?? true;
    noMarkdown = prefs?.getBool("noMarkdown") ?? false;
  }

  @override
  void dispose() {
    systemInputController.dispose();
    super.dispose();
  }

  void _onUseSystemChanged(bool value) {
    selectionHaptic();
    setState(() {
      useSystem = value;
      prefs?.setBool("useSystem", value);
    });
  }

  void _onNoMarkdownChanged(bool value) {
    selectionHaptic();
    setState(() {
      noMarkdown = value;
      prefs?.setBool("noMarkdown", value);
    });
  }

  void _onSystemMessageSaved() {
    selectionHaptic();
    prefs?.setString("system", systemInputController.text.isNotEmpty ? systemInputController.text : "You are a helpful assistant");
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
    );
  }
}