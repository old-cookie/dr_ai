import '../main.dart';

/// 用戶引導服務
/// 管理引導頁面的顯示狀態
class GuideService {
  static const String _guideKey = 'guide_shown';

  /// 檢查是否需要顯示引導頁面
  /// 返回 true 表示需要顯示引導
  static bool shouldShowGuide() {
    return prefs.getInt(_guideKey) == 0;
  }

  /// 標記引導頁面已顯示
  static Future<void> markGuideShown() async {
    await prefs.setInt(_guideKey, 1);
  }

  /// 重置引導狀態
  /// 下次啟動時將重新顯示引導頁面
  static Future<void> resetGuide() async {
    await prefs.setInt(_guideKey, 0);
  }

  /// 初始化引導狀態
  /// 如果是首次運行，設置為需要顯示引導
  static Future<void> initGuide() async {
    final value = prefs.getInt(_guideKey);
    if (value == null) {
      await prefs.setInt(_guideKey, 0);
    }
  }
}
