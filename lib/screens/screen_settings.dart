import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/haptic.dart';
import '../widgets/widget_screen_settings.dart';

/// 設置頁面
/// 用於配置應用程序的主要設置，如服務器地址等
class ScreenSettings extends StatefulWidget {
  const ScreenSettings({super.key});
  @override
  State<ScreenSettings> createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  SharedPreferences? _prefs;

  /// 是否使用固定主機地址
  bool useHost = true;

  /// 固定主機地址
  String fixedHost = "http://100.64.50.12:11434";

  /// 當前主機地址
  String? host;

  /// 主機地址輸入控制器
  final hostInputController = TextEditingController();

  /// 主機檢查載入狀態
  bool hostLoading = false;

  /// URL 格式是否無效
  bool hostInvalidUrl = false;

  /// 主機連接是否失敗
  bool hostInvalidHost = false;
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _loadPrefs();
  }

  /// 載入本地設置
  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    
    setState(() {
      // 初始化主機設置，添加空值檢查
      useHost = _prefs?.getBool('useHost') ?? false;
      fixedHost = _prefs?.getString('fixedHost') ?? '';
      host = _prefs?.getString('host') ?? 'http://localhost:11434';
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
