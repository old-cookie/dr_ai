import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/widgets_workers/widget_desktop.dart';
//import 'package:bitsdojo_window/bitsdojo_window.dart';

// 檢查是否為桌面平台（Windows、Linux、MacOS）或 Web 平台
bool desktopFeature({bool web = false}) {
  try {
    return (Platform.isWindows || Platform.isLinux || Platform.isMacOS || (web ? kIsWeb : false));
  } catch (_) {
    return web ? kIsWeb : false;
  }
}

// 檢查是否需要使用桌面佈局
bool desktopLayout(BuildContext context, {bool web = true, double? value, double valueCap = 1000}) {
  value ??= MediaQuery.of(context).size.width;
  return (desktopFeature(web: web) || value >= valueCap);
}

// 檢查是否需要強制使用桌面佈局
bool desktopLayoutRequired(BuildContext context, {bool web = true, double? value, double valueCap = 1000}) {
  value ??= MediaQuery.of(context).size.width;
  return (desktopFeature(web: web) && value >= valueCap);
}

// 檢查是否不需要使用桌面佈局
bool desktopLayoutNotRequired(BuildContext context, {bool web = true, double? value, double valueCap = 1000}) {
  value ??= MediaQuery.of(context).size.width;
  return (value >= valueCap);
}

// 根據 desktopFeature 的結果返回不同的 Widget 列表
List<Widget>? desktopControlsActions(BuildContext context, [List<Widget>? ifNotAvailable]) {
  // 如果 desktopFeature 為 true，返回包含 desktopControls 的 Widget 列表
  // 否則返回 ifNotAvailable
  return desktopFeature() ? <Widget>[widgetDesktop(context)] : ifNotAvailable;
}
