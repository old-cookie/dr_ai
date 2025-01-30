import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dartx/dartx.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../worker/haptic.dart';
import '../../worker/desktop.dart';
import '../../worker/theme.dart';
import '../widgets_units/widget_toggle.dart';
import '../widgets_units/widget_title.dart';
import '../widgets_units/widget_button.dart';

class WidgetInterface extends StatefulWidget {
  final SharedPreferences prefs;
  final Function? setMainAppState;

  const WidgetInterface({
    super.key,
    required this.prefs,
    this.setMainAppState,
  });

  @override
  State<WidgetInterface> createState() => _WidgetInterfaceState();
}

String _formatDuration(double seconds) {
  if (seconds <= 60) return "";

  final minutes = seconds ~/ 60;
  final remainingSeconds = (seconds % 60).toInt();

  String formattedDuration = "${minutes}m";
  if (remainingSeconds > 0) formattedDuration += " ${remainingSeconds}s";

  return "($formattedDuration)";
}

class _WidgetInterfaceState extends State<WidgetInterface> {
  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsTitleInterface),
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
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsShowModelTags,
                        widget.prefs.getBool("modelTags") ?? false,
                        (value) => widget.prefs.setBool("modelTags", value),
                      ),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsPreloadModels,
                        widget.prefs.getBool("preloadModel") ?? true,
                        (value) => widget.prefs.setBool("preloadModel", value),
                      ),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsResetOnModelChange,
                        widget.prefs.getBool("resetOnModelSelect") ?? true,
                        (value) => widget.prefs.setBool("resetOnModelSelect", value),
                      ),
                      titleDivider(bottom: isDesktopLayoutNotRequired(context) ? 38 : 20, context: context),
                      _buildRequestTypeSegmentedButton(context),
                      const SizedBox(height: 16),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsGenerateTitles,
                        widget.prefs.getBool("generateTitles") ?? true,
                        (value) => widget.prefs.setBool("generateTitles", value),
                      ),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsEnableEditing,
                        widget.prefs.getBool("enableEditing") ?? true,
                        (value) => widget.prefs.setBool("enableEditing", value),
                      ),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsAskBeforeDelete,
                        widget.prefs.getBool("askBeforeDeletion") ?? false,
                        (value) => widget.prefs.setBool("askBeforeDeletion", value),
                      ),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsShowTips,
                        widget.prefs.getBool("tips") ?? true,
                        (value) => widget.prefs.setBool("tips", value),
                      ),
                      titleDivider(context: context),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsKeepModelLoadedAlways,
                        int.parse(widget.prefs.getString("keepAlive") ?? "300") == -1,
                        (value) => widget.prefs.setString("keepAlive", value ? "-1" : "300"),
                      ),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsKeepModelLoadedNever,
                        int.parse(widget.prefs.getString("keepAlive") ?? "300") == 0,
                        (value) => widget.prefs.setString("keepAlive", value ? "0" : "300"),
                      ),
                      _buildKeepModelLoadedButton(context),
                      titleDivider(context: context),
                      _buildTimeoutMultiplierSlider(context),
                      _buildTimeoutMultiplierExample(context),
                      titleDivider(context: context),
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsEnableHapticFeedback,
                        widget.prefs.getBool("enableHaptic") ?? true,
                        (value) => widget.prefs.setBool("enableHaptic", value),
                      ),
                      if (isDesktopPlatform())
                        _buildToggle(
                          context,
                          AppLocalizations.of(context)!.settingsMaximizeOnStart,
                          widget.prefs.getBool("maximizeOnStart") ?? false,
                          (value) => widget.prefs.setBool("maximizeOnStart", value),
                        ),
                      const SizedBox(height: 8),
                      _buildBrightnessSegmentedButton(context),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isDesktopLayoutNotRequired(context) ? 16 : 8,
                      ),
                      if (colorSchemeLight != null && colorSchemeDark != null)
                        _buildThemeSegmentedButton(context),
                      titleDivider(),
                      _buildTemporaryFixesButton(context),
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

  Widget _buildToggle(
    BuildContext context,
    String text,
    bool value,
    Function(bool) onChanged,
  ) {
    return widgetToggle(
      context,
      text,
      value,
      (value) {
        selectionHaptic();
        onChanged(value);
        setState(() {});
      },
    );
  }

  Widget _buildRequestTypeSegmentedButton(BuildContext context) {
    return SegmentedButton(
      segments: [
        ButtonSegment(
          value: "stream",
          label: Text(AppLocalizations.of(context)!.settingsRequestTypeStream),
          icon: const Icon(Icons.stream_rounded),
        ),
        ButtonSegment(
          value: "request",
          label: Text(AppLocalizations.of(context)!.settingsRequestTypeRequest),
          icon: const Icon(Icons.send_rounded),
        ),
      ],
      selected: {widget.prefs.getString("requestType") ?? "stream"},
      onSelectionChanged: (p0) {
        selectionHaptic();
        setState(() {
          widget.prefs.setString("requestType", p0.elementAt(0));
        });
      },
    );
  }

  Widget _buildKeepModelLoadedButton(BuildContext context) {
    return widgetButton(
      int.parse(widget.prefs.getString("keepAlive") ?? "300") > 0
          ? AppLocalizations.of(context)!.settingsKeepModelLoadedSet((int.parse(widget.prefs.getString("keepAlive") ?? "300") ~/ 60).toString())
          : AppLocalizations.of(context)!.settingsKeepModelLoadedFor,
      Icons.snooze_rounded,
      () async {
        selectionHaptic();
        resetSystemNavigation(
          context,
          systemNavigationBarColor: Color.alphaBlend(Colors.black54, Theme.of(context).colorScheme.surface),
        );
        await showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              alignment: shouldUseDesktopLayout(context) ? null : Alignment.bottomRight,
              child: _buildKeepModelLoadedDialog(context),
            );
          },
        );
        // ignore: use_build_context_synchronously
        resetSystemNavigation(context);
      },
    );
  }

  Widget _buildKeepModelLoadedDialog(BuildContext context) {
    bool loaded = false;
    return StatefulBuilder(
      builder: (context, setLocalState) {
        if (int.parse(widget.prefs.getString("keepAlive") ?? "0") <= 0 && !loaded) {
          widget.prefs.setString("keepAlive", "0");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setLocalState(() {});
            _incrementKeepAlive(setLocalState);
          });
        } else {
          loaded = true;
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Theme(
            data: (widget.prefs.getBool("useDeviceTheme") ?? false)
                ? Theme.of(context)
                : ThemeData.from(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, brightness: Theme.of(context).colorScheme.brightness),
                  ),
            child: DurationPicker(
              duration: Duration(seconds: int.parse(widget.prefs.getString("keepAlive") ?? "300")),
              baseUnit: BaseUnit.minute,
              lowerBound: const Duration(minutes: 1),
              upperBound: const Duration(minutes: 60),
              onChange: (value) {
                if (!loaded) return;
                if (value.inSeconds == 0) return;
                widget.prefs.setString("keepAlive", value.inSeconds.toString());
                setLocalState(() {});
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _incrementKeepAlive(void Function(void Function()) setLocalState) async {
    try {
      while (int.parse(widget.prefs.getString("keepAlive")!) < 300) {
        await Future.delayed(const Duration(milliseconds: 5));
        widget.prefs.setString("keepAlive", (int.parse(widget.prefs.getString("keepAlive")!) + 30).toString());
        setLocalState(() {});
        setState(() {});
      }
      widget.prefs.setString("keepAlive", "300");
    } catch (_) {
      widget.prefs.setString("keepAlive", "300");
    }
  }

  Widget _buildTimeoutMultiplierSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetButton(
          AppLocalizations.of(context)!.settingsTimeoutMultiplier,
          Icons.info_rounded,
          null,
          iconAfterwards: true,
          context: context,
          alwaysMobileDescription: true,
          description: "\n${AppLocalizations.of(context)!.settingsTimeoutMultiplierDescription}",
        ),
        Slider(
          value: (widget.prefs.getDouble("timeoutMultiplier") ?? 1),
          min: 0.5,
          divisions: 19,
          max: 10,
          label: (widget.prefs.getDouble("timeoutMultiplier") ?? 1).toString().removeSuffix(".0"),
          onChanged: (value) {
            selectionHaptic();
            widget.prefs.setDouble("timeoutMultiplier", value);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildTimeoutMultiplierExample(BuildContext context) {
    final multiplier = widget.prefs.getDouble("timeoutMultiplier") ?? 1;
    final formattedMultiplier = multiplier == 10 ? "${multiplier.round()}." : multiplier.toString().padRight(3, "0");
    final totalSeconds = (multiplier * 30).round();
    return widgetButton(
      AppLocalizations.of(context)!.settingsTimeoutMultiplierExample,
      Icons.calculate_rounded,
      null,
      onlyDesktopDescription: false,
      description: "\n$formattedMultiplier x 30s = ${totalSeconds}s ${_formatDuration(multiplier * 30)}",
    );
  }

  Widget _buildBrightnessSegmentedButton(BuildContext context) {
    return SegmentedButton(
      segments: [
        ButtonSegment(
          value: "dark",
          label: Text(AppLocalizations.of(context)!.settingsBrightnessDark),
          icon: const Icon(Icons.brightness_4_rounded),
        ),
        ButtonSegment(
          value: "system",
          label: Text(AppLocalizations.of(context)!.settingsBrightnessSystem),
          icon: const Icon(Icons.brightness_auto_rounded),
        ),
        ButtonSegment(
          value: "light",
          label: Text(AppLocalizations.of(context)!.settingsBrightnessLight),
          icon: const Icon(Icons.brightness_high_rounded),
        ),
      ],
      selected: {widget.prefs.getString("brightness") ?? "system"},
      onSelectionChanged: (p0) async {
        selectionHaptic();
        await widget.prefs.setString("brightness", p0.elementAt(0));
        widget.setMainAppState?.call(() {});
        setState(() {});
      },
    );
  }

  Widget _buildThemeSegmentedButton(BuildContext context) {
    return SegmentedButton(
      segments: [
        ButtonSegment(
          value: "device",
          label: Text(AppLocalizations.of(context)!.settingsThemeDevice),
          icon: const Icon(Icons.devices_rounded),
        ),
        ButtonSegment(
          value: "ollama",
          label: Text(AppLocalizations.of(context)!.settingsThemeOllama),
          icon: const ImageIcon(AssetImage("assets/logo512.png")),
        ),
      ],
      selected: {(widget.prefs.getBool("useDeviceTheme") ?? false) ? "device" : "ollama"},
      onSelectionChanged: (p0) async {
        selectionHaptic();
        await widget.prefs.setBool("useDeviceTheme", p0.elementAt(0) == "device");
        widget.setMainAppState?.call(() {});
        setState(() {});
      },
    );
  }

  Widget _buildTemporaryFixesButton(BuildContext context) {
    return widgetButton(
      AppLocalizations.of(context)!.settingsTemporaryFixes,
      Icons.fast_forward_rounded,
      () {
        selectionHaptic();
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: shouldUseDesktopLayout(context) ? 16 : 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widgetButton(
                        AppLocalizations.of(context)!.settingsTemporaryFixesDescription,
                        Icons.info_rounded,
                        null,
                        color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary),
                      ),
                      widgetButton(
                        AppLocalizations.of(context)!.settingsTemporaryFixesInstructions,
                        Icons.warning_rounded,
                        null,
                        color: Colors.orange.harmonizeWith(Theme.of(context).colorScheme.primary),
                      ),
                      titleDivider(),
                      _buildToggle(
                        context,
                        "Fixing code block not scrollable",
                        widget.prefs.getBool("fixCodeblockScroll") ?? false,
                        (value) {
                          widget.prefs.setBool("fixCodeblockScroll", value);
                          if (!(widget.prefs.getBool("fixCodeblockScroll") ?? false)) {
                            widget.prefs.remove("fixCodeblockScroll");
                          }
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}