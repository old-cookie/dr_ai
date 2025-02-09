import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt_shared_preferences/provider.dart';
import '../services/service_haptic.dart';
import '../widgets/widgets_screens/widget_screen_settings.dart';
import '../main.dart' show useHost, fixedHost;

/// 設置頁面
/// 用於配置應用程序的主要設置，包括：
/// - 服務器主機地址配置
/// - 主機連接狀態檢查
/// - 本地設置的加載和保存
class ScreenSettings extends StatefulWidget {
  const ScreenSettings({super.key});
  @override
  State<ScreenSettings> createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  /// 本地儲存實例
  EncryptedSharedPreferences? _prefs;

  /// 當前使用的主機地址
  /// 用於臨時存儲有效的主機配置
  String? host;

  /// 主機地址輸入控制器
  /// 用於管理輸入框的文本內容
  final hostInputController = TextEditingController();

  /// 主機檢查載入狀態
  /// true 表示正在進行連接測試
  bool hostLoading = false;

  /// URL 格式是否無效
  /// true 表示輸入的 URL 格式不正確
  bool hostInvalidUrl = false;

  /// 主機連接是否失敗
  /// true 表示無法連接到指定主機
  bool hostInvalidHost = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _loadPrefs();
  }

  /// 載入本地設置
  /// 從 SharedPreferences 中讀取已保存的主機設置
  /// 並根據固定主機模式決定是否進行連接測試
  Future<void> _loadPrefs() async {
    _prefs = EncryptedSharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      host = _prefs?.getString('host') ?? fixedHost;
      hostInputController.text = useHost ? fixedHost : host!;

      if ((Uri.parse(hostInputController.text.trim().replaceAll(RegExp(r'/$'), '').trim()).toString() != fixedHost)) {
        checkHost();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    hostInputController.dispose();
  }

  /// 檢查主機連接狀態
  /// 執行以下步驟：
  /// 1. 格式化並驗證主機地址
  /// 2. 發送測試請求檢查連接
  /// 3. 處理響應結果並更新狀態
  /// 4. 成功時保存新的主機設置
  void checkHost() async {
    setState(() {
      hostLoading = true;
      hostInvalidUrl = false;
      hostInvalidHost = false;
    });
    // 處理主機地址格式
    var tmpHost = hostInputController.text.trim().replaceAll(RegExp(r'/$'), '').trim();
    // 驗證 URL 格式
    if (tmpHost.isEmpty || !Uri.parse(tmpHost).isAbsolute) {
      setState(() {
        hostInvalidUrl = true;
        hostLoading = false;
      });
      return;
    }
    // 測試主機連接
    http.Response? request;
    try {
      var client = http.Client();
      final requestBase = http.Request("get", Uri.parse(tmpHost))
        ..headers.addAll(
          (jsonDecode(_prefs?.getString("hostHeaders") ?? "{}") as Map).cast<String, String>(),
        )
        ..followRedirects = false;
      // 發送請求並設置超時
      request = await http.Response.fromStream(
        await requestBase.send().timeout(
              Duration(milliseconds: (5000.0 * (_prefs?.getDouble("timeoutMultiplier") ?? 1.0)).round()),
              onTimeout: () => http.StreamedResponse(const Stream.empty(), 408),
            ),
      );
      client.close();
    } catch (e) {
      setState(() {
        hostInvalidHost = true;
        hostLoading = false;
      });
      return;
    }
    // 處理響應結果
    if ((request.statusCode == 200 && request.body == "Ollama is running") || (Uri.parse(tmpHost).toString() == fixedHost)) {
      setState(() {
        hostLoading = false;
        host = tmpHost;
        if (hostInputController.text != host! && (Uri.parse(tmpHost).toString() != fixedHost)) {
          hostInputController.text = host!;
        }
      });
      _prefs?.setString("host", host!);
    } else {
      setState(() {
        hostInvalidHost = true;
        hostLoading = false;
      });
    }
    selectionHaptic();
  }

  /// 構建設置頁面
  /// 在 SharedPreferences 初始化完成前顯示載入指示器
  /// 初始化完成後顯示完整的設置界面
  @override
  Widget build(BuildContext context) {
    // 如果 prefs 未初始化，顯示載入指示器
    if (_prefs == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WidgetScreenSettings(
      hostInputController: hostInputController,
      hostLoading: hostLoading,
      hostInvalidUrl: hostInvalidUrl,
      hostInvalidHost: hostInvalidHost,
      checkHost: checkHost,
      useHost: useHost,
      prefs: _prefs,
    );
  }
}
