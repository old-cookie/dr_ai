import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import '../../services/services_desktop.dart';
import '../../services/services_haptic.dart';

/// 自定義按鈕組件
/// 可配置的通用按鈕組件，支持圖標、描述文字、徽章等功能
/// @param text 按鈕文字
/// @param icon 按鈕圖標
/// @param onPressed 點擊回調
/// @param context 上下文
/// @param color 按鈕顏色
/// @param disabled 是否禁用
/// @param replaceIconIfNull 無圖標時是否使用佔位圖標
/// @param description 描述文字
/// @param onlyDesktopDescription 是否僅在桌面端顯示描述
/// @param alwaysMobileDescription 是否在移動端始終顯示描述
/// @param badge 按鈕徽章
/// @param iconBadge 圖標徽章
/// @param iconAfterwards 圖標是否在文字後
/// @param onDisabledTap 禁用狀態點擊回調
/// @param onLongTap 長按回調
/// @param onDoubleTap 雙擊回調
Widget widgetButton(
  String text,
  IconData? icon,
  void Function()? onPressed, {
  BuildContext? context,
  Color? color,
  bool disabled = false,
  bool replaceIconIfNull = false,
  String? description,
  bool onlyDesktopDescription = true,
  bool alwaysMobileDescription = false,
  String? badge,
  String? iconBadge,
  bool? iconAfterwards,
  void Function()? onDisabledTap,
  void Function()? onLongTap,
  void Function()? onDoubleTap,
}) {
  /// 處理描述文字格式
  if (description != null &&
      ((context != null && isDesktopLayoutNotRequired(context)) || !onlyDesktopDescription) &&
      !alwaysMobileDescription &&
      !description.startsWith("\n")) {
    description = " • $description";
  }
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: (context != null && isDesktopLayoutNotRequired(context)) ? const EdgeInsets.only(top: 8, bottom: 8) : EdgeInsets.zero,
    child: InkWell(
      enableFeedback: false,
      splashFactory: (onPressed == null) ? NoSplash.splashFactory : null,
      highlightColor: (onPressed == null) ? Colors.transparent : null,
      hoverColor: (onPressed == null) ? Colors.transparent : null,

      /// 處理各種點擊事件
      onTap: disabled
          ? () {
              selectionHaptic();
              onDisabledTap?.call();
            }
          : (onPressed == null && (onLongTap != null || onDoubleTap != null))
              ? () => selectionHaptic()
              : onPressed,
      onLongPress: (description != null && context != null)
          ? (isDesktopLayoutNotRequired(context) && !alwaysMobileDescription) || !onlyDesktopDescription
              ? null
              : () {
                  selectionHaptic();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(description!.trim()), showCloseIcon: true));
                }
          : onLongTap,
      onDoubleTap: onDoubleTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Builder(
          builder: (context) {
            /// 構建圖標部分
            var iconContent = (icon != null || replaceIconIfNull)
                ? replaceIconIfNull
                    ? ImageIcon(MemoryImage(kTransparentImage))
                    : Icon(icon, color: disabled || (iconAfterwards ?? false) ? Colors.grey : color)
                : const SizedBox.shrink();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 根據配置放置圖標
                if (!(iconAfterwards ?? false))
                  iconBadge == null
                      ? iconContent
                      : Badge(
                          label: (iconBadge != "") ? Text(iconBadge) : null,
                          child: iconContent,
                        ),
                if (icon != null || replaceIconIfNull)
                  SizedBox(
                    width: !(iconAfterwards ?? false) ? 16 : null,
                    height: 42,
                  ),

                /// 構建文字和描述部分
                Expanded(
                  child: Builder(
                    builder: (context) {
                      /// 構建文字組件
                      Widget textWidget = Text(
                        text,
                        style: TextStyle(color: disabled ? Colors.grey : color),
                      );

                      /// 添加徽章(如果需要)
                      if (badge != null) {
                        textWidget = Badge(
                          label: Text(badge),
                          offset: const Offset(20, -4),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          child: textWidget,
                        );
                      }

                      /// 根據圖標位置和描述文字構建最終佈局
                      if (iconAfterwards ?? false) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            textWidget,
                            const SizedBox(width: 8),
                            Transform.translate(
                              offset: const Offset(0, 1),
                              child: iconBadge == null
                                  ? iconContent
                                  : Badge(
                                      label: (iconBadge != "") ? Text(iconBadge) : null,
                                      child: iconContent,
                                    ),
                            ),
                          ],
                        );
                      } else {
                        if (description == null || description?.startsWith("\n") == true) {
                          description = description?.replaceFirst("\n", "");
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              textWidget,
                              if (description != null && !alwaysMobileDescription && (isDesktopLayoutNotRequired(context) || !onlyDesktopDescription))
                                Text(
                                  description ?? '',
                                  style: const TextStyle(color: Colors.grey, overflow: TextOverflow.ellipsis),
                                ),
                            ],
                          );
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              textWidget,
                              if (description != null && !alwaysMobileDescription && (isDesktopLayoutNotRequired(context) || !onlyDesktopDescription))
                                Expanded(
                                  child: Text(
                                    description ?? '',
                                    style: const TextStyle(color: Colors.grey, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                            ],
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
