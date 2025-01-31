import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import '../../widgets/widgets_screens/widgets_settings/widget_about.dart';

/// 應用程式關於頁面
/// 展示應用程式相關信息和版權聲明
class ScreenSettingsAbout extends StatefulWidget {
  const ScreenSettingsAbout({super.key});
  @override
  State<ScreenSettingsAbout> createState() => _ScreenSettingsAboutState();
}

class _ScreenSettingsAboutState extends State<ScreenSettingsAbout> {
  @override
  void initState() {
    super.initState();

    /// 確保 Flutter 綁定初始化完成
    WidgetsFlutterBinding.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      /// 使用當前主題的表面顏色作為窗口邊框顏色
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        /// 在頁面中央顯示關於組件
        body: const Center(
          child: WidgetAbout(),
        ),
      ),
    );
  }
}
