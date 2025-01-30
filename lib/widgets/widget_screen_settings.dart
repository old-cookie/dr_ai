import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets_units/widget_title.dart';
import 'widgets_units/widget_button.dart';

import '../services/haptic.dart';
import '../services/setter.dart';
import '../settings/behavior.dart';
import '../settings/interface.dart';
import '../settings/voice.dart';
import '../settings/export.dart';
import '../settings/about.dart';
import '../services/desktop.dart';


class WidgetScreenSettings extends StatefulWidget {
  final TextEditingController hostInputController;
  final bool hostLoading;
  final bool hostInvalidUrl;
  final bool hostInvalidHost;
  final VoidCallback checkHost;
  final bool useHost;
  final SharedPreferences prefs;

  const WidgetScreenSettings({
    super.key,
    required this.hostInputController,
    required this.hostLoading,
    required this.hostInvalidUrl,
    required this.hostInvalidHost,
    required this.checkHost,
    required this.useHost,
    required this.prefs,
  });

  @override
  State<WidgetScreenSettings> createState() => _WidgetScreenSettingsState();
}

class _WidgetScreenSettingsState extends State<WidgetScreenSettings> {
  double iconSize = 1;
  bool animatedInitialized = false;
  bool animatedDesktop = false;

  @override
  Widget build(BuildContext context) {
    if (!animatedInitialized) {
      animatedInitialized = true;
      animatedDesktop = isDesktopLayoutNotRequired(context);
    }

    return PopScope(
      canPop: !widget.hostLoading,
      onPopInvokedWithResult: (didPop, result) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: WindowBorder(
        color: Theme.of(context).colorScheme.surface,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(AppLocalizations.of(context)!.optionSettings),
                Expanded(child: SizedBox(height: 200, child: MoveWindow())),
              ],
            ),
            actions: getDesktopControlsActions(context),
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var column1 = buildColumn1(context);
                  var column2 = buildColumn2(context);

                  animatedDesktop = isDesktopLayoutNotRequired(context);

                  return Column(
                    children: [
                      Expanded(
                        child: isDesktopLayoutNotRequired(context)
                            ? buildDesktopLayout(context, column1, column2)
                            : buildMobileLayout(context, column1, column2),
                      ),
                      const SizedBox(height: 8),
                      buildSavedAutomaticallyButton(context),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildColumn1(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: animatedDesktop ? 8 : 0,
          child: const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.hostInputController,
          keyboardType: TextInputType.url,
          autofillHints: const [AutofillHints.url],
          readOnly: widget.useHost,
          onSubmitted: (value) {
            selectionHaptic();
            widget.checkHost();
          },
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.settingsHost,
            hintText: "http://localhost:11434",
            prefixIcon: IconButton(
              enableFeedback: false,
              tooltip: AppLocalizations.of(context)!.tooltipAddHostHeaders,
              onPressed: addHostHeaders,
              icon: const Icon(Icons.add_rounded),
            ),
            suffixIcon: widget.useHost
                ? const SizedBox.shrink()
                : (widget.hostLoading
                    ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator())
                    : IconButton(
                        enableFeedback: false,
                        tooltip: AppLocalizations.of(context)!.tooltipSave,
                        onPressed: () {
                          selectionHaptic();
                          widget.checkHost();
                        },
                        icon: const Icon(Icons.save_rounded),
                      )),
            border: const OutlineInputBorder(),
            error: (widget.hostInvalidHost || widget.hostInvalidUrl)
                ? InkWell(
                    onTap: () {
                      selectionHaptic();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.settingsHostInvalidDetailed(widget.hostInvalidHost ? "host" : "url")),
                          showCloseIcon: true,
                        ),
                      );
                    },
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.settingsHostInvalid(widget.hostInvalidHost ? "host" : "url"),
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                  )
                : null,
            helper: InkWell(
              onTap: () {
                selectionHaptic();
              },
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: widget.hostLoading
                  ? Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.settingsHostChecking,
                          style: const TextStyle(color: Colors.grey, fontFamily: "monospace"),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(Icons.check_rounded, color: Colors.green.harmonizeWith(Theme.of(context).colorScheme.primary)),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.settingsHostValid,
                          style: TextStyle(
                            color: Colors.green.harmonizeWith(Theme.of(context).colorScheme.primary),
                            fontFamily: "monospace",
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildColumn2(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSettingsButton(
          AppLocalizations.of(context)!.settingsTitleBehavior,
          Icons.psychology_rounded,
          () {
            selectionHaptic();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsBehavior()));
          },
          context: context,
          description: "\n${AppLocalizations.of(context)!.settingsDescriptionBehavior}",
        ),
        buildSettingsButton(
          AppLocalizations.of(context)!.settingsTitleInterface,
          Icons.web_asset_rounded,
          () {
            selectionHaptic();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsInterface()));
          },
          context: context,
          description: "\n${AppLocalizations.of(context)!.settingsDescriptionInterface}",
        ),
        (!isDesktopPlatform(includeWeb: true))
            ? buildSettingsButton(
                AppLocalizations.of(context)!.settingsTitleVoice,
                Icons.headphones_rounded,
                () {
                  selectionHaptic();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsVoice()));
                },
                context: context,
                description: "\n${AppLocalizations.of(context)!.settingsDescriptionVoice}",
                badge: AppLocalizations.of(context)!.settingsExperimentalBeta,
              )
            : const SizedBox.shrink(),
        buildSettingsButton(
          AppLocalizations.of(context)!.settingsTitleExport,
          Icons.share_rounded,
          () {
            selectionHaptic();
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsExport()));
          },
          context: context,
          description: "\n${AppLocalizations.of(context)!.settingsDescriptionExport}",
        ),
        Builder(
          builder: (context) {
            return buildSettingsButton(
              AppLocalizations.of(context)!.settingsTitleAbout,
              Icons.help_rounded,
              () {
                selectionHaptic();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsAbout()));
              },
              context: context,
              description: "\n${AppLocalizations.of(context)!.settingsDescriptionAbout}",
              iconBadge: null,
            );
          },
        ),
      ],
    );
  }

  Widget buildDesktopLayout(BuildContext context, Widget column1, Widget column2) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              column1,
              Expanded(
                child: Center(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    enableFeedback: false,
                    hoverColor: Colors.transparent,
                    onTap: animateIcon,
                    child: AnimatedScale(
                      scale: iconSize,
                      duration: const Duration(milliseconds: 400),
                      child: const ImageIcon(AssetImage("assets/logo512.png"), size: 44),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, 8),
                child: widgetButton(
                  AppLocalizations.of(context)!.settingsSavedAutomatically,
                  Icons.info_rounded,
                  null,
                  color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
        verticalTitleDivider(context: context),
        Expanded(child: column2),
      ],
    );
  }

  Widget buildMobileLayout(BuildContext context, Widget column1, Widget column2) {
    return ListView(
      children: [
        column1,
        AnimatedOpacity(
          opacity: animatedDesktop ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: titleDivider(bottom: 4),
        ),
        AnimatedOpacity(
          opacity: animatedDesktop ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: column2,
        ),
      ],
    );
  }

  Widget buildSavedAutomaticallyButton(BuildContext context) {
    return isDesktopLayoutNotRequired(context)
        ? const SizedBox.shrink()
        : widgetButton(
            AppLocalizations.of(context)!.settingsSavedAutomatically,
            Icons.info_rounded,
            null,
            color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary),
          );
  }

  Widget buildSettingsButton(
    String title,
    IconData icon,
    VoidCallback? onPressed, {
    required BuildContext context,
    String? description,
    String? badge,
    String? iconBadge,
  }) {
    return widgetButton(
      title,
      icon,
      onPressed,
      context: context,
      description: description,
      badge: badge,
      iconBadge: iconBadge,
    );
  }

  Future<void> addHostHeaders() async {
    selectionHaptic();
    String tmp = await prompt(
      context,
      placeholder: "{\"Authorization\": \"Bearer ...\"}",
      title: AppLocalizations.of(context)!.settingsHostHeaderTitle,
      value: (widget.prefs.getString("hostHeaders") ?? ""),
      enableSuggestions: false,
      valueIfCanceled: "{}",
      validator: (content) async {
        try {
          var tmp = jsonDecode(content);
          tmp as Map<String, dynamic>;
          return true;
        } catch (_) {
          return false;
        }
      },
      validatorError: AppLocalizations.of(context)!.settingsHostHeaderInvalid,
      prefill: !((widget.prefs.getString("hostHeaders") ?? {}) == "{}"),
    );
    widget.prefs.setString("hostHeaders", tmp);
  }

  void animateIcon() async {
    if (iconSize != 1) return;
    heavyHaptic();
    setState(() {
      iconSize = 0.8;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      iconSize = 1.2;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      iconSize = 1;
    });
  }
}