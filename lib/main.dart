import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'services/services_desktop.dart';
import 'services/services_theme.dart';

///*******************************************
/// 客戶端配置部分
///*******************************************

/// 是否使用固定主機地址
/// 若為 false，則顯示對話框讓用戶輸入
const bool useHost = true;

/// Ollama 服務器地址，必須能從客戶端訪問
/// 不需要包含結尾的斜線
const String fixedHost = "http://100.64.50.12:11434";

/// 是否使用固定模型
/// 若為 false，則顯示模型選擇器
const bool useModel = true;

/// 預設的 AI 模型名稱
const String fixedModel = "oldcookie/dr_ai:q5_1";

/// 推薦模型列表
/// 在模型選擋中會標記星號
const List<String> recommendedModels = ["oldcookie/dr_ai:q5_1", "oldcookie/dr_ai:q8_0"];

/// 是否允許打開設置頁面
const bool allowSettings = true;

/// 是否允許多個聊天對話
const bool allowMultipleChats = true;

///*******************************************
/// 全局變量
///*******************************************

/// 本地存儲實例
SharedPreferences? prefs;

/// 當前選擇的模型和主機
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
final user = types.User(id: const Uuid().v4());
final assistant = types.User(id: const Uuid().v4());

/// UI 狀態控制
bool settingsOpen = false;
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

void main() {
  pwa.PWAInstall().setup(installCallback: () {});

  runApp(const App());

  if (isDesktopPlatform()) {
    doWhenWindowReady(() {
      appWindow.minSize = const Size(600, 450);
      appWindow.size = const Size(1200, 650);
      appWindow.alignment = Alignment.center;
      if (prefs!.getBool("maximizeOnStart") ?? false) {
        appWindow.maximize();
      }
      appWindow.show();
    });
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    void load() async {
      try {
        await FlutterDisplayMode.setHighRefreshRate();
      } catch (_) {}

      SharedPreferences.setPrefix("ollama.");
      SharedPreferences tmp = await SharedPreferences.getInstance();
      setState(() {
        prefs = tmp;
      });

      try {
        if ((await Permission.bluetoothConnect.isGranted) && (await Permission.microphone.isGranted)) {
          voiceSupported = await speech.initialize();
        } else {
          prefs!.setBool("voiceModeEnabled", false);
          voiceSupported = false;
        }
      } catch (_) {
        prefs!.setBool("voiceModeEnabled", false);
        voiceSupported = false;
      }
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
