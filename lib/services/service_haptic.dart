import 'package:flutter/services.dart';
import '../main.dart';

/// 提供應用程式觸覺反饋功能的服務
/// 可以通過偏好設定來啟用或禁用觸覺反饋

/// 檢查觸覺反饋是否已啟用
/// 返回: true 表示已啟用，false 表示已禁用
bool _isHapticEnabled() {
  return prefs.getBool('enableHaptic') ?? true;
}

/// 執行觸覺反饋的通用方法
/// [hapticFeedback] 具體的觸覺反饋回調函數
void _performHapticFeedback(VoidCallback hapticFeedback) {
  if (_isHapticEnabled()) {
    hapticFeedback();
  }
}

/// 觸發輕度觸覺反饋
void lightHaptic() {
  _performHapticFeedback(HapticFeedback.lightImpact);
}

/// 觸發中度觸覺反饋
void mediumHaptic() {
  _performHapticFeedback(HapticFeedback.mediumImpact);
}

/// 觸發重度觸覺反饋
void heavyHaptic() {
  _performHapticFeedback(HapticFeedback.heavyImpact);
}

/// 觸發選擇時的觸覺反饋
/// 使用輕度觸覺反饋來提供更好的使用者體驗
void selectionHaptic() {
  _performHapticFeedback(HapticFeedback.lightImpact);
}
