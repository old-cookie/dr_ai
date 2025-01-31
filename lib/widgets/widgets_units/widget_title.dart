import 'package:flutter/material.dart';
import '../../services/service_desktop.dart';

/// 創建帶有文字的分隔線標題
/// @param text 標題文字
/// @param top 頂部間距
/// @param bottom 底部間距
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

/// 創建水平分隔線
/// @param top 頂部間距
/// @param bottom 底部間距
/// @param context 用於判斷佈局類型的上下文
Widget titleDivider({double? top, double? bottom, BuildContext? context}) {
  // 根據佈局類型設置默認間距
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

/// 創建垂直分隔線
/// @param left 左側間距
/// @param right 右側間距
/// @param context 用於判斷佈局類型的上下文
Widget verticalTitleDivider({double? left, double? right, BuildContext? context}) {
  // 根據佈局類型設置默認間距
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
