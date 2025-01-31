import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

/// 構建桌面端窗口控制按鈕組件
/// 包括最小化、最大化和關閉按鈕
Widget widgetDesktop(BuildContext context) {
  return SizedBox(
    height: 200,
    child: WindowTitleBarBox(
      child: Row(
        children: [
          /// 最小化按鈕
          _buildWindowButton(
            context,
            width: 46,
            height: 200,
            button: MinimizeWindowButton(
              animate: true,
              colors: WindowButtonColors(iconNormal: Theme.of(context).colorScheme.primary),
            ),
          ),

          /// 最大化按鈕
          _buildWindowButton(
            context,
            width: 46,
            height: 72,
            button: MaximizeWindowButton(
              animate: true,
              colors: WindowButtonColors(iconNormal: Theme.of(context).colorScheme.primary),
            ),
          ),

          /// 關閉按鈕
          _buildWindowButton(
            context,
            width: 46,
            height: 72,
            button: CloseWindowButton(
              animate: true,
              colors: WindowButtonColors(iconNormal: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 構建單個窗口控制按鈕
/// @param context 上下文
/// @param width 按鈕寬度
/// @param height 按鈕高度
/// @param button 按鈕組件
Widget _buildWindowButton(BuildContext context, {required double width, required double height, required Widget button}) {
  return SizedBox(
    width: width,
    height: height,
    child: button,
  );
}
