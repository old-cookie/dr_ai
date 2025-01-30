import 'package:flutter/services.dart';

import '../main.dart';

bool _isHapticEnabled() {
  return prefs?.getBool('enableHaptic') ?? true;
}

void _performHapticFeedback(VoidCallback hapticFeedback) {
  if (_isHapticEnabled()) {
    hapticFeedback();
  }
}

void lightHaptic() {
  _performHapticFeedback(HapticFeedback.lightImpact);
}

void mediumHaptic() {
  _performHapticFeedback(HapticFeedback.mediumImpact);
}

void heavyHaptic() {
  _performHapticFeedback(HapticFeedback.heavyImpact);
}

void selectionHaptic() {
  // Same name but for better experience, change behavior
  _performHapticFeedback(HapticFeedback.lightImpact);
  // HapticFeedback.selectionClick();
}