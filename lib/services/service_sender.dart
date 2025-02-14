import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ollama_dart/ollama_dart.dart' as llama;
import 'package:dartx/dartx.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'service_haptic.dart';
import 'service_setter.dart';
import '../main.dart';
import 'package:flutter_opencc_ffi/flutter_opencc_ffi.dart';
/// 訊息發送服務
/// 處理與 AI 模型的通訊、訊息歷史記錄管理和對話標題生成
/// 簡體轉繁體（香港）轉換器實例
Converter converter = createConverter('s2hk');

/// 當前對話中的圖片列表
List<String> images = [];

/// 組裝聊天歷史記錄
/// @param addToSystem 可選的系統提示附加訊息
Future<List<llama.Message>> getHistory([String? addToSystem]) async {
  var system = prefs.getString("system") ?? "您是一位提供一般醫療資訊和指導的人工智慧醫生。您可以提供事實，提出常見病症的可能原因和治療方法，並提倡健康的習慣。然而，您無法取代專業的醫療建議、診斷或治療。始終提醒使用者諮詢合格的醫療保健提供者以獲得個人化護理。";
  if (prefs.getBool("noMarkdown") ?? false) {
    system += "\n您不得以任何方式使用 markdown 或任何其他格式語言！";
  }
  if (addToSystem != null) {
    system += "\n$addToSystem";
  }
  List<llama.Message> history = (prefs.getBool("useSystem") ?? true) ? [llama.Message(role: llama.MessageRole.system, content: system)] : [];
  List<llama.Message> history2 = [];
  images = [];
  for (var message in messages) {
    if (jsonDecode(jsonEncode(message))["text"] != null) {
      history2.add(llama.Message(
        role: (message.author.id == user.id) ? llama.MessageRole.user : llama.MessageRole.system,
        content: jsonDecode(jsonEncode(message))["text"],
        images: images.isNotEmpty ? images : null,
      ));
      images = [];
    } else {
      var uri = jsonDecode(jsonEncode(message))["uri"] as String;
      String content =
          uri.startsWith("data:image/png;base64,") ? uri.removePrefix("data:image/png;base64,") : base64.encode(await File(uri).readAsBytes());
      uri = uri.removePrefix("data:image/png;base64,");
      images.add(content);
    }
  }
  history.addAll(history2.reversed);
  return history;
}

/// 獲取指定對話的歷史記錄字符串形式
/// @param uuid 對話的唯一標識符
List getHistoryString([String? uuid]) {
  uuid ??= chatUuid!;
  List messages = [];
  for (var chat in prefs.getStringList("chats") ?? []) {
    if (jsonDecode(chat)["uuid"] == uuid) {
      messages = jsonDecode(jsonDecode(chat)["messages"]);
      break;
    }
  }
  if (messages.isNotEmpty && messages[0]["role"] == "system") {
    messages.removeAt(0);
  }
  for (var i = 0; i < messages.length; i++) {
    if (messages[i]["type"] == "image") {
      messages[i] = {"role": messages[i]["role"]!, "content": "<${messages[i]["role"]} inserted an image>"};
    }
  }
  return messages;
}

/// 使用AI生成對話標題
/// @param history 對話歷史記錄
/// @returns 生成的標題文字
Future<String> getTitleAi(List history) async {
  final generated = await (llama.OllamaClient(
    headers: (jsonDecode(prefs.getString("hostHeaders") ?? "{}") as Map).cast<String, String>(),
    baseUrl: "$host/api",
  ))
      .generateChatCompletion(
        request: llama.GenerateChatCompletionRequest(
          model: model!,
          messages: [
            const llama.Message(
              role: llama.MessageRole.system,
              content:
                  "為使用者提供的對話產生一個三到六個字的標題。如果對話中某個物件或人非常重要，也請將其放入標題中",
            ),
            llama.Message(role: llama.MessageRole.user, content: "```\n${jsonEncode(history)}\n```"),
          ],
          keepAlive: int.parse(prefs.getString("keepAlive") ?? "300"),
        ),
      )
      .timeout(Duration(seconds: (10.0 * (prefs.getDouble("timeoutMultiplier") ?? 1.0)).round()));
  var title = generated.message.content;
  title = title.replaceAll("\n", " ");
  var terms = ['"', "'", "*", "_", ".", ",", "!", "?", ":", ";", "(", ")", "[", "]", "{", "}"];
  for (var term in terms) {
    title = title.replaceAll(term, "");
  }
  title = title.replaceAll(RegExp(r'<.*?>', dotAll: true), "");
  if (title.split(":").length == 2) {
    title = title.split(":")[1];
  }
  while (title.contains("  ")) {
    title = title.replaceAll("  ", " ");
  }
  return title.trim();
}

/// 設置AI生成的對話標題
/// @param history 對話歷記錄
Future<void> setTitleAi(List history) async {
  try {
    var title = await getTitleAi(history);
    var chats = prefs.getStringList("chats") ?? [];
    for (var i = 0; i < chats.length; i++) {
      if (jsonDecode(chats[i])["uuid"] == chatUuid) {
        var chat = jsonDecode(chats[i]);
        chat["title"] = title;
        chats[i] = jsonEncode(chat);
        break;
      }
    }
    prefs.setStringList("chats", chats);
  } catch (_) {}
}

/// 發送訊息並處理AI回應
/// @param value 要發送的訊息內容
/// @param context 當前上下文
/// @param setState 狀態更新函數
/// @param onStream 串流回調函數
/// @param addToSystem 附加系統提示
/// @returns AI的回應文本
Future<String> send(
  String value,
  BuildContext context,
  Function setState, {
  void Function(String currentText, bool done)? onStream,
  String? addToSystem,
}) async {
  selectionHaptic();
  setState(() {
    sendable = false;
  });
  if (host == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.noHostSelected),
      showCloseIcon: true,
    ));
    if (onStream != null) {
      onStream("", true);
    }
    return "";
  }
  if (!chatAllowed || model == null) {
    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.noModelSelected),
        showCloseIcon: true,
      ));
    }
    if (onStream != null) {
      onStream("", true);
    }
    return "";
  }
  bool newChat = false;
  if (chatUuid == null) {
    newChat = true;
    chatUuid = const Uuid().v8();
    prefs.setStringList(
      "chats",
      (prefs.getStringList("chats") ?? []).append([
        jsonEncode({
          "title": AppLocalizations.of(context)!.newChatTitle,
          "uuid": chatUuid,
          "messages": [],
        })
      ]).toList(),
    );
  }
  var history = await getHistory(addToSystem);
  history.add(llama.Message(
    role: llama.MessageRole.user,
    content: value.trim(),
    images: images.isNotEmpty ? images : null,
  ));
  messages.insert(0, types.TextMessage(author: user, id: const Uuid().v8(), text: value.trim()));
  saveChat(chatUuid!, setState);
  setState(() {});
  chatAllowed = false;
  String text = "";
  String newId = const Uuid().v8();
  llama.OllamaClient client = llama.OllamaClient(
    headers: (jsonDecode(prefs.getString("hostHeaders") ?? "{}") as Map).cast<String, String>(),
    baseUrl: "$host/api",
  );
  try {
    if ((prefs.getString("requestType") ?? "stream") == "stream") {
      final stream = client
          .generateChatCompletionStream(
            request: llama.GenerateChatCompletionRequest(
              model: model!,
              messages: history,
              keepAlive: int.parse(prefs.getString("keepAlive") ?? "300"),
            ),
          )
          .timeout(Duration(seconds: (30.0 * (prefs.getDouble("timeoutMultiplier") ?? 1.0)).round()));
      await for (final res in stream) {
        text += res.message.content;
        messages.removeWhere((message) => message.id == newId);
        if (chatAllowed) return "";
        // 包裹 opencc 轉換以捕捉例外，避免連線中斷
        String translated;
        try {
          translated = converter.convert(text);
        } catch (error) {
          log("OpenCC conversion error: $error");
          translated = text;
        }
        messages.insert(0, types.TextMessage(author: assistant, id: newId, text: translated));
        if (onStream != null) {
          onStream(translated, false);
        }
        setState(() {});
        heavyHaptic();
      }
      // 串流回應完成後檢查
      messages.removeWhere((message) => message.id == newId);
      String finalText = text;
      if (finalText.trim().startsWith("<think>")) {
        finalText = finalText.replaceAll(RegExp(r"<think>.*?</think>", dotAll: true), "");
      }
      try {
        finalText = converter.convert(finalText);
      } catch (_) {}
      messages.insert(0, types.TextMessage(author: assistant, id: newId, text: finalText));
      // 記錄整體的 AI 回應（串流形式）
      log("AI response stream: $text");
    } else {
      llama.GenerateChatCompletionResponse request = await client
          .generateChatCompletion(
            request: llama.GenerateChatCompletionRequest(
              model: model!,
              messages: history,
              keepAlive: int.parse(prefs.getString("keepAlive") ?? "300"),
            ),
          )
          .timeout(Duration(seconds: (30.0 * (prefs.getDouble("timeoutMultiplier") ?? 1.0)).round()));
      if (chatAllowed) return "";
      String text = request.message.content;
      if (text.trim().startsWith("<think>")) {
        text = text.replaceAll(RegExp(r"<think>.*?</think>", dotAll: true), "");
      }
      // 記錄 AI 回應（非串流形式）
      log("AI response non-stream: $text");
      String s2hkText;
      try {
        s2hkText = converter.convert(text);
      } catch (error) {
        log("OpenCC conversion error: $error");
        s2hkText = text;
      }
      messages.insert(0, types.TextMessage(author: assistant, id: newId, text: s2hkText));
      setState(() {});
      heavyHaptic();
    }
  } catch (e) {
    messages.removeWhere((message) => message.id == newId);
    setState(() {
      chatAllowed = true;
      messages.removeAt(0);
      if (messages.isEmpty) {
        var chats = prefs.getStringList("chats") ?? [];
        chats.removeWhere((chat) => jsonDecode(chat)["uuid"] == chatUuid);
        prefs.setStringList("chats", chats);
        chatUuid = null;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.settingsHostInvalid("timeout")),
      showCloseIcon: true,
    ));
    return "";
  }
  if ((prefs.getString("requestType") ?? "stream") == "stream" && onStream != null) {
    onStream(text, true);
  }
  saveChat(chatUuid!, setState);
  if (newChat && (prefs.getBool("generateTitles") ?? true)) {
    await setTitleAi(getHistoryString());
    setState(() {});
  }
  setState(() {});
  chatAllowed = true;
  return text;
}
