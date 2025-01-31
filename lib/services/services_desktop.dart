import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/widgets_workers/widget_desktop.dart';

/// 提供桌面平台相關的判斷和功能支援
/// 包含平台檢測、布局判斷和桌面控制項處理

/// 判斷當前是否為桌面平台
/// [includeWeb] - 是否將網頁平台視為桌面平台
bool isDesktopPlatform({bool includeWeb = false}) {
  try {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS || (includeWeb && kIsWeb);
  } catch (_) {
    return includeWeb && kIsWeb;
  }
}

/// 根據平台和螢幕寬度判斷是否應使用桌面布局
/// [includeWeb] - 是否將網頁平台納入考慮
/// [screenWidth] - 指定的螢幕寬度，若為null則自動獲取
/// [widthThreshold] - 觸發桌面布局的寬度閾值
bool shouldUseDesktopLayout(BuildContext context, {bool includeWeb = true, double? screenWidth, double widthThreshold = 1000}) {
  screenWidth ??= MediaQuery.of(context).size.width;
  return isDesktopPlatform(includeWeb: includeWeb) || screenWidth >= widthThreshold;
}

/// 判斷是否必須使用桌面布局
/// 當平台為桌面且寬度達到閾值時返回true
bool isDesktopLayoutRequired(BuildContext context, {bool includeWeb = true, double? screenWidth, double widthThreshold = 1000}) {
  screenWidth ??= MediaQuery.of(context).size.width;
  return isDesktopPlatform(includeWeb: includeWeb) && screenWidth >= widthThreshold;
}

/// 判斷是否不需要使用桌面布局
/// 僅根據寬度判斷，不考慮平台因素
bool isDesktopLayoutNotRequired(BuildContext context, {bool includeWeb = true, double? screenWidth, double widthThreshold = 1000}) {
  screenWidth ??= MediaQuery.of(context).size.width;
  return screenWidth >= widthThreshold;
}

/// 獲取桌面控制項操作列表
/// [alternativeActions] - 非桌面平台時的替代操作列表
List<Widget>? getDesktopControlsActions(BuildContext context, [List<Widget>? alternativeActions]) {
  return isDesktopPlatform() ? [widgetDesktop(context)] : alternativeActions;
}
