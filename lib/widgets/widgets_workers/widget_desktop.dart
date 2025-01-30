import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

Widget widgetDesktop(BuildContext context) {
  return SizedBox(
    height: 200,
    child: WindowTitleBarBox(
      child: Row(
        children: [
          _buildWindowButton(
            context,
            width: 46,
            height: 200,
            button: MinimizeWindowButton(
              animate: true,
              colors: WindowButtonColors(iconNormal: Theme.of(context).colorScheme.primary),
            ),
          ),
          _buildWindowButton(
            context,
            width: 46,
            height: 72,
            button: MaximizeWindowButton(
              animate: true,
              colors: WindowButtonColors(iconNormal: Theme.of(context).colorScheme.primary),
            ),
          ),
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

Widget _buildWindowButton(BuildContext context, {required double width, required double height, required Widget button}) {
  return SizedBox(
    width: width,
    height: height,
    child: button,
  );
}