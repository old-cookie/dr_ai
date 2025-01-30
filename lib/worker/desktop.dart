import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/widgets_workers/widget_desktop.dart';

bool isDesktopPlatform({bool includeWeb = false}) {
  try {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS || (includeWeb && kIsWeb);
  } catch (_) {
    return includeWeb && kIsWeb;
  }
}

bool shouldUseDesktopLayout(BuildContext context, {bool includeWeb = true, double? screenWidth, double widthThreshold = 1000}) {
  screenWidth ??= MediaQuery.of(context).size.width;
  return isDesktopPlatform(includeWeb: includeWeb) || screenWidth >= widthThreshold;
}

bool isDesktopLayoutRequired(BuildContext context, {bool includeWeb = true, double? screenWidth, double widthThreshold = 1000}) {
  screenWidth ??= MediaQuery.of(context).size.width;
  return isDesktopPlatform(includeWeb: includeWeb) && screenWidth >= widthThreshold;
}

bool isDesktopLayoutNotRequired(BuildContext context, {bool includeWeb = true, double? screenWidth, double widthThreshold = 1000}) {
  screenWidth ??= MediaQuery.of(context).size.width;
  return screenWidth >= widthThreshold;
}

List<Widget>? getDesktopControlsActions(BuildContext context, [List<Widget>? alternativeActions]) {
  return isDesktopPlatform() ? [widgetDesktop(context)] : alternativeActions;
}