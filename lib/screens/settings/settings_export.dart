import 'dart:io';
import 'dart:convert';
import 'dart:developer';
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
/// 用於導出和導入所有偏好設置數據
class ScreenSettingsExport extends StatefulWidget {
  const ScreenSettingsExport({super.key});
  @override
  State<ScreenSettingsExport> createState() => _ScreenSettingsExportState();
}

class _ScreenSettingsExportState extends State<ScreenSettingsExport> {
  /// 獲取所有偏好設置數據
  Map<String, dynamic> _getAllPrefs() {
    Map<String, dynamic> allPrefs = {};

    // 獲取所有可用的鍵
    Set<String> keys = prefs.getKeys();

    // 遍歷並保存每個偏好設置
    for (String key in keys) {
      try {
        // 直接嘗試獲取不同類型的值
        try {
          String? stringValue = prefs.getString(key);
          if (stringValue != null) {
            allPrefs[key] = {'type': 'string', 'value': stringValue};
            continue;
          }
        } catch (_) {}

        try {
          bool? boolValue = prefs.getBool(key);
          if (boolValue != null) {
            allPrefs[key] = {'type': 'bool', 'value': boolValue};
            continue;
          }
        } catch (_) {}

        try {
          int? intValue = prefs.getInt(key);
          if (intValue != null) {
            allPrefs[key] = {'type': 'int', 'value': intValue};
            continue;
          }
        } catch (_) {}

        try {
          double? doubleValue = prefs.getDouble(key);
          if (doubleValue != null) {
            allPrefs[key] = {'type': 'double', 'value': doubleValue};
            continue;
          }
        } catch (_) {}

        try {
          List<String>? listValue = prefs.getStringList(key);
          if (listValue != null) {
            allPrefs[key] = {'type': 'stringList', 'value': listValue};
            continue;
          }
        } catch (_) {}
      } catch (e) {
        // 忽略無法處理的鍵值
        log('無法處理偏好設置鍵: $key, 錯誤: $e');
      }
    }

    return allPrefs;
  }

  /// 導出所有偏好設置數據
  /// 將數據保存為JSON文件
  Future<void> _exportPrefs(BuildContext context) async {
    selectionHaptic();
    // 生成導出文件名,包含時間戳
    var name = "DrAI-prefs-${DateFormat('yyyy-MM-dd-H-m-s').format(DateTime.now())}.json";

    // 獲取偏好設置數據
    var prefsData = _getAllPrefs();
    var jsonData = jsonEncode(prefsData);

    // 根據平台選擇導出方式
    if (kIsWeb) {
      await _exportDataWeb(name, jsonData);
    } else {
      await _exportDataDesktop(name, jsonData);
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

  /// Web 平台導出數據
  Future<void> _exportDataWeb(String name, String content) async {
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

  /// 桌面平台導出數據
  Future<void> _exportDataDesktop(String name, String content) async {
    String? path = "";
    try {
      // 嘗試使用 file_selector 保存
      path = (await file_selector.getSaveLocation(
        acceptedTypeGroups: [
          const file_selector.XTypeGroup(label: "DrAI Data", extensions: ["json"]),
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
        bytes: utf8.encode(content),
      );
    }
    selectionHaptic();
    if (isDesktopPlatform() && path != null) {
      File(path).writeAsString(content);
    }
  }

  /// 導入偏好設置數據
  /// 從JSON文件中讀取並覆蓋現有設置
  Future<void> _importPrefs(BuildContext context) async {
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
                String jsonContent = "";
                try {
                  // 嘗試使用 file_selector 讀取文件
                  if (kIsWeb) {
                    throw Exception("web must use file picker");
                  }
                  file_selector.XFile? result = await file_selector.openFile(
                    acceptedTypeGroups: [
                      const file_selector.XTypeGroup(label: "DrAI Data", extensions: ["json"]),
                    ],
                  );
                  if (result == null) {
                    Navigator.of(context).pop();
                    return;
                  }

                  // 檢查文件是否存在和可訪問
                  try {
                    final File fileObj = File(result.path);
                    if (!await fileObj.exists()) {
                      throw Exception("文件不存在: ${result.path}");
                    }

                    final fileSize = await fileObj.length();
                    log('文件大小: $fileSize 字節');
                    if (fileSize == 0) {
                      throw Exception("文件為空");
                    }

                    // 直接使用 File 讀取，而不是 XFile
                    jsonContent = await fileObj.readAsString();
                    log('使用 File.readAsString() 讀取文件, 內容長度: ${jsonContent.length}');
                  } catch (fileError) {
                    log('使用 File API 讀取失敗: $fileError，嘗試使用 XFile API');
                    // 回退到 XFile API
                    jsonContent = await result.readAsString();
                    log('使用 XFile.readAsString() 讀取文件, 內容長度: ${jsonContent.length}');
                  }
                } catch (e) {
                  log('file_selector 讀取失敗: $e，嘗試使用 FilePicker');
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
                    jsonContent = await file.readAsString();
                    log('從文件讀取的JSON數據長度: ${jsonContent.length}');
                    if (jsonContent.isEmpty) {
                      throw Exception("文件內容為空");
                    }
                  } catch (e) {
                    // web fallback
                    log('從文件讀取失敗: $e，使用 web fallback');
                    try {
                      final bytes = result.files.single.bytes;
                      if (bytes == null || bytes.isEmpty) {
                        throw Exception("檔案内容為空");
                      }
                      jsonContent = utf8.decode(bytes);
                      log('從 bytes 讀取的JSON數據長度: ${jsonContent.length}');
                      if (jsonContent.isEmpty) {
                        throw Exception("解碼後内容為空");
                      }
                    } catch (e) {
                      log('web fallback 也失敗了: $e');
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("無法讀取文件內容: $e"),
                          showCloseIcon: true,
                        ),
                      );
                      return;
                    }
                  }
                }

                try {
                  log('開始處理導入的JSON數據...');

                  // 檢查內容是否為空
                  if (jsonContent.trim().isEmpty) {
                    log('讀取的內容為空');
                    throw Exception("文件內容為空");
                  }

                  log('JSON內容預覽: ${jsonContent.length > 100 ? "${jsonContent.substring(0, 100)}..." : jsonContent}');

                  // 解析JSON數據
                  Map<String, dynamic> importedPrefs;
                  try {
                    final dynamic decoded = jsonDecode(jsonContent);
                    if (decoded is! Map<String, dynamic>) {
                      throw FormatException("JSON格式不正確，應為物件格式");
                    }
                    importedPrefs = decoded;
                  } catch (e) {
                    log('JSON解析失敗: $e');
                    log('嘗試讀取的內容: $jsonContent');
                    rethrow;
                  }

                  log('JSON解析成功，包含 ${importedPrefs.length} 個設置項');

                  // 覆蓋現有偏好設置
                  int importedCount = 0;
                  for (var entry in importedPrefs.entries) {
                    String key = entry.key;
                    dynamic valueData = entry.value;

                    if (valueData is Map && valueData.containsKey('type') && valueData.containsKey('value')) {
                      String type = valueData['type'];
                      dynamic value = valueData['value'];

                      try {
                        switch (type) {
                          case 'string':
                            await prefs.setString(key, value);
                            importedCount++;
                            break;
                          case 'bool':
                            await prefs.setBool(key, value);
                            importedCount++;
                            break;
                          case 'int':
                            await prefs.setInt(key, value);
                            importedCount++;
                            break;
                          case 'double':
                            await prefs.setDouble(key, value);
                            importedCount++;
                            break;
                          case 'stringList':
                            if (value is List) {
                              List<String> stringList = value.map((e) => e.toString()).toList();
                              await prefs.setStringList(key, stringList);
                              importedCount++;
                            }
                            break;
                        }
                      } catch (e) {
                        log('無法導入設置鍵: $key, 錯誤: $e');
                      }
                    }
                  }

                  log('成功導入 $importedCount 個設置項');

                  // 重置當前聊天狀態
                  messages = [];
                  chatUuid = null;

                  setState(() {});
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("設置導入成功，共導入 $importedCount 個設置項"),
                      showCloseIcon: true,
                    ),
                  );
                } catch (e, stackTrace) {
                  // 解析或導入失敗
                  log('JSON解析或導入失敗: $e');
                  log('錯誤堆棧: $stackTrace');
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("導入失敗：$e。請確保導入正確的DrAI設置文件。"),
                      showCloseIcon: true,
                      duration: const Duration(seconds: 8),
                    ),
                  );
                }
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
      exportChats: _exportPrefs,
      importChats: _importPrefs,
    );
  }
}
