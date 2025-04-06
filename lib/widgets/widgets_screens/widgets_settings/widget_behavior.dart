import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/service_haptic.dart';
import '../../../services/service_desktop.dart';
import '../../widgets_units/widget_toggle.dart';
import '../../widgets_units/widget_button.dart';

/// 行為設置組件
/// 用於配置系統提示詞和 Markdown 相關選項的界面元素
class WidgetBehavior extends StatelessWidget {
  /// 系統提示詞輸入控制器
  final TextEditingController systemInputController;

  /// 是否使用系統提示詞
  final bool useSystem;

  /// 是否禁用 Markdown
  final bool noMarkdown;

  /// 是否使用 OpenAI API
  final bool useOpenAI;

  /// 系統提示詞開關變更回調
  final Function(bool) onUseSystemChanged;

  /// Markdown 開關變更回調
  final Function(bool) onNoMarkdownChanged;

  /// API 提供者切換回調
  final Function(bool) onUseOpenAIChanged;

  /// 保存系統提示詞回調
  final Function() onSystemMessageSaved;

  /// 選擇模型回調
  final Function() onModelSelected;

  /// 當前選擇的模型
  final String model;

  /// 連接錯誤信息
  final String? connectionError;

  const WidgetBehavior({
    super.key,
    required this.systemInputController,
    required this.useSystem,
    required this.noMarkdown,
    required this.useOpenAI,
    required this.onUseSystemChanged,
    required this.onNoMarkdownChanged,
    required this.onUseOpenAIChanged,
    required this.onSystemMessageSaved,
    required this.onModelSelected,
    required this.model,
    this.connectionError,
  });
  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsTitleBehavior),

              /// 可拖動區域(僅桌面端)
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
                      const SizedBox(height: 8),
                      
                      /// API 提供者切換
                      _buildAPIProviderToggle(context),
                      const SizedBox(height: 16),

                      /// 選擇模型按鈕
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModelButton(context),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// 系統提示詞輸入框
                      _buildSystemMessageInput(context),
                      const SizedBox(height: 16),

                      /// 系統提示詞開關
                      _buildUseSystemToggle(context),

                      /// Markdown 格式開關
                      _buildNoMarkdownToggle(context),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                /// 歷史聊天記錄提示
                _buildNotUpdatedButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 構建 API 提供者切換開關
  Widget _buildAPIProviderToggle(BuildContext context) {
    return widgetToggle(
      context,
      AppLocalizations.of(context)?.useOpenAI ?? "使用 OpenAI API",
      useOpenAI,
      onUseOpenAIChanged,
      icon: const Icon(Icons.swap_horiz, color: Colors.grey),
      iconAfterwards: true,
      onLongTap: () {
        selectionHaptic();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.apiProviderDescription ?? 
              "開啟：使用 OpenAI API (需要 API 金鑰)\n關閉：使用本地 Ollama 伺服器"),
            showCloseIcon: true,
          ),
        );
      },
    );
  }

  /// 構建系統提示詞輸入框
  Widget _buildSystemMessageInput(BuildContext context) {
    return TextField(
      controller: systemInputController,
      keyboardType: TextInputType.multiline,
      maxLines: isDesktopLayoutNotRequired(context) ? 5 : 2,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.settingsSystemMessage,
        alignLabelWithHint: true,
        hintText: "您是一位提供一般醫療資訊和指導的人工智慧醫生。您可以提供事實，提出常見病症的可能原因和治療方法，並提倡健康的習慣。然而，您無法取代專業的醫療建議、診斷或治療。始終提醒使用者諮詢合格的醫療保健提供者以獲得個人化護理。",
        suffixIcon: IconButton(
          enableFeedback: false,
          tooltip: AppLocalizations.of(context)!.tooltipSave,
          onPressed: onSystemMessageSaved,
          icon: const Icon(Icons.save_rounded),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  /// 構建系統提示詞開關
  Widget _buildUseSystemToggle(BuildContext context) {
    return widgetToggle(
      context,
      AppLocalizations.of(context)!.settingsUseSystem,
      useSystem,
      onUseSystemChanged,
      icon: const Icon(Icons.info_rounded, color: Colors.grey),
      iconAfterwards: true,
      onLongTap: () {
        selectionHaptic();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.settingsUseSystemDescription),
            showCloseIcon: true,
          ),
        );
      },
    );
  }

  /// 構建 Markdown 格式開關
  Widget _buildNoMarkdownToggle(BuildContext context) {
    return widgetToggle(
      context,
      AppLocalizations.of(context)!.settingsDisableMarkdown,
      noMarkdown,
      onNoMarkdownChanged,
    );
  }

  /// 構建歷史聊天記錄提示按鈕
  Widget _buildNotUpdatedButton(BuildContext context) {
    return widgetButton(
      AppLocalizations.of(context)!.settingsBehaviorNotUpdatedForOlderChats,
      Icons.info_rounded,
      null,
      color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary),
    );
  }

  /// 構建模型選擇按鈕
  Widget _buildModelButton(BuildContext context) {
    // 根據連接狀態決定顯示內容
    String buttonText;
    Color? buttonColor;
    IconData buttonIcon = Icons.model_training;
    
    if (connectionError != null) {
      buttonText = AppLocalizations.of(context)?.serverConnectionError ?? "連接錯誤";
      buttonColor = Colors.red.harmonizeWith(Theme.of(context).colorScheme.primary);
      buttonIcon = Icons.error_outline;
    } else if (model.isNotEmpty) {
      buttonText = model;
      buttonColor = null;
    } else {
      buttonText = AppLocalizations.of(context)!.dialogSelectModel;
      buttonColor = null;
    }
    
    return widgetButton(
      buttonText,
      buttonIcon,
      onModelSelected,
      color: buttonColor,
    );
  }
}
