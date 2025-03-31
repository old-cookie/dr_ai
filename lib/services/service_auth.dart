import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'dart:developer' as developer;

/// 認證服務
/// 提供生物識別（指紋/臉部ID）認證功能
class ServiceAuth {
  static final LocalAuthentication _auth = LocalAuthentication();
  static bool _isAuthenticating = false;

  // 定義生物識別錯誤類型
  static const String errorNotAvailable = "biometric_not_available";
  static const String errorNotEnrolled = "biometric_not_enrolled";
  static const String errorHardwareUnavailable = "hardware_unavailable";
  static const String errorPermissionDenied = "permission_denied";
  static const String errorSecurityError = "security_error";
  static const String errorSensorError = "sensor_error";
  static const String errorUnknown = "unknown_error";
  static const String errorFragmentActivity = "no_fragment_activity";

  /// 檢查設備是否支持生物識別
  static Future<bool> isDeviceSupported() async {
    final bool isSupported = await _auth.isDeviceSupported();
    developer.log('設備支持生物識別: $isSupported', name: 'ServiceAuth');
    return isSupported;
  }

  /// 檢查是否可以使用生物識別
  static Future<bool> canCheckBiometrics() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      developer.log('可以檢查生物識別: $canCheck', name: 'ServiceAuth');
      return canCheck;
    } on PlatformException catch (e) {
      developer.log('檢查生物識別能力時發生錯誤: ${e.message}', name: 'ServiceAuth');
      return false;
    }
  }

  /// 檢查設備是否已註冊生物識別資料
  static Future<bool> isBiometricEnrolled() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      final bool hasData = availableBiometrics.isNotEmpty;
      developer.log('設備是否已註冊生物識別資料: $hasData', name: 'ServiceAuth');
      return hasData;
    } catch (e) {
      developer.log('檢查生物識別註冊狀態時發生錯誤: $e', name: 'ServiceAuth');
      return false;
    }
  }

  /// 獲取可用的生物識別類型
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      developer.log('可用的生物識別類型: $biometrics', name: 'ServiceAuth');
      return biometrics;
    } on PlatformException catch (e) {
      developer.log('獲取可用生物識別類型時發生錯誤: ${e.message}', name: 'ServiceAuth');
      return <BiometricType>[];
    }
  }

  /// 使用生物識別進行認證
  static Future<Map<String, dynamic>> authenticateWithStatus(String localizedReason) async {
    developer.log('開始生物識別認證', name: 'ServiceAuth');
    if (_isAuthenticating) {
      developer.log('已有認證進行中，停止先前的認證', name: 'ServiceAuth');
      await stopAuthentication();
    }

    _isAuthenticating = true;
    bool authenticated = false;
    String errorCode = errorUnknown;
    String errorMessage = "未知錯誤";

    try {
      // 先檢查設備支援和能力
      if (!await isDeviceSupported()) {
        return {'success': false, 'errorCode': errorHardwareUnavailable, 'errorMessage': '設備不支援生物識別功能'};
      }

      if (!await canCheckBiometrics()) {
        return {'success': false, 'errorCode': errorNotAvailable, 'errorMessage': '無法使用生物識別功能'};
      }

      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return {'success': false, 'errorCode': errorNotEnrolled, 'errorMessage': '設備未註冊任何生物識別資料(指紋/臉部ID)'};
      }

      authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      developer.log('生物識別認證結果: $authenticated', name: 'ServiceAuth');

      return {'success': authenticated, 'errorCode': authenticated ? '' : errorUnknown, 'errorMessage': authenticated ? '' : '生物識別驗證失敗'};
    } on PlatformException catch (e) {
      developer.log('生物識別認證發生錯誤: ${e.message}, 錯誤代碼: ${e.code}', name: 'ServiceAuth');

      errorMessage = '生物識別認證失敗';
      errorCode = errorUnknown;

      // 解析特定錯誤代碼
      if (e.code == 'NotAvailable' || e.code == 'NotEnrolled') {
        errorCode = errorNotAvailable;
        errorMessage = '設備不支援生物識別或未設置';
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        errorCode = errorSecurityError;
        errorMessage = '因多次嘗試失敗，生物識別暫時被鎖定';
      } else if (e.code == 'PasscodeNotSet') {
        errorCode = errorSecurityError;
        errorMessage = '設備未設置螢幕鎖定密碼';
      } else if (e.code == 'NotEnrolled') {
        errorCode = errorNotEnrolled;
        errorMessage = '設備未註冊生物識別資料';
      } else if (e.code == 'OtherOperatingSystem') {
        errorCode = errorHardwareUnavailable;
        errorMessage = '不支援的作業系統';
      } else if (e.code == 'LockedOut') {
        errorCode = errorSensorError;
        errorMessage = '感應器已鎖定，請稍後再試';
      } else if (e.code == 'no_fragment_activity') {
        errorCode = errorFragmentActivity;
        errorMessage = '應用程式配置問題，請更新至最新版本';
      }

      return {'success': false, 'errorCode': errorCode, 'errorMessage': errorMessage, 'platformError': e.toString()};
    } catch (e) {
      developer.log('生物識別認證發生非預期錯誤: $e', name: 'ServiceAuth');
      return {'success': false, 'errorCode': errorUnknown, 'errorMessage': '發生未知錯誤: $e', 'error': e.toString()};
    } finally {
      _isAuthenticating = false;
    }
  }

  /// 使用生物識別進行認證 (兼容現有程式碼)
  static Future<bool> authenticate(String localizedReason) async {
    final result = await authenticateWithStatus(localizedReason);
    return result['success'] as bool;
  }

  /// 停止認證過程
  static Future<void> stopAuthentication() async {
    if (_isAuthenticating) {
      developer.log('停止正在進行的認證', name: 'ServiceAuth');
      await _auth.stopAuthentication();
      _isAuthenticating = false;
    }
  }

  /// 檢查生物識別是否已啟用
  static Future<bool> isBiometricEnabled() async {
    final prefs = EncryptedSharedPreferences.getInstance();
    final enabled = prefs.getBool('useBiometricAuth') ?? false;
    developer.log('生物識別啟用狀態: $enabled', name: 'ServiceAuth');
    return enabled;
  }

  /// 設置生物識別啟用狀態
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = EncryptedSharedPreferences.getInstance();
    await prefs.setBool('useBiometricAuth', enabled);
  }

  /// 設置 PIN 碼
  static Future<void> setPin(String pin) async {
    final prefs = EncryptedSharedPreferences.getInstance();
    await prefs.setString('authPin', pin);
  }

  /// 驗證 PIN 碼
  static Future<bool> verifyPin(String pin) async {
    developer.log('開始驗證 PIN 碼', name: 'ServiceAuth');
    final prefs = EncryptedSharedPreferences.getInstance();
    final storedPin = prefs.getString('authPin');
    final verified = storedPin == pin;
    developer.log('PIN 碼驗證結果: $verified', name: 'ServiceAuth');
    return verified;
  }

  /// 檢查是否已設置 PIN 碼
  static Future<bool> isPinSet() async {
    final prefs = EncryptedSharedPreferences.getInstance();
    final pin = prefs.getString('authPin');
    return pin != null && pin.isNotEmpty;
  }

  /// 清除 PIN 碼
  static Future<void> clearPin() async {
    final prefs = EncryptedSharedPreferences.getInstance();
    await prefs.remove('authPin');
  }
}
