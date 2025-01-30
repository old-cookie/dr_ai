import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/haptic.dart';
import '../../services/desktop.dart';
import '../widgets_units/widget_title.dart';
import '../widgets_units/widget_button.dart';

class WidgetAbout extends StatelessWidget {
  const WidgetAbout({super.key});

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
                      buildButton(
                        context,
                        AppLocalizations.of(context)!.settingsGithub,
                        SimpleIcons.github,
                        "https://github.com/old-cookie/dr_ai",
                      ),
                      buildButton(
                        context,
                        AppLocalizations.of(context)!.settingsReportIssue,
                        Icons.report_rounded,
                        "https://github.com/old-cookie/dr_ai/issues",
                      ),
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
