import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/haptic.dart';

/// 開關按鈕組件
/// 用於創建帶有文字說明和開關按鈕的可配置組件
/// @param context 上下文
/// @param text 顯示文字
/// @param value 開關狀態
/// @param onChanged 狀態變更回調
/// @param disabled 是否禁用
/// @param onDisabledTap 禁用狀態點擊回調
/// @param onLongTap 長按回調
/// @param onDoubleTap 雙擊回調
/// @param icon 圖標組件
/// @param iconAfterwards 圖標是否在文字後
Widget widgetToggle(
  BuildContext context,
  String text,
  bool value,
  Function(bool value) onChanged, {
  bool disabled = false,
  void Function()? onDisabledTap,
  void Function()? onLongTap,
  void Function()? onDoubleTap,
  Widget? icon,
  bool? iconAfterwards,
}) {
  return InkWell(
    enableFeedback: false,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,

    /// 處理點擊事件
    onTap: () {
      if (disabled) {
        selectionHaptic();
        onDisabledTap?.call();
      } else {
        onChanged(!value);
      }
    },
    onLongPress: onLongTap,
    onDoubleTap: onDoubleTap,
    child: Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: [
          /// 文字和圖標區域
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    /// 前置圖標
                    if (icon != null && !(iconAfterwards ?? false))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: icon,
                      ),

                    /// 文字內容
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth - (icon != null ? 32 : 0)),
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: disabled ? Colors.grey : null),
                      ),
                    ),

                    /// 後置圖標
                    if (icon != null && (iconAfterwards ?? false))
                      Transform.translate(
                        offset: const Offset(0, 1),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: icon,
                        ),
                      ),

                    /// 分隔線
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Divider(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          /// 開關按鈕
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Switch(
              value: value,
              onChanged: disabled
                  ? (onDisabledTap != null)
                      ? (p0) {
                          selectionHaptic();
                          onDisabledTap();
                        }
                      : null
                  : onChanged,

              /// 自定義開關樣式
              activeTrackColor: disabled ? Theme.of(context).colorScheme.primary.withAlpha(50) : null,
              trackOutlineColor: disabled ? WidgetStatePropertyAll(Theme.of(context).colorScheme.primary.withAlpha(150)) : null,
              thumbColor: disabled
                  ? WidgetStatePropertyAll(Theme.of(context).colorScheme.primary.withAlpha(150))
                  : !(prefs?.getBool("useDeviceTheme") ?? false) && value
                      ? WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary)
                      : null,
            ),
          ),
        ],
      ),
    ),
  );
}
