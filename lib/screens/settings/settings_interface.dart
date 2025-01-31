import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../widgets/widgets_screens/widgets_settings/widget_interface.dart';

/// 介面設置頁面
/// 用於配置應用程式的外觀和顯示相關選項
class ScreenSettingsInterface extends StatefulWidget {
  const ScreenSettingsInterface({super.key});
  @override
  State<ScreenSettingsInterface> createState() => _ScreenSettingsInterfaceState();
}

class _ScreenSettingsInterfaceState extends State<ScreenSettingsInterface> {
  SharedPreferences? _prefs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WidgetInterface(
      prefs: _prefs!,
      setMainAppState: setMainAppState,
    );
  }
}
