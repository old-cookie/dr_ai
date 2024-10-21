import 'package:flutter/material.dart';

import '../screen_settings.dart';
import '../worker/haptic.dart';

import '../worker/desktop.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

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
          appBar: AppBar(
              title: Row(children: [
                Text(AppLocalizations.of(context)!.settingsTitleAbout),
                Expanded(child: SizedBox(height: 200, child: MoveWindow()))
              ]),
              actions: desktopControlsActions(context)),
          body: Center(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(children: [
                  Expanded(
                    child: ListView(children: [
                      titleDivider(context: context),
                      button(AppLocalizations.of(context)!.settingsGithub,
                          SimpleIcons.github, () {
                        selectionHaptic();
                        launchUrl(
                            mode: LaunchMode.inAppBrowserView,
                            Uri.parse("https://github.com/your-repo-url"));
                      }),
                      button(AppLocalizations.of(context)!.settingsReportIssue,
                          Icons.report_rounded, () {
                        selectionHaptic();
                        launchUrl(
                            mode: LaunchMode.inAppBrowserView,
                            Uri.parse("https://github.com/your-repo-url/issues"));
                      }),
                      button(AppLocalizations.of(context)!.settingsLicenses,
                          Icons.gavel_rounded, () {
                        selectionHaptic();
                        String legal = "Copyright 2024 ";
                        Widget icon = const Padding(
                          padding: EdgeInsets.all(16),
                          child: ImageIcon(AssetImage("assets/logo512.png"),
                              size: 48),
                        );
                        if (desktopFeature()) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                    child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: LicensePage(
                                      applicationName: "Dr.AI",
                                      applicationIcon: icon,
                                      applicationLegalese: legal),
                                ));
                              });
                        } else {
                          showLicensePage(
                              context: context,
                              applicationName: "Dr.AI",
                              applicationIcon: icon,
                              applicationLegalese: legal);
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
