import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//import 'package:shared_preferences/shared_preferences.dart';
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
import 'widgets/widgets_screens/widget_main.dart';
import 'services/service_desktop.dart';
import 'services/service_theme.dart';
import 'services/service_notification.dart';

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
const String fixedHost = "http://100.64.50.12:11434";

/// 是否使用固定模型
/// 若為 false，則顯示模型選擇器
const bool useModel = false;

/// 預設的 AI 模型名稱
const String fixedModel = "oldcookie/dr_ai:q5_1";

/// 推薦模型列表
/// 在模型選擋中會標記星號
const List<String> recommendedModels = ["oldcookie/dr_ai:q5_1", "oldcookie/dr_ai:q8_0"];

/// 是否允許打開設置頁面
const bool allowSettings = true;
const bool allowVaccine = true;
const bool allowCalendar = true;

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
void main() async {
  // 確保 Flutter 綁定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();

  try {
    // 初始化加密存儲
    await EncryptedSharedPreferences.initialize(encryptionKey);
    prefs = EncryptedSharedPreferences.getInstance();

    // PWA 設定
    pwa.PWAInstall().setup(installCallback: () {});

    // 運行應用程式
    runApp(const App());

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

      setState(() {});
    }

    load();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      colorSchemeLight = lightDynamic;
      colorSchemeDark = darkDynamic;

      return StatefulBuilder(builder: (context, setState) {
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
            home: const MainApp());
      });
    });
  }
}
