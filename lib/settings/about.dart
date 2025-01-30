import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../widgets/widgets_settings/widget_about.dart';

class ScreenSettingsAbout extends StatefulWidget {
  const ScreenSettingsAbout({super.key});

  @override
  State<ScreenSettingsAbout> createState() => _ScreenSettingsAboutState();
}

class _ScreenSettingsAboutState extends State<ScreenSettingsAbout> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        body: const Center(
          child: WidgetAbout(),
        ),
      ),
    );
  }
}