import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dartx/dartx.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import '../../../services/service_haptic.dart';
import '../../../services/service_desktop.dart';
import '../../../services/service_theme.dart';
import '../../../services/ocr_service.dart';
import '../../widgets_units/widget_toggle.dart';
import '../../widgets_units/widget_title.dart';
import '../../widgets_units/widget_button.dart';

/// 介面設置組件
/// 用於配置應用程序的外觀和行為設置
class WidgetInterface extends StatefulWidget {
  /// 本地儲存實例
  final EncryptedSharedPreferences prefs;

  /// 主應用狀態更新函數
  final Function? setMainAppState;
  const WidgetInterface({
    super.key,
    required this.prefs,
    this.setMainAppState,
  });
  @override
  State<WidgetInterface> createState() => _WidgetInterfaceState();
}

/// 格式化持續時間
/// 將秒數轉換為分鐘和秒的格式
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
  void initState() {
    super.initState();
    
    final isDemoModeEnabled = widget.prefs.getBool("demoModeEnabled") ?? false;
    OcrService.toggleDemoMode(enable: isDemoModeEnabled);
  }

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
                      /// 模型標籤顯示設置
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsShowModelTags,
                        widget.prefs.getBool("modelTags") ?? false,
                        (value) => widget.prefs.setBool("modelTags", value),
                      ),

                      /// 模型預加載設置
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsPreloadModels,
                        widget.prefs.getBool("preloadModel") ?? true,
                        (value) => widget.prefs.setBool("preloadModel", value),
                      ),

                      /// 模型切換重置設置
                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsResetOnModelChange,
                        widget.prefs.getBool("resetOnModelSelect") ?? true,
                        (value) => widget.prefs.setBool("resetOnModelSelect", value),
                      ),
                      titleDivider(bottom: isDesktopLayoutNotRequired(context) ? 38 : 20, context: context),

                      /// 請求類型選擇器
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
                      if (colorSchemeLight != null && colorSchemeDark != null) _buildThemeSegmentedButton(context),
                      titleDivider(),
                      _buildTemporaryFixesButton(context),
                      const SizedBox(height: 16),
                      titleDivider(context: context),

                      _buildToggle(
                        context,
                        AppLocalizations.of(context)!.settingsDemoModeEnable,
                        widget.prefs.getBool("demoModeEnabled") ?? false,
                        (value) {
                           widget.prefs.setBool("demoModeEnabled", value);
                           OcrService.toggleDemoMode(enable: value);
                        },
                      ),

                      widgetButton(
                        AppLocalizations.of(context)!.settingsDemoModeInfo,
                        Icons.info_outline,
                        () {
                          selectionHaptic();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.settingsDemoModeTitle),
                              content: Text(AppLocalizations.of(context)!.settingsDemoModeDescription),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(AppLocalizations.of(context)!.buttonGotIt),
                                ),
                              ],
                            ),
                          );
                        },
                        //icon: Icons.help_outline,
                      ),
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

  /// 構建開關組件
  /// @param context 上下文
  /// @param text 顯示文字
  /// @param value 當前值
  /// @param onChanged 值變更回調
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

  /// 構建請求類型選擇器
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

  /// 構建模型保持載入設置按鈕
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
        resetSystemNavigation(context);
      },
    );
  }

  /// 構建模型保持載入時間選擇對話框
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

  /// 增加模型保持載入時間
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

  /// 構建超時時間倍數滑塊
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

  /// 構建超時時間倍數示例
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

  /// 構建亮度模式選擇器
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

  /// 構建主題選擇器
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

  /// 構建臨時修復選項按鈕
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
