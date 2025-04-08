import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/service_haptic.dart';
import '../../../services/service_desktop.dart';
import '../../../services/service_auth.dart';
import '../../../services/service_guide.dart';
import '../../widgets_units/widget_title.dart';
import '../../widgets_units/widget_button.dart';
import '../../widgets_units/widget_toggle.dart'; // 添加toggle組件
import '../../../screens/guide/screen_guide_page_1.dart'; // 引入引導頁面

/// 關於頁面組件
/// 用於顯示應用程式相關信息、外部鏈接和許可證
class WidgetAbout extends StatefulWidget {
  const WidgetAbout({super.key});
  @override
  State<WidgetAbout> createState() => _WidgetAboutState();
}

class _WidgetAboutState extends State<WidgetAbout> {
  bool _biometricSupported = false;
  bool _useBiometricAuth = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _loadBiometricSetting();
  }

  /// 檢查設備是否支持生物識別
  Future<void> _checkBiometricSupport() async {
    // 如果是網頁平台，直接設置為不支持
    if (kIsWeb) {
      setState(() {
        _biometricSupported = false;
      });
      return;
    }
    
    final bool deviceSupported = await ServiceAuth.isDeviceSupported();
    final bool canCheckBio = await ServiceAuth.canCheckBiometrics();

    if (mounted) {
      setState(() {
        _biometricSupported = deviceSupported && canCheckBio;
      });
    }
  }

  /// 加載生物識別設置
  Future<void> _loadBiometricSetting() async {
    // 如果是網頁平台，直接設置為禁用
    if (kIsWeb) {
      setState(() {
        _useBiometricAuth = false;
      });
      return;
    }
    
    final bool enabled = await ServiceAuth.isBiometricEnabled();

    if (mounted) {
      setState(() {
        _useBiometricAuth = enabled;
      });
    }
  }

  /// 切換生物識別設置
  Future<void> _toggleBiometricAuth(bool value) async {
    // 如果是網頁平台，禁止啟用生物識別
    if (kIsWeb && value) {
      return;
    }
    
    if (!_biometricSupported && value) {
      return;
    }

    await ServiceAuth.setBiometricEnabled(value);

    if (mounted) {
      setState(() {
        _useBiometricAuth = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsTitleAbout),
              Expanded(child: SizedBox(height: 200, child: MoveWindow())),
            ],
          ),
          actions: getDesktopControlsActions(context),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titleDivider(context: context),

                  if (!kIsWeb) ...[
                    const SizedBox(height: 16),
                    widgetToggle(
                      context,
                      "使用生物識別解鎖",
                      _useBiometricAuth,
                      _toggleBiometricAuth,
                      disabled: !_biometricSupported,
                      icon: Icon(Icons.fingerprint, color: _biometricSupported ? null : Colors.grey),
                    ),
                    const SizedBox(height: 16),
                  ],

                  buildButton(
                    context, 
                    AppLocalizations.of(context)!.settingsGithub,
                    SimpleIcons.github,
                    "https://github.com/old-cookie/dr_ai"
                  ),
                  const SizedBox(height: 8),

                  buildButton(
                    context,
                    AppLocalizations.of(context)!.settingsReportIssue,
                    Icons.report_rounded,
                    "https://github.com/old-cookie/dr_ai/issues",
                  ),
                  const SizedBox(height: 8),

                  buildLicensesButton(context),
                  const SizedBox(height: 8),

                  widgetButton(
                    "重置引導頁面",
                    Icons.restart_alt_rounded,
                    () async {
                      selectionHaptic();
                      try {
                        await GuideService.resetGuide();
                        if (!mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("引導已重置，即將顯示引導頁面"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        
                        await Future.delayed(const Duration(seconds: 1));
                        if (!mounted) return;
                        
                        // 清除導航堆疊並推送引導頁面
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const GuideExample(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("重置失敗：$e")),
                        );
                      }
                    },
                    description: "下次啟動應用時將重新顯示引導頁面",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 構建外部鏈接按鈕
  /// @param context 上下文
  /// @param text 按鈕文字
  /// @param icon 按鈕圖標
  /// @param url 目標URL
  Widget buildButton(BuildContext context, String text, IconData icon, String url) {
    return widgetButton(text, icon, () {
      selectionHaptic();
      launchUrl(mode: LaunchMode.inAppBrowserView, Uri.parse(url));
    });
  }

  /// 構建許可證信息按鈕
  /// 顯示應用程式的許可證頁面
  Widget buildLicensesButton(BuildContext context) {
    return widgetButton(AppLocalizations.of(context)!.settingsLicenses, Icons.gavel_rounded, () {
      selectionHaptic();
      showLicensePage(
        context: context,
        applicationName: "Dr.AI",
        applicationIcon: const Padding(padding: EdgeInsets.all(16), child: ImageIcon(AssetImage("assets/logo512.png"), size: 48)),
        applicationLegalese: "Copyright 2025 ",
      );
    });
  }
}
