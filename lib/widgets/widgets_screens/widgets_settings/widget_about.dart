import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../services/services_haptic.dart';
import '../../../services/services_desktop.dart';
import '../../widgets_units/widget_title.dart';
import '../../widgets_units/widget_button.dart';

/// 關於頁面組件
/// 用於顯示應用程式相關信息、外部鏈接和許可證
class WidgetAbout extends StatelessWidget {
  const WidgetAbout({super.key});
  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        /// 標題欄
        appBar: AppBar(
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsTitleAbout),

              /// 可拖動區域(僅桌面端)
              Expanded(child: SizedBox(height: 200, child: MoveWindow())),
            ],
          ),
          actions: getDesktopControlsActions(context),
        ),

        /// 主體內容
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      titleDivider(context: context),

                      /// GitHub 倉庫鏈接
                      buildButton(
                        context,
                        AppLocalizations.of(context)!.settingsGithub,
                        SimpleIcons.github,
                        "https://github.com/old-cookie/dr_ai",
                      ),

                      /// 問題報告鏈接
                      buildButton(
                        context,
                        AppLocalizations.of(context)!.settingsReportIssue,
                        Icons.report_rounded,
                        "https://github.com/old-cookie/dr_ai/issues",
                      ),

                      /// 許可證信息按鈕
                      buildLicensesButton(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
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
    return widgetButton(
      text,
      icon,
      () {
        selectionHaptic();
        launchUrl(mode: LaunchMode.inAppBrowserView, Uri.parse(url));
      },
    );
  }

  /// 構建許可證信息按鈕
  /// 顯示應用程式的許可證頁面
  Widget buildLicensesButton(BuildContext context) {
    return widgetButton(
      AppLocalizations.of(context)!.settingsLicenses,
      Icons.gavel_rounded,
      () {
        selectionHaptic();
        showLicensePage(
          context: context,
          applicationName: "Dr.AI",
          applicationIcon: const Padding(
            padding: EdgeInsets.all(16),
            child: ImageIcon(AssetImage("assets/logo512.png"), size: 48),
          ),
          applicationLegalese: "Copyright 2025 ",
        );
      },
    );
  }
}
