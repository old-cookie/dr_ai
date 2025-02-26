import 'dart:io';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/service_haptic.dart';
import '../../services/service_desktop.dart';
import '../../services/service_theme.dart';
import '../../widgets/widgets_screens/widgets_settings/widget_export.dart';

/// 導出設置頁面
/// 用於導出和導入聊天記錄
class ScreenSettingsExport extends StatefulWidget {
  const ScreenSettingsExport({super.key});
  @override
  State<ScreenSettingsExport> createState() => _ScreenSettingsExportState();
}

class _ScreenSettingsExportState extends State<ScreenSettingsExport> {
  /// 導出聊天記錄
  /// 將聊天記錄保存為 JSON 文件
  Future<void> _exportChats(BuildContext context) async {
    selectionHaptic();
    // 生成導出文件名,包含時間戳
    var name = "DrAI-export-${DateFormat('yyyy-MM-dd-H-m-s').format(DateTime.now())}.json";
    var content = jsonEncode(prefs.getStringList("chats") ?? []);
    // 根據平台選擇導出方式
    if (kIsWeb) {
      await _exportChatsWeb(name, content);
    } else {
      await _exportChatsDesktop(name, content);
    }
    // 顯示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // ignore: use_build_context_synchronously
        content: Text(AppLocalizations.of(context)!.settingsExportChatsSuccess),
        showCloseIcon: true,
      ),
    );
  }

  /// Web 平台導出聊天記錄
  /// 使用瀏覽器的下載功能
  Future<void> _exportChatsWeb(String name, String content) async {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement("a") as html.AnchorElement
      ..href = url
      ..style.display = "none"
      ..download = name;
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  /// 桌面平台導出聊天記錄
  /// 使用文件選擇器保存文件
  Future<void> _exportChatsDesktop(String name, String content) async {
    String? path = "";
    try {
      // 嘗試使用 file_selector 保存
      path = (await file_selector.getSaveLocation(
        acceptedTypeGroups: [
          const file_selector.XTypeGroup(label: "DrAI File", extensions: ["json"]),
        ],
        suggestedName: name,
      ))
          ?.path;
    } catch (_) {
      // 備用方案：使用 FilePicker
      path = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ["json"],
        fileName: name,
        bytes: utf8.encode(jsonEncode(prefs.getStringList("chats") ?? [])),
      );
    }
    selectionHaptic();
    if (isDesktopPlatform()) {
      File(path!).writeAsString(content);
    }
  }

  /// 導入聊天記錄
  /// 從 JSON 文件中讀取聊天記錄
  Future<void> _importChats(BuildContext context) async {
    selectionHaptic();
    resetSystemNavigation(
      context,
      systemNavigationBarColor: Color.alphaBlend(Colors.black54, Theme.of(context).colorScheme.surface),
    );
    // 顯示確認對話框
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.settingsImportChatsTitle),
          content: Text(AppLocalizations.of(context)!.settingsImportChatsDescription),
          actions: [
            // 取消按鈕
            TextButton(
              onPressed: () {
                selectionHaptic();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.settingsImportChatsCancel),
            ),
            // 導入按鈕
            TextButton(
              onPressed: () async {
                selectionHaptic();
                String content;
                try {
                  // 嘗試使用 file_selector 讀取文件
                  if (kIsWeb) {
                    throw Exception("web must use file picker");
                  }
                  file_selector.XFile? result = await file_selector.openFile(
                    acceptedTypeGroups: [
                      const file_selector.XTypeGroup(label: "Ollama App File", extensions: ["json"]),
                    ],
                  );
                  if (result == null) {
                    Navigator.of(context).pop();
                    return;
                  }
                  content = await result.readAsString();
                } catch (_) {
                  // 備用方案：使用 FilePicker
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ["json"],
                  );
                  if (result == null) {
                    Navigator.of(context).pop();
                    return;
                  }
                  try {
                    File file = File(result.files.single.path!);
                    content = await file.readAsString();
                  } catch (_) {
                    // web fallback
                    content = utf8.decode(result.files.single.bytes as List<int>);
                  }
                }
                // 解析並儲存導入的聊天記錄
                List<dynamic> tmpHistory = jsonDecode(content);
                List<String> history = tmpHistory.map((item) => item.toString()).toList();
                prefs.setStringList("chats", history);
                // 清空當前聊天
                messages = [];
                chatUuid = null;
                setState(() {});
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.settingsImportChatsSuccess),
                    showCloseIcon: true,
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.settingsImportChatsImport),
            ),
          ],
        );
      },
    );
    resetSystemNavigation(context);
  }

  @override
  Widget build(BuildContext context) {
    /// 使用導出設置組件構建界面
    return WidgetExport(
      exportChats: _exportChats,
      importChats: _importChats,
    );
  }
}
