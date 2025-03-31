import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/service_auth.dart';
import '../services/service_haptic.dart';

import '../widgets/widgets_screens/widget_main.dart';
import '../l10n/app_localizations.dart';
import 'dart:developer' as developer;

/// 生物識別認證畫面
/// 在應用啟動時檢查並要求用戶進行生物識別認證
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticating = false;
  bool _authFailed = false;
  String _statusText = '';
  bool _showPinInput = false;
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _showBiometricHelp = false;
  String _biometricErrorCode = '';

  @override
  void initState() {
    super.initState();
    developer.log('AuthScreen 初始化', name: 'AuthScreen');
    // 當畫面構建完成後啟動驗證
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthMethod();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  /// 檢查認證方法
  Future<void> _checkAuthMethod() async {
    developer.log('檢查可用的認證方法', name: 'AuthScreen');
    final bool biometricEnabled = await ServiceAuth.isBiometricEnabled();
    final bool pinSet = await ServiceAuth.isPinSet();

    developer.log('認證方法檢查結果 - 生物識別已啟用: $biometricEnabled, PIN碼已設置: $pinSet', name: 'AuthScreen');

    if (biometricEnabled) {
      developer.log('使用生物識別認證方式', name: 'AuthScreen');
      _authenticate();
    } else if (pinSet) {
      developer.log('使用 PIN 碼認證方式', name: 'AuthScreen');
      setState(() {
        _showPinInput = true;
      });
    } else {
      developer.log('未設置任何認證方式，直接進入應用', name: 'AuthScreen');
      // 未設置任何認證方式，直接進入應用
      _proceedToApp();
    }
  }

  /// 執行生物識別驗證
  Future<void> _authenticate() async {
    if (_isAuthenticating) {
      developer.log('認證已在進行中，忽略新的認證請求', name: 'AuthScreen');
      return;
    }

    try {
      developer.log('開始進行生物識別認證流程', name: 'AuthScreen');
      setState(() {
        _isAuthenticating = true;
        _authFailed = false;
        _statusText = '';
        _showBiometricHelp = false;
        _biometricErrorCode = '';
      });

      // 檢查設備功能和 PIN 碼設置
      final bool deviceSupported = await ServiceAuth.isDeviceSupported();
      final bool canCheckBiometric = await ServiceAuth.canCheckBiometrics();
      final bool isEnrolled = await ServiceAuth.isBiometricEnrolled();
      final bool pinSet = await ServiceAuth.isPinSet();

      developer.log('設備支援檢查: 支援生物識別=$deviceSupported, 可檢查生物識別=$canCheckBiometric, 已註冊生物識別=$isEnrolled, PIN碼已設置=$pinSet', name: 'AuthScreen');

      if (!deviceSupported || !canCheckBiometric || !isEnrolled) {
        developer.log('設備不支持生物識別或未註冊生物識別數據', name: 'AuthScreen');
        setState(() {
          _isAuthenticating = false;
          _authFailed = true;
          _showBiometricHelp = true;

          if (!deviceSupported) {
            _biometricErrorCode = ServiceAuth.errorHardwareUnavailable;
            _statusText = '設備不支援生物識別功能';
          } else if (!canCheckBiometric) {
            _biometricErrorCode = ServiceAuth.errorNotAvailable;
            _statusText = '無法使用生物識別功能';
          } else if (!isEnrolled) {
            _biometricErrorCode = ServiceAuth.errorNotEnrolled;
            _statusText = '設備未註冊任何生物識別資料';
          }
        });

        // 如果設備不支援生物識別但設置了PIN碼，則使用PIN碼
        if (pinSet) {
          setState(() {
            _showPinInput = true;
          });
        } else if (!pinSet) {
          // 如果設備不支援生物識別且未設置PIN碼，則直接進入應用
          _proceedToApp();
        }
        return;
      }

      // 檢查是否啟用了生物識別
      final bool biometricEnabled = await ServiceAuth.isBiometricEnabled();
      if (!biometricEnabled) {
        developer.log('生物識別未啟用', name: 'AuthScreen');
        // 如果生物識別未啟用但設置了PIN碼，則使用PIN碼
        if (pinSet) {
          developer.log('轉為使用 PIN 碼認證', name: 'AuthScreen');
          setState(() {
            _isAuthenticating = false;
            _showPinInput = true;
          });
          return;
        } else {
          developer.log('未設置認證方法，直接進入應用', name: 'AuthScreen');
          // 未設置認證方法，直接進入應用
          _proceedToApp();
          return;
        }
      }

      // 顯示本地化的驗證提示
      final String reason = AppLocalizations.of(context)?.authPrompt ?? '請進行生物識別驗證以解鎖應用';
      developer.log('顯示生物識別認證提示: $reason', name: 'AuthScreen');

      // 使用帶狀態的認證方法
      final Map<String, dynamic> result = await ServiceAuth.authenticateWithStatus(reason);
      final bool authenticated = result['success'] as bool;

      if (!mounted) return;

      if (authenticated) {
        developer.log('生物識別認證成功', name: 'AuthScreen');
        successHaptic();
        _proceedToApp();
      } else {
        developer.log('生物識別認證失敗: ${result['errorMessage']}', name: 'AuthScreen');
        errorHaptic();
        setState(() {
          _authFailed = true;
          _isAuthenticating = false;
          _statusText = result['errorMessage'] ?? AppLocalizations.of(context)?.authFailed ?? '驗證失敗，請重試';
          _biometricErrorCode = result['errorCode'] ?? ServiceAuth.errorUnknown;
          _showBiometricHelp = true;
        });
      }
    } catch (e) {
      if (!mounted) return;

      developer.log('生物識別認證過程出錯: $e', name: 'AuthScreen');
      errorHaptic();
      setState(() {
        _authFailed = true;
        _isAuthenticating = false;
        _statusText = e.toString();
        _showBiometricHelp = true;
      });
    }
  }

  /// 驗證 PIN 碼
  Future<void> _verifyPin() async {
    developer.log('開始 PIN 碼驗證', name: 'AuthScreen');
    if (_pinController.text.isEmpty) {
      developer.log('PIN 碼為空', name: 'AuthScreen');
      setState(() {
        _statusText = AppLocalizations.of(context)?.pinEmpty ?? '請輸入PIN碼';
      });
      return;
    }

    developer.log('驗證用戶輸入的 PIN 碼', name: 'AuthScreen');
    final bool verified = await ServiceAuth.verifyPin(_pinController.text);
    if (verified) {
      developer.log('PIN 碼驗證成功', name: 'AuthScreen');
      successHaptic();
      _proceedToApp();
    } else {
      developer.log('PIN 碢驗證失敗', name: 'AuthScreen');
      errorHaptic();
      setState(() {
        _statusText = AppLocalizations.of(context)?.pinIncorrect ?? 'PIN碼不正確';
        _pinController.clear();
      });
    }
  }

  /// 切換到 PIN 碼輸入
  void _switchToPin() {
    developer.log('切換到 PIN 碼輸入模式', name: 'AuthScreen');
    setState(() {
      _showPinInput = true;
      _authFailed = false;
      _statusText = '';
    });
    // 聚焦到PIN輸入框
    Future.delayed(const Duration(milliseconds: 100), () {
      _pinFocusNode.requestFocus();
    });
  }

  /// 驗證成功後進入主應用
  void _proceedToApp() {
    if (!mounted) return;

    developer.log('認證成功，進入主應用', name: 'AuthScreen');
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainApp()));
  }

  /// 退出應用
  void _exitApp() {
    developer.log('用戶選擇退出應用', name: 'AuthScreen');
    SystemNavigator.pop();
  }

  /// 顯示生物識別問題説明
  Widget _buildBiometricHelpSection() {
    String helpMessage = '';

    switch (_biometricErrorCode) {
      case ServiceAuth.errorNotAvailable:
        helpMessage = '• 請確認您的設備支援生物識別功能\n• 檢查系統設定中的生物識別功能是否已啟用';
        break;
      case ServiceAuth.errorNotEnrolled:
        helpMessage = '• 您尚未在設備上註冊任何指紋或面容資料\n• 請到設備系統設定中添加生物識別資料';
        break;
      case ServiceAuth.errorHardwareUnavailable:
        helpMessage = '• 生物識別硬體可能暫時無法使用\n• 請重新啟動設備後再試\n• 檢查設備生物識別感應器是否正常';
        break;
      case ServiceAuth.errorPermissionDenied:
        helpMessage = '• 應用程式沒有使用生物識別的權限\n• 請在系統設定中允許此應用使用生物識別功能';
        break;
      case ServiceAuth.errorSecurityError:
        helpMessage = '• 因多次嘗試失敗，生物識別暫時被鎖定\n• 請稍後再試或使用PIN碼登入';
        break;
      case ServiceAuth.errorSensorError:
        helpMessage = '• 生物識別感應器無法正常工作\n• 請確保感應器清潔且未被遮蓋\n• 輕觸而非按壓指紋感應器';
        break;
      case ServiceAuth.errorFragmentActivity:
        helpMessage = '• 應用程式內部配置問題\n• 請檢查最新版本或聯繫開發者\n• 暫時請使用PIN碼登入';
        break;
      default:
        helpMessage = '• 確保手指乾燥並清潔\n• 輕觸而非按壓感應器\n• 使用已註冊的指紋\n• 如持續遇到問題，請使用PIN碼登入';
        break;
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        Text('生物識別問題排解：', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
          child: Text(helpMessage, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 應用圖標
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Hero(tag: 'app_logo', child: ImageIcon(AssetImage("assets/logo512.png"), size: 100)),
              ),

              // 應用名稱
              Text(AppLocalizations.of(context)?.appTitle ?? 'Dr.AI', style: Theme.of(context).textTheme.headlineMedium),

              const SizedBox(height: 50),

              // 驗證狀態
              if (_statusText.isNotEmpty) Text(_statusText, style: TextStyle(color: Theme.of(context).colorScheme.error)),

              // 生物識別説明
              if (_showBiometricHelp) _buildBiometricHelpSection(),

              const SizedBox(height: 30),

              // PIN 碼輸入部分
              if (_showPinInput)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)?.pinCode ?? 'PIN碼', border: const OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        onSubmitted: (_) => _verifyPin(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: _verifyPin, child: Text(AppLocalizations.of(context)?.login ?? '登入')),
                    ],
                  ),
                ),

              // 生物識別相關按鈕
              if (_authFailed && !_showPinInput)
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _authenticate,
                      icon: const Icon(Icons.fingerprint),
                      label: Text(AppLocalizations.of(context)?.authRetry ?? '重試'),
                    ),
                    const SizedBox(height: 16),
                    // 添加使用 PIN 碼登入的按鈕
                    TextButton(onPressed: _switchToPin, child: Text(AppLocalizations.of(context)?.usePin ?? '使用PIN碼登入')),
                  ],
                ),

              const SizedBox(height: 16),

              // 退出按鈕
              if (_authFailed || _showPinInput) TextButton(onPressed: _exitApp, child: Text(AppLocalizations.of(context)?.authExit ?? '退出')),

              // 驗證中指示器
              if (_isAuthenticating)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)?.authInProgress ?? '請完成生物識別驗證'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
