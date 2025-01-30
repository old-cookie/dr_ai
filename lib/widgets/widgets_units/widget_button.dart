import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../worker/desktop.dart';
import '../../worker/haptic.dart';

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
            var iconContent = (icon != null || replaceIconIfNull)
                ? replaceIconIfNull
                    ? ImageIcon(MemoryImage(kTransparentImage))
                    : Icon(icon, color: disabled || (iconAfterwards ?? false) ? Colors.grey : color)
                : const SizedBox.shrink();

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                Expanded(
                  child: Builder(
                    builder: (context) {
                      Widget textWidget = Text(
                        text,
                        style: TextStyle(color: disabled ? Colors.grey : color),
                      );

                      if (badge != null) {
                        textWidget = Badge(
                          label: Text(badge),
                          offset: const Offset(20, -4),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          child: textWidget,
                        );
                      }

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
                              if (description != null &&
                                  !alwaysMobileDescription &&
                                  (isDesktopLayoutNotRequired(context) || !onlyDesktopDescription))
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
                              if (description != null &&
                                  !alwaysMobileDescription &&
                                  (isDesktopLayoutNotRequired(context) || !onlyDesktopDescription))
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