import 'package:flutter/material.dart';
import '../../worker/desktop.dart';

Widget widgetTitle(String text, {double top = 16, double bottom = 16}) {
  return Padding(
    padding: EdgeInsets.only(left: 8, right: 8, top: top, bottom: bottom),
    child: Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Text(text),
        ),
        const Expanded(child: Divider()),
      ],
    ),
  );
}

Widget titleDivider({double? top, double? bottom, BuildContext? context}) {
  top ??= (context != null && isDesktopLayoutNotRequired(context)) ? 32 : 16;
  bottom ??= (context != null && isDesktopLayoutNotRequired(context)) ? 32 : 16;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: EdgeInsets.only(left: 8, right: 8, top: top, bottom: bottom),
    child: const Row(
      mainAxisSize: MainAxisSize.max,
      children: [Expanded(child: Divider())],
    ),
  );
}

Widget verticalTitleDivider({double? left, double? right, BuildContext? context}) {
  left ??= (context != null && isDesktopLayoutNotRequired(context)) ? 32 : 16;
  right ??= (context != null && isDesktopLayoutNotRequired(context)) ? 32 : 16;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: EdgeInsets.only(left: left, right: right, top: 8, bottom: 8),
    child: const Row(
      mainAxisSize: MainAxisSize.max,
      children: [VerticalDivider(width: 1)],
    ),
  );
}