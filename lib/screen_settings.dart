import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';
import 'worker/desktop.dart';
import 'worker/haptic.dart';
import 'worker/setter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'settings/behavior.dart';
import 'settings/interface.dart';
import 'settings/voice.dart';
import 'settings/export.dart';
import 'settings/about.dart';

// Add new widget imports
//import 'widgets/screen_settings/toggle.dart';
import 'widgets/screen_settings/title.dart';
import 'widgets/screen_settings/button.dart';

import 'package:dartx/dartx.dart';
import 'package:http/http.dart' as http;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';

class ScreenSettings extends StatefulWidget {
  const ScreenSettings({super.key});

  @override
  State<ScreenSettings> createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  final hostInputController = TextEditingController(text: (useHost) ? fixedHost : (prefs?.getString("host") ?? "http://localhost:11434"));
  bool hostLoading = false;
  bool hostInvalidUrl = false;
  bool hostInvalidHost = false;
  void checkHost() async {
    setState(() {
      hostLoading = true;
      hostInvalidUrl = false;
      hostInvalidHost = false;
    });
    var tmpHost = hostInputController.text.trim().removeSuffix("/").trim();

    if (tmpHost.isEmpty || !Uri.parse(tmpHost).isAbsolute) {
      setState(() {
        hostInvalidUrl = true;
        hostLoading = false;
      });
      return;
    }

    http.Response? request;
    try {
      var client = http.Client();
      final requestBase = http.Request("get", Uri.parse(tmpHost))
        ..headers.addAll(
          (jsonDecode(prefs!.getString("hostHeaders") ?? "{}") as Map).cast<String, String>(),
        )
        ..followRedirects = false;
      request = await http.Response.fromStream(
          await requestBase.send().timeout(Duration(milliseconds: (5000.0 * (prefs!.getDouble("timeoutMultiplier") ?? 1.0)).round()), onTimeout: () {
        return http.StreamedResponse(const Stream.empty(), 408);
      }));
      client.close();
    } catch (e) {
      setState(() {
        hostInvalidHost = true;
        hostLoading = false;
      });
      return;
    }
    if ((request.statusCode == 200 && request.body == "Ollama is running") || (Uri.parse(tmpHost).toString() == fixedHost)) {
      setState(() {
        hostLoading = false;
        host = tmpHost;
        if (hostInputController.text != host! && (Uri.parse(tmpHost).toString() != fixedHost)) {
          hostInputController.text = host!;
        }
      });
      prefs?.setString("host", host!);
    } else {
      setState(() {
        hostInvalidHost = true;
        hostLoading = false;
      });
    }
    selectionHaptic();
  }

  double iconSize = 1;
  bool animatedInitialized = false;
  bool animatedDesktop = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    if ((Uri.parse(hostInputController.text.trim().removeSuffix("/").trim()).toString() != fixedHost)) {
      checkHost();
    }
  }

  @override
  void dispose() {
    super.dispose();
    hostInputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!animatedInitialized) {
      animatedInitialized = true;
      animatedDesktop = desktopLayoutNotRequired(context);
    }
    return PopScope(
        canPop: !hostLoading,
        onPopInvokedWithResult: (didPop, result) {
          settingsOpen = false;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: WindowBorder(
            color: Theme.of(context).colorScheme.surface,
            child: Scaffold(
                appBar: AppBar(
                    title: Row(
                        children: [Text(AppLocalizations.of(context)!.optionSettings), Expanded(child: SizedBox(height: 200, child: MoveWindow()))]),
                    actions: desktopControlsActions(context)),
                body: Center(
                  child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: LayoutBuilder(builder: (context, constraints) {
                        var column1 = Column(mainAxisSize: MainAxisSize.min, children: [
                          AnimatedContainer(
                              duration: const Duration(milliseconds: 200), height: animatedDesktop ? 8 : 0, child: const SizedBox.shrink()),
                          const SizedBox(height: 8),
                          TextField(
                              controller: hostInputController,
                              keyboardType: TextInputType.url,
                              autofillHints: const [AutofillHints.url],
                              readOnly: useHost,
                              onSubmitted: (value) {
                                selectionHaptic();
                                checkHost();
                              },
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.settingsHost,
                                  hintText: "http://localhost:11434",
                                  prefixIcon: IconButton(
                                      enableFeedback: false,
                                      tooltip: AppLocalizations.of(context)!.tooltipAddHostHeaders,
                                      onPressed: () async {
                                        selectionHaptic();
                                        String tmp = await prompt(context,
                                            placeholder: "{\"Authorization\": \"Bearer ...\"}",
                                            title: AppLocalizations.of(context)!.settingsHostHeaderTitle,
                                            value: (prefs!.getString("hostHeaders") ?? ""),
                                            enableSuggestions: false,
                                            valueIfCanceled: "{}", validator: (content) async {
                                          try {
                                            var tmp = jsonDecode(content);
                                            tmp as Map<String, dynamic>;
                                            return true;
                                          } catch (_) {
                                            return false;
                                          }
                                        },
                                            validatorError: AppLocalizations.of(context)!.settingsHostHeaderInvalid,
                                            prefill: !((prefs!.getString("hostHeaders") ?? {}) == "{}"));
                                        prefs!.setString("hostHeaders", tmp);
                                      },
                                      icon: const Icon(Icons.add_rounded)),
                                  suffixIcon: useHost
                                      ? const SizedBox.shrink()
                                      : (hostLoading
                                          ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator())
                                          : IconButton(
                                              enableFeedback: false,
                                              tooltip: AppLocalizations.of(context)!.tooltipSave,
                                              onPressed: () {
                                                selectionHaptic();
                                                checkHost();
                                              },
                                              icon: const Icon(Icons.save_rounded),
                                            )),
                                  border: const OutlineInputBorder(),
                                  error: (hostInvalidHost || hostInvalidUrl)
                                      ? InkWell(
                                          onTap: () {
                                            selectionHaptic();
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content:
                                                    Text(AppLocalizations.of(context)!.settingsHostInvalidDetailed(hostInvalidHost ? "host" : "url")),
                                                showCloseIcon: true));
                                          },
                                          splashFactory: NoSplash.splashFactory,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          child: Row(
                                            children: [
                                              Icon(Icons.error_rounded, color: Theme.of(context).colorScheme.error),
                                              const SizedBox(width: 8),
                                              Text(AppLocalizations.of(context)!.settingsHostInvalid(hostInvalidHost ? "host" : "url"),
                                                  style: TextStyle(color: Theme.of(context).colorScheme.error))
                                            ],
                                          ))
                                      : null,
                                  helper: InkWell(
                                      onTap: () {
                                        selectionHaptic();
                                      },
                                      splashFactory: NoSplash.splashFactory,
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      child: hostLoading
                                          ? Row(
                                              children: [
                                                const Icon(Icons.search_rounded, color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.settingsHostChecking,
                                                    style: const TextStyle(color: Colors.grey, fontFamily: "monospace"))
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Icon(Icons.check_rounded, color: Colors.green.harmonizeWith(Theme.of(context).colorScheme.primary)),
                                                const SizedBox(width: 8),
                                                Text(AppLocalizations.of(context)!.settingsHostValid,
                                                    style: TextStyle(
                                                        color: Colors.green.harmonizeWith(Theme.of(context).colorScheme.primary),
                                                        fontFamily: "monospace"))
                                              ],
                                            ))))
                        ]);
                        var column2 = Column(mainAxisSize: MainAxisSize.min, children: [
                          button(AppLocalizations.of(context)!.settingsTitleBehavior, Icons.psychology_rounded, () {
                            selectionHaptic();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsBehavior()));
                          }, context: context, description: "\n${AppLocalizations.of(context)!.settingsDescriptionBehavior}"),
                          button(AppLocalizations.of(context)!.settingsTitleInterface, Icons.web_asset_rounded, () {
                            selectionHaptic();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsInterface()));
                          }, context: context, description: "\n${AppLocalizations.of(context)!.settingsDescriptionInterface}"),
                          (!desktopFeature(web: true))
                              ? button(AppLocalizations.of(context)!.settingsTitleVoice, Icons.headphones_rounded, () {
                                  selectionHaptic();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsVoice()));
                                },
                                  context: context,
                                  description: "\n${AppLocalizations.of(context)!.settingsDescriptionVoice}",
                                  badge: AppLocalizations.of(context)!.settingsExperimentalBeta)
                              : const SizedBox.shrink(),
                          button(AppLocalizations.of(context)!.settingsTitleExport, Icons.share_rounded, () {
                            selectionHaptic();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsExport()));
                          }, context: context, description: "\n${AppLocalizations.of(context)!.settingsDescriptionExport}"),
                          Builder(builder: (context) {
                            return button(AppLocalizations.of(context)!.settingsTitleAbout, Icons.help_rounded, () {
                              selectionHaptic();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ScreenSettingsAbout()));
                            }, context: context, description: "\n${AppLocalizations.of(context)!.settingsDescriptionAbout}", iconBadge: null);
                          })
                        ]);
                        animatedDesktop = desktopLayoutNotRequired(context);
                        return Column(children: [
                          Expanded(
                              child: desktopLayoutNotRequired(context)
                                  ? Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Expanded(
                                          child: Column(mainAxisSize: MainAxisSize.max, children: [
                                        column1,
                                        Expanded(
                                            child: Center(
                                                child: InkWell(
                                          splashFactory: NoSplash.splashFactory,
                                          highlightColor: Colors.transparent,
                                          enableFeedback: false,
                                          hoverColor: Colors.transparent,
                                          onTap: () async {
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
                                          },
                                          child: AnimatedScale(
                                            scale: iconSize,
                                            duration: const Duration(milliseconds: 400),
                                            child: const ImageIcon(AssetImage("assets/logo512.png"), size: 44),
                                          ),
                                        ))),
                                        Transform.translate(
                                          offset: const Offset(0, 8),
                                          child: button(AppLocalizations.of(context)!.settingsSavedAutomatically, Icons.info_rounded, null,
                                              color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary)),
                                        )
                                      ])),
                                      verticalTitleDivider(context: context),
                                      Expanded(child: column2)
                                    ])
                                  : ListView(children: [
                                      column1,
                                      AnimatedOpacity(
                                          opacity: animatedDesktop ? 0 : 1,
                                          duration: const Duration(milliseconds: 200),
                                          child: titleDivider(bottom: 4)),
                                      AnimatedOpacity(opacity: animatedDesktop ? 0 : 1, duration: const Duration(milliseconds: 200), child: column2)
                                    ])),
                          const SizedBox(height: 8),
                          desktopLayoutNotRequired(context)
                              ? const SizedBox.shrink()
                              : button(AppLocalizations.of(context)!.settingsSavedAutomatically, Icons.info_rounded, null,
                                  color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary))
                        ]);
                      })),
                ))));
  }
}
