import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../worker/haptic.dart';
import '../../worker/desktop.dart';
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
                  children: [Text(AppLocalizations.of(context)!.settingsTitleAbout), Expanded(child: SizedBox(height: 200, child: MoveWindow()))]),
              actions: desktopControlsActions(context)),
          body: Center(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(children: [
                  Expanded(
                    child: ListView(children: [
                      titleDivider(context: context),
                      widgetButton(AppLocalizations.of(context)!.settingsGithub, SimpleIcons.github, () {
                        selectionHaptic();
                        launchUrl(mode: LaunchMode.inAppBrowserView, Uri.parse("https://github.com/old-cookie/dr_ai"));
                      }),
                      widgetButton(AppLocalizations.of(context)!.settingsReportIssue, Icons.report_rounded, () {
                        selectionHaptic();
                        launchUrl(mode: LaunchMode.inAppBrowserView, Uri.parse("https://github.com/old-cookie/dr_ai/issues"));
                      }),
                      widgetButton(AppLocalizations.of(context)!.settingsLicenses, Icons.gavel_rounded, () {
                        selectionHaptic();
                        String legal = "Copyright 2024 ";
                        Widget icon = const Padding(
                          padding: EdgeInsets.all(16),
                          child: ImageIcon(AssetImage("assets/logo512.png"), size: 48),
                        );
                        if (desktopFeature()) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                    child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: LicensePage(applicationName: "Dr.AI", applicationIcon: icon, applicationLegalese: legal),
                                ));
                              });
                        } else {
                          showLicensePage(context: context, applicationName: "Dr.AI", applicationIcon: icon, applicationLegalese: legal);
                        }
                      }),
                      const SizedBox(height: 16)
                    ]),
                  )
                ])),
          )),
    );
  }
}
