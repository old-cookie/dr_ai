import 'package:flutter/material.dart';
import '../../main.dart';
import '../../worker/haptic.dart';

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
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (icon != null && !(iconAfterwards ?? false))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: icon,
                      ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: constraints.maxWidth - (icon != null ? 32 : 0)),
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: disabled ? Colors.grey : null),
                      ),
                    ),
                    if (icon != null && (iconAfterwards ?? false))
                      Transform.translate(
                        offset: const Offset(0, 1),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: icon,
                        ),
                      ),
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