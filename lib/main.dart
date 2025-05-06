import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:pwa_install/pwa_install.dart' as pwa;
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'widgets/widgets_screens/widget_main.dart';
import 'services/service_desktop.dart';
import 'services/service_theme.dart';
import 'services/service_notification.dart';
import 'services/service_auth.dart'; // 添加認證服務引用
import 'screens/screen_auth.dart'; // 添加認證畫面引用
import 'screens/vaccine/screen_vaccine_record.dart'; // 導入疫苗記錄畫面

///*******************************************
/// 客戶端配置部分
/// 包含所有可自定義的應用程式設定
///*******************************************

/// 是否使用固定主機地址
/// 設為 false 時會顯示主機輸入對話框
const bool useHost = true;

/// Ollama 服務器地址設定
/// 必須確保客戶端可以訪問此地址
/// @note 不要包含結尾的斜線
const String fixedHost = "http://oldcookie276.asuscomm.com:11434";

/// 備用服務器地址，當主服務器無法訪問時使用
const String backupHost = "http://100.64.50.3:11434";

/// 是否使用固定模型
/// 若為 false，則顯示模型選擇器
const bool useModel = false;

/// 預設的 AI 模型名稱
const String fixedModel = "gemma3:12b";

/// 推薦模型列表
/// 在模型選擋中會標記星號
const List<String> recommendedModels = ["gemma3:12b", "deepseek-r1:14b"];

/// 是否允許打開設置頁面
const bool allowSettings = true;
const bool allowVaccine = true;
const bool allowCalendar = true;
const bool allowBMI = true;
const bool allowMedicalCertificate = true;

/// 是否允許多個聊天對話
const bool allowMultipleChats = true;

///*******************************************
/// 全局變量
/// 應用程式運行時的關鍵狀態管理
///*******************************************

/// 加密存儲相關設定
/// @param encryptionKey 用於加密本地存儲的金鑰
/// @param prefs 加密的SharedPreferences實例
const String encryptionKey = "draidraidraidrai";
late EncryptedSharedPreferences prefs;

/// 模型和主機配置
/// @param model 當前選擇的AI模型
/// @param host 當前連接的服務器地址
String? model;
String? host;

/// 是否支持多模態輸入
bool multimodal = false;

/// 聊天消息列表
List<types.Message> messages = [];
String? chatUuid;
bool chatAllowed = true;
String hoveredChat = "";

/// 主要組件引用
GlobalKey<ChatState>? chatKey;
final user = types.User(id: const Uuid().v8());
final assistant = types.User(id: const Uuid().v8());

/// UI 狀態控制
bool settingsOpen = false;
bool vaccineOpen = false;
bool desktopTitleVisible = true;
bool logoVisible = true;
bool menuVisible = false;
bool sendable = false;
bool updateDetectedOnStart = false;
double sidebarIconSize = 1;

/// 語音相關功能
SpeechToText speech = SpeechToText();
FlutterTts voice = FlutterTts();
bool voiceSupported = false;

/// 全局上下文與狀態更新函數
BuildContext? mainContext;
void Function(void Function())? setGlobalState;
void Function(void Function())? setMainAppState;

/// 主應用程式入口
/// 初始化必要的服務和配置
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化通知服務
    final notificationService = NotificationService();
    await notificationService.initialize();

    // 初始化加密存儲
    await EncryptedSharedPreferences.initialize(encryptionKey);
    prefs = EncryptedSharedPreferences.getInstance();

    // 設置主機地址，如果主伺服器不可用則使用備用伺服器
    if (useHost) {
      host = await checkHostAvailability(fixedHost) ? fixedHost : backupHost;
      debugPrint('使用的伺服器地址: $host');
    }

    // PWA 設定
    pwa.PWAInstall().setup(installCallback: () {});

    // 運行應用程式
    initializeDateFormatting().then((_) => runApp(const App()));

    // 桌面平台視窗設定
    if (isDesktopPlatform()) {
      doWhenWindowReady(() {
        appWindow.minSize = const Size(600, 450);
        appWindow.size = const Size(1200, 650);
        appWindow.alignment = Alignment.center;
        if (prefs.getBool("maximizeOnStart") ?? false) {
          appWindow.maximize();
        }
        appWindow.show();
      });
    }
  } catch (e) {
    debugPrint('初始化錯誤: $e');
    rethrow;
  }
}

/// 檢查主機是否可用
/// 嘗試連接主機，如果連接失敗則返回 false
Future<bool> checkHostAvailability(String host) async {
  try {
    final response = await http.get(Uri.parse('$host/api/version')).timeout(const Duration(seconds: 5));
    return response.statusCode == 200;
  } catch (e) {
    debugPrint('無法連接到 $host: $e');
    return false;
  }
}

/// 主應用程式狀態管理類
/// 負責管理應用程式的整體生命週期和狀態
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

/// 應用程式狀態實現
/// 包含初始化邏輯和UI構建
class _AppState extends State<App> {
  // 添加生物識別狀態
  bool _biometricEnabled = false;
  // 用於檢查是否需要導向到特定路徑
  String? _initialRoute;

  @override
  void initState() {
    super.initState();

    void load() async {
      try {
        await FlutterDisplayMode.setHighRefreshRate();
      } catch (_) {}

      try {
        if ((await Permission.bluetoothConnect.isGranted) && (await Permission.microphone.isGranted)) {
          voiceSupported = await speech.initialize();
        } else {
          prefs.setBool("voiceModeEnabled", false);
          voiceSupported = false;
        }
      } catch (_) {
        prefs.setBool("voiceModeEnabled", false);
        voiceSupported = false;
      }

      // 檢查是否啟用了生物識別
      _biometricEnabled = await ServiceAuth.isBiometricEnabled();

      // 檢查web路徑並設置初始路由
      if (kIsWeb) {
        final path = html.window.location.pathname;
        debugPrint('當前 Web 路徑: $path');

        if (path == '/vaccine') {
          _initialRoute = 'vaccine';
        }
      }

      setState(() {});
    }

    load();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        colorSchemeLight = lightDynamic;
        colorSchemeDark = darkDynamic;

        return StatefulBuilder(
          builder: (context, setState) {
            setMainAppState = setState;

            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              localeListResolutionCallback: (deviceLocales, supportedLocales) {
                if (deviceLocales != null) {
                  for (final locale in deviceLocales) {
                    var newLocale = Locale(locale.languageCode);
                    if (supportedLocales.contains(newLocale)) {
                      return locale;
                    }
                  }
                }
                return const Locale("en");
              },
              onGenerateTitle: (context) {
                return AppLocalizations.of(context)!.appTitle;
              },
              theme: themeLight(),
              darkTheme: themeDark(),
              themeMode: themeMode(),
              home: _buildHomeWidget(),
            );
          },
        );
      },
    );
  }

  // 根據條件構建首頁小部件
  Widget _buildHomeWidget() {
    // 如果有指定的初始路由，直接導向到相應頁面
    if (_initialRoute == 'vaccine' && allowVaccine) {
      return const ScreenVaccineRecord();
    }

    // 否則按照正常流程選擇顯示認證畫面或主應用
    return _biometricEnabled ? const AuthScreen() : const MainApp();
  }
}
