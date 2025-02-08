import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../main.dart';

/// 存儲淺色主題的顏色方案
ColorScheme? colorSchemeLight;

/// 存儲深色主題的顏色方案
ColorScheme? colorSchemeDark;
// 重置系統導航欄顏色
/// 重置系統導航欄和狀態欄的顏色設置
/// @param context 上下文
/// @param color 主要顏色
/// @param statusBarColor 狀態欄顏色
/// @param systemNavigationBarColor 導航欄顏色
/// @param delay 延遲時間
void resetSystemNavigation(BuildContext context, {Color? color, Color? statusBarColor, Color? systemNavigationBarColor, Duration? delay}) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (delay != null) {
      await Future.delayed(delay);
    }
    color ??= themeCurrent(context).colorScheme.surface;
    
    // 檢查顏色是否相等的輔助函數
    bool colorsEqual(Color a, Color b) {
      return a.r == b.r && a.g == b.g && a.b == b.b && a.a == b.a;
    }
    
    Color effectiveStatusColor = (statusBarColor != null) ? statusBarColor : color!;
    bool shouldBeTransparent = !kIsWeb && colorsEqual(effectiveStatusColor, themeCurrent(context).colorScheme.surface);
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: (effectiveStatusColor.computeLuminance() > 0.179) ? Brightness.dark : Brightness.light,
      statusBarColor: shouldBeTransparent ? Colors.transparent : effectiveStatusColor,
      systemNavigationBarColor: (systemNavigationBarColor != null) ? systemNavigationBarColor : color,
    ));
  });
}

// 修改主題
/// 修改預設主題設置
/// @param theme 要修改的主題
ThemeData themeModifier(ThemeData theme) {
  return theme.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    },
  ));
}

// 獲取當前主題
/// 獲取當前使用的主題
/// 根據系統設置或用戶偏好返回對應主題
/// @param context 上下文
ThemeData themeCurrent(BuildContext context) {
  if (themeMode() == ThemeMode.system) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return themeLight();
    } else {
      return themeDark();
    }
  } else {
    if (themeMode() == ThemeMode.light) {
      return themeLight();
    } else {
      return themeDark();
    }
  }
}

// 獲取淺色主題
/// 獲取淺色主題設置
/// 如果未使用設備主題,則返回預設淺色主題
ThemeData themeLight() {
  if (!(prefs?.getBool("useDeviceTheme") ?? false) || colorSchemeLight == null) {
    return themeModifier(ThemeData.from(
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Colors.black,
            onPrimary: Colors.white,
            secondary: Colors.white,
            onSecondary: Colors.black,
            error: Colors.red,
            onError: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black)));
  } else {
    return themeModifier(ThemeData.from(colorScheme: colorSchemeLight!));
  }
}

// 獲取深色主題
/// 獲取深色主題設置
/// 如果未使用設備主題,則返回預設深色主題
ThemeData themeDark() {
  if (!(prefs?.getBool("useDeviceTheme") ?? false) || colorSchemeDark == null) {
    return themeModifier(ThemeData.from(
        colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Colors.black,
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.black,
            surface: Colors.black,
            onSurface: Colors.white)));
  } else {
    return themeModifier(ThemeData.from(colorScheme: colorSchemeDark!));
  }
}

// 獲取主題模式
/// 獲取當前主題模式
/// 返回系統、淺色或深色模式
ThemeMode themeMode() {
  return ((prefs?.getString("brightness") ?? "system") == "system")
      ? ThemeMode.system
      : ((prefs!.getString("brightness") == "dark") ? ThemeMode.dark : ThemeMode.light);
}
