import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets_units/widget_title.dart';
import '../widgets_units/widget_button.dart';
import '../../services/service_haptic.dart';
import '../../services/service_setter.dart';
import '../../screens/settings/settings_behavior.dart';
import '../../screens/settings/settings_interface.dart';
import '../../screens/settings/settings_voice.dart';
import '../../screens/settings/settings_export.dart';
import '../../screens/settings/settings_about.dart';
import '../../services/service_desktop.dart';

/// 設置頁面組件
/// 用於顯示和管理應用程序的各項設置
/// 包含主機設置、行為設置、界面設置、語音設置、導出和關於等功能
class WidgetScreenSettings extends StatefulWidget {
  /// 主機地址輸入控制器
  final TextEditingController hostInputController;

  /// 主機檢查載入狀態
  final bool hostLoading;

  /// URL 格式是否無效
  final bool hostInvalidUrl;

  /// 主機連接是否失敗
  final bool hostInvalidHost;

  /// 檢查主機連接的回調
  final VoidCallback checkHost;

  /// 是否使用固定主機
  final bool useHost;

  /// 本地儲存實例
  final SharedPreferences? prefs;

  /// 構造函數
  /// @param hostInputController 主機地址輸入控制器
  /// @param hostLoading 主機檢查載入狀態標記
  /// @param hostInvalidUrl URL格式是否無效標記
  /// @param hostInvalidHost 主機連接是否失敗標記
  /// @param checkHost 檢查主機連接的回調函數
  /// @param useHost 是否使用固定主機標記
  /// @param prefs 本地儲存實例
  const WidgetScreenSettings({
    super.key,
    required this.hostInputController,
    required this.hostLoading,
    required this.hostInvalidUrl,
    required this.hostInvalidHost,
    required this.checkHost,
    required this.useHost,
    this.prefs,
  });
  @override
  State<WidgetScreenSettings> createState() => _WidgetScreenSettingsState();
}

class _WidgetScreenSettingsState extends State<WidgetScreenSettings> {
  /// 本地儲存實例引用
  SharedPreferences? prefs;

  /// 圖標大小動畫值
  double iconSize = 1;

  /// 動畫初始化標記
  bool animatedInitialized = false;

  /// 桌面佈局動畫標記
  bool animatedDesktop = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  /// 初始化本地儲存實例
  Future<void> _initPrefs() async {
    if (widget.prefs != null) {
      prefs = widget.prefs;
    } else {
      prefs = await SharedPreferences.getInstance();
    }
    setState(() {});
  }

  /// 構建主頁面佈局
  /// 包含頂部欄、主體內容和底部提示
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
                  var column1 = widget.useHost ? const SizedBox.shrink() : buildColumn1(context);
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

  /// 構建左側欄位
  /// 包含主機設置相關內容
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
            hintText: "http://dr_ai.com:11434",
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

  /// 構建右側欄位
  /// 包含各種設置選項按鈕
  /// 包括行為設置、界面設置、語音設置、導出和關於等
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
        //(!isDesktopPlatform(includeWeb: true))
            //?
        buildSettingsButton(
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
            //: const SizedBox.shrink()
        ,
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

  /// 構建桌面端佈局
  /// 左右雙欄佈局
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

  /// 構建移動端佈局
  /// 單欄滾動佈局
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

  /// 構建自動保存提示按鈕
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

  /// 構建設置選項按鈕
  /// @param title 按鈕標題
  /// @param icon 按鈕圖標
  /// @param onPressed 點擊回調
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

  /// 添加主機請求頭
  /// 顯示對話框讓使用者輸入 JSON 格式的請求頭
  Future<void> addHostHeaders() async {
    selectionHaptic();
    if (prefs == null) return;

    String tmp = await prompt(
      context,
      placeholder: "{\"Authorization\": \"Bearer ...\"}",
      title: AppLocalizations.of(context)!.settingsHostHeaderTitle,
      value: (prefs?.getString("hostHeaders") ?? ""),
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
      prefill: !((prefs?.getString("hostHeaders") ?? {}) == "{}"),
    );
    prefs?.setString("hostHeaders", tmp);
  }

  /// 執行圖標動畫效果
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
