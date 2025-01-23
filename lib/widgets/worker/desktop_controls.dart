//import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter/foundation.dart';

import 'package:bitsdojo_window/bitsdojo_window.dart';

Widget desktopControls(BuildContext context) {
  return SizedBox(
      height: 200,
      child: WindowTitleBarBox(
          child: Row(
        children: [
          SizedBox(
              width: 46,
              height: 200,
              child: MinimizeWindowButton(animate: true, colors: WindowButtonColors(iconNormal: Theme.of(context).colorScheme.primary))),
          SizedBox(
              width: 46,
              height: 72,
              child: MaximizeWindowButton(animate: true, colors: WindowButtonColors(iconNormal: Theme.of(context).colorScheme.primary))),
          SizedBox(
              width: 46,
              height: 72,
              child: CloseWindowButton(animate: true, colors: WindowButtonColors(iconNormal: Theme.of(context).colorScheme.primary))),
        ],
      )));
}
