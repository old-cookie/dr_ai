import 'dart:io';
import 'dart:convert';

import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:intl/intl.dart';

import '../main.dart';
import '../services/haptic.dart';
import '../services/desktop.dart';
import '../services/theme.dart';
import '../widgets/widgets_settings/widget_export.dart';

class ScreenSettingsExport extends StatefulWidget {
  const ScreenSettingsExport({super.key});

  @override
  State<ScreenSettingsExport> createState() => _ScreenSettingsExportState();
}

class _ScreenSettingsExportState extends State<ScreenSettingsExport> {
  Future<void> _exportChats(BuildContext context) async {
    selectionHaptic();
    var name = "ollama-export-${DateFormat('yyyy-MM-dd-H-m-s').format(DateTime.now())}.json";
    var content = jsonEncode(prefs!.getStringList("chats") ?? []);
    if (kIsWeb) {
      await _exportChatsWeb(name, content);
    } else {
      await _exportChatsDesktop(name, content);
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // ignore: use_build_context_synchronously
        content: Text(AppLocalizations.of(context)!.settingsExportChatsSuccess),
        showCloseIcon: true,
      ),
    );
  }

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

  Future<void> _exportChatsDesktop(String name, String content) async {
    String? path = "";
    try {
      path = (await file_selector.getSaveLocation(
        acceptedTypeGroups: [
          const file_selector.XTypeGroup(label: "DrAI File", extensions: ["json"]),
        ],
        suggestedName: name,
      ))
          ?.path;
    } catch (_) {
      path = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ["json"],
        fileName: name,
        bytes: utf8.encode(jsonEncode(prefs!.getStringList("chats") ?? [])),
      );
    }
    selectionHaptic();
    if (isDesktopPlatform()) {
      File(path!).writeAsString(content);
    }
  }

  Future<void> _importChats(BuildContext context) async {
    selectionHaptic();
    resetSystemNavigation(
      context,
      systemNavigationBarColor: Color.alphaBlend(Colors.black54, Theme.of(context).colorScheme.surface),
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.settingsImportChatsTitle),
          content: Text(AppLocalizations.of(context)!.settingsImportChatsDescription),
          actions: [
            TextButton(
              onPressed: () {
                selectionHaptic();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.settingsImportChatsCancel),
            ),
            TextButton(
              onPressed: () async {
                selectionHaptic();
                String content;
                try {
                  if (kIsWeb) {
                    throw Exception("web must use file picker");
                  }
                  file_selector.XFile? result = await file_selector.openFile(
                    acceptedTypeGroups: [
                      const file_selector.XTypeGroup(label: "Ollama App File", extensions: ["json"]),
                    ],
                  );
                  if (result == null) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    return;
                  }
                  content = await result.readAsString();
                } catch (_) {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ["json"],
                  );
                  if (result == null) {
                    // ignore: use_build_context_synchronously
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
                List<dynamic> tmpHistory = jsonDecode(content);
                List<String> history = tmpHistory.map((item) => item.toString()).toList();

                prefs!.setStringList("chats", history);

                messages = [];
                chatUuid = null;

                setState(() {});
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    // ignore: use_build_context_synchronously
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
    // ignore: use_build_context_synchronously
    resetSystemNavigation(context);
  }

  @override
  Widget build(BuildContext context) {
    return WidgetExport(
      exportChats: _exportChats,
      importChats: _importChats,
    );
  }
}