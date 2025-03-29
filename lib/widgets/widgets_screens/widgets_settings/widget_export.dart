import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../../../services/service_desktop.dart';
import '../../widgets_units/widget_button.dart';

/// 匯出設置組件
/// 用於提供所有偏好設置的匯出和匯入功能界面
class WidgetExport extends StatelessWidget {
  /// 匯出偏好設置的回調函數
  final Future<void> Function(BuildContext) exportChats;

  /// 匯入偏好設置的回調函數
  final Future<void> Function(BuildContext) importChats;
  const WidgetExport({
    super.key,
    required this.exportChats,
    required this.importChats,
  });
  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsTitleExport),

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
                      /// 匯出偏好設置按鈕
                      widgetButton(
                        '導出所有設置',
                        Icons.upload_rounded,
                        () => exportChats(context),
                      ),

                      /// 匯入偏好設置按鈕
                      widgetButton(
                        '導入所有設置',
                        Icons.download_rounded,
                        () => importChats(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                /// 匯出功能信息提示
                widgetButton(
                  '導出將保存所有應用設置和聊天記錄（JSON格式）',
                  Icons.info_rounded,
                  null,
                  color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary),
                ),

                /// 匯出警告提示
                widgetButton(
                  '導入設置將覆蓋現有所有設置，請謹慎操作',
                  Icons.warning_rounded,
                  null,
                  color: Colors.orange.harmonizeWith(Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
