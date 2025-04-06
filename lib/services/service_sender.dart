import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:ollama_dart/ollama_dart.dart' as llama;
import 'package:dart_openai/dart_openai.dart';
import 'package:dartx/dartx.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'service_haptic.dart';
import 'service_setter.dart';
import 'service_demo.dart';
import '../main.dart';

/// 當前對話中的圖片列表
List<String> images = [];

/// 組裝聊天歷史記錄
/// @param addToSystem 可選的系統提示附加訊息
Future<List<llama.Message>> getHistory([String? addToSystem]) async {
  var system = prefs.getString("system") ?? "您是一位在臨床推理、診斷和治療計劃方面擁有高級知識的醫學專家。必需使用**繁體中文**回答。由造成原因、自行解決方案，尋求專業建議三個方向回答在回答之前，請仔細思考問題，確保回答 合乎邏輯且準確。";
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

/// 組裝聊天歷史記錄 - OpenAI格式
/// @param addToSystem 可選的系統提示附加訊息
Future<List<OpenAIChatCompletionChoiceMessageModel>> getOpenAIHistory([String? addToSystem]) async {
  var system = prefs.getString("system") ?? "您是一位在臨床推理、診斷和治療計劃方面擁有高級知識的醫學專家。必需使用**繁體中文**回答。由造成原因、自行解決方案，尋求專業建議三個方向回答在回答之前，請仔細思考問題，確保回答 合乎邏輯且準確。";
  if (prefs.getBool("noMarkdown") ?? false) {
    system += "\n您不得以任何方式使用 markdown 或任何其他格式語言！";
  }
  if (addToSystem != null) {
    system += "\n$addToSystem";
  }
  
  List<OpenAIChatCompletionChoiceMessageModel> history = (prefs.getBool("useSystem") ?? true) 
    ? [OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(system)]
      )] 
    : [];
    
  List<OpenAIChatCompletionChoiceMessageModel> historyMessages = [];
  List<String> imageUrls = [];
  
  for (var message in messages) {
    if (jsonDecode(jsonEncode(message))["text"] != null) {
      List<OpenAIChatCompletionChoiceMessageContentItemModel> contentItems = [];
      
      // 添加文本內容
      contentItems.add(OpenAIChatCompletionChoiceMessageContentItemModel.text(
        jsonDecode(jsonEncode(message))["text"]
      ));
      
      // 如果有圖片，添加圖片內容
      if (imageUrls.isNotEmpty) {
        for (var imageUrl in imageUrls) {
          contentItems.add(
            OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
              imageUrl
            )
          );
        }
        imageUrls = [];
      }
      
      historyMessages.add(OpenAIChatCompletionChoiceMessageModel(
        role: (message.author.id == user.id) 
          ? OpenAIChatMessageRole.user 
          : OpenAIChatMessageRole.assistant,
        content: contentItems
      ));
    } else {
      // 處理圖片消息
      var uri = jsonDecode(jsonEncode(message))["uri"] as String;
      if (uri.startsWith("data:image/png;base64,")) {
        // 對於OpenAI API來說，我們需要提供圖片URL或base64格式
        // 如果是base64編碼的圖片，將其存儲到列表中，等待附加到下一條消息
        imageUrls.add(uri);
      } else {
        // 對於本地圖片文件，需要讀取並轉換為base64
        String base64Image = "data:image/png;base64,${base64.encode(await File(uri).readAsBytes())}";
        imageUrls.add(base64Image);
      }
    }
  }
  
  // 將消息按照時間順序添加到歷史記錄中
  history.addAll(historyMessages.reversed);
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
              content: "為使用者提供的對話產生一個三到六個字的標題。如果對話中某個物件或人非常重要，也請將其放入標題中",
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

  // 檢查是否啟用演示模式
  final bool demoModeEnabled = prefs.getBool("demoModeEnabled") ?? false;

  if (demoModeEnabled) {
    // 演示模式處理邏輯
    String newId = const Uuid().v8();
    messages.insert(0, types.TextMessage(author: user, id: const Uuid().v8(), text: value.trim()));
    setState(() {});

    // 顯示"思考中"消息
    messages.insert(0, types.TextMessage(author: assistant, id: newId, text: "🤔 處理中..."));
    setState(() {});

    // 延遲一小段時間模擬處理過程
    await Future.delayed(const Duration(milliseconds: 800));

    // 獲取演示回應
    String response = await DemoService.processDemoMessage(value);

    // 更新回應消息
    messages.removeWhere((message) => message.id == newId);
    messages.insert(0, types.TextMessage(author: assistant, id: const Uuid().v8(), text: response));

    if (onStream != null) {
      onStream(response, true);
    }

    setState(() {
      chatAllowed = true;
      sendable = true;
    });

    if (chatUuid != null) {
      saveChat(chatUuid!, setState);
    }

    heavyHaptic();
    return response;
  }

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
      String currentResponse = "";
      String displayText = "";
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
        try {
          currentResponse += res.message.content;
          displayText = currentResponse;
          if (displayText.startsWith("<think>")) {
            int endIndex = displayText.indexOf("</think>");
            if (endIndex != -1) {
              // 顯示思考後的內容
              displayText = displayText.substring(endIndex + "</think>".length).trim();
            } else {
              // 顯示思考中提示
              displayText = "🤔 AI正在思考中...";
            }
          }

          messages.removeWhere((message) => message.id == newId);
          if (chatAllowed) return "";

          messages.insert(0, types.TextMessage(author: assistant, id: newId, text: displayText));

          if (onStream != null) {
            onStream(displayText, false);
          }
          setState(() {});
          heavyHaptic();
        } catch (streamError) {
          log("Stream error: $streamError");
          continue;
        }
      }

      if (currentResponse.isEmpty) {
        throw Exception("Empty response from server");
      }

      // 串流回應完成後檢查
      messages.removeWhere((message) => message.id == newId);
      String finalText = currentResponse;
      if (finalText.trim().startsWith("<think>")) {
        finalText = finalText.replaceAll(RegExp(r"<think>.*?</think>", dotAll: true), "");
      }
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
      // 處理思考過程標記
      if (text.startsWith("<think>")) {
        int endIndex = text.indexOf("</think>");
        if (endIndex != -1) {
          text = text.substring(endIndex + "</think>".length).trim();
        }
      }
      // 記錄 AI 回應（非串流形式）
      log("AI response non-stream: $text");
      messages.insert(0, types.TextMessage(author: assistant, id: newId, text: text));
      setState(() {});
      heavyHaptic();
    }
  } catch (e) {
    log("Connection error: $e");
    messages.removeWhere((message) => message.id == newId);
    setState(() {
      chatAllowed = true;
      if (messages.isNotEmpty) {
        messages.removeAt(0);
      }
      if (messages.isEmpty) {
        var chats = prefs.getStringList("chats") ?? [];
        chats.removeWhere((chat) => jsonDecode(chat)["uuid"] == chatUuid);
        prefs.setStringList("chats", chats);
        chatUuid = null;
      }
    });

    // 顯示更具體的錯誤訊息
    String errorMessage = e.toString().contains("timeout")
        ? AppLocalizations.of(context)!.settingsHostInvalid("timeout")
        : AppLocalizations.of(context)!.settingsHostInvalid("connection");

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage),
      showCloseIcon: true,
      duration: const Duration(seconds: 5),
    ));

    if (onStream != null) {
      onStream("", true);
    }
    return "";
  }

  // 確保在完成後重置狀態
  setState(() {
    chatAllowed = true;
  });

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

/// 使用 OpenAI API 發送訊息並處理回應
/// @param value 要發送的訊息內容
/// @param context 當前上下文
/// @param setState 狀態更新函數
/// @param onStream 串流回調函數
/// @param addToSystem 附加系統提示
/// @returns AI的回應文本
Future<String> sendOpenAI(
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

  // 檢查 OpenAI API Key 是否已設置
  final String? apiKey = prefs.getString("openai_api_key");
  if (apiKey == null || apiKey.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("需要設置 OpenAI API 金鑰"),
      showCloseIcon: true,
    ));
    if (onStream != null) {
      onStream("", true);
    }
    setState(() {
      sendable = true;
      chatAllowed = true;
    });
    return "";
  }

  // 初始化 OpenAI SDK
  OpenAI.apiKey = apiKey;
  final String? baseUrl = prefs.getString("openai_base_url");
  if (baseUrl != null && baseUrl.isNotEmpty) {
    OpenAI.baseUrl = baseUrl;
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

  // 獲取 OpenAI 格式的歷史記錄
  var history = await getOpenAIHistory(addToSystem);
  
  // 添加用戶消息
  List<OpenAIChatCompletionChoiceMessageContentItemModel> contentItems = [];
  contentItems.add(OpenAIChatCompletionChoiceMessageContentItemModel.text(value.trim()));
  
  // 處理圖片
  if (images.isNotEmpty) {
    for (String img in images) {
      String imageData = img.startsWith("data:image/png;base64,") 
          ? img 
          : "data:image/png;base64,$img";
      contentItems.add(
        OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
          imageData
        )
      );
    }
    images = [];
  }
  
  // 添加用戶消息到歷史記錄
  history.add(OpenAIChatCompletionChoiceMessageModel(
    role: OpenAIChatMessageRole.user,
    content: contentItems
  ));
  
  // 添加用戶消息到UI
  messages.insert(0, types.TextMessage(author: user, id: const Uuid().v8(), text: value.trim()));
  saveChat(chatUuid!, setState);
  setState(() {});
  
  // 設置AI回應暫存ID
  chatAllowed = false;
  String text = "";
  String newId = const Uuid().v8();
  
  try {
    // 獲取選定的 OpenAI 模型
    final String selectedModel = prefs.getString("openai_model") ?? "gpt-4o";
    
    // 決定是使用串流還是非串流模式
    if ((prefs.getString("requestType") ?? "stream") == "stream") {
      // 串流模式
      String currentResponse = "";
      String displayText = "";
      
      // 創建串流請求
      final stream = OpenAI.instance.chat.createStream(
        model: selectedModel,
        messages: history,
        temperature: prefs.getDouble("openai_temperature") ?? 0.7,
        maxTokens: int.tryParse(prefs.getString("openai_max_tokens") ?? "2000"),
      );
      
      // 處理串流回應
      await for (final res in stream) {
        try {
          if (res.choices.first.delta.content?.isNotEmpty ?? false) {
            // 檢查 content 是否為 List 類型
            var deltaContent = res.choices.first.delta.content;
            if (deltaContent is String) {
              currentResponse += deltaContent as String;
            } else if (deltaContent is List && deltaContent!.isNotEmpty) {
              // 處理 List 類型的 content
              for (var item in deltaContent) {
                if (item?.type == 'text' && item?.text != null) {
                  currentResponse += item?.text as String;
                }
              }
            }
            
            displayText = currentResponse;
            
            // 處理思考標記
            if (displayText.startsWith("<think>")) {
              int endIndex = displayText.indexOf("</think>");
              if (endIndex != -1) {
                // 顯示思考後的內容
                displayText = displayText.substring(endIndex + "</think>".length).trim();
              } else {
                // 顯示思考中提示
                displayText = "🤔 AI正在思考中...";
              }
            }
            
            // 更新UI顯示
            messages.removeWhere((message) => message.id == newId);
            if (chatAllowed) return "";
            
            messages.insert(0, types.TextMessage(author: assistant, id: newId, text: displayText));
            
            if (onStream != null) {
              onStream(displayText, false);
            }
            setState(() {});
            heavyHaptic();
          }
        } catch (streamError) {
          log("OpenAI stream error: $streamError");
          continue;
        }
      }
      
      if (currentResponse.isEmpty) {
        throw Exception("Empty response from OpenAI");
      }
      
      // 串流回應完成後處理
      messages.removeWhere((message) => message.id == newId);
      String finalText = currentResponse;
      
      if (finalText.trim().startsWith("<think>")) {
        finalText = finalText.replaceAll(RegExp(r"<think>.*?</think>", dotAll: true), "");
      }
      
      messages.insert(0, types.TextMessage(author: assistant, id: newId, text: finalText));
      text = finalText;
      
      // 記錄回應
      log("OpenAI response stream: $text");
      
    } else {
      // 非串流模式
      messages.insert(0, types.TextMessage(author: assistant, id: newId, text: "🤔 處理中..."));
      setState(() {});
      
      // 發送請求
      final response = await OpenAI.instance.chat.create(
        model: selectedModel,
        messages: history,
        temperature: prefs.getDouble("openai_temperature") ?? 0.7,
        maxTokens: int.tryParse(prefs.getString("openai_max_tokens") ?? "2000"),
      ).timeout(Duration(seconds: (30.0 * (prefs.getDouble("timeoutMultiplier") ?? 1.0)).round()));
      
      if (chatAllowed) return "";
      
      // 獲取回應文本
      final contentList = response.choices.first.message.content;
      if (contentList != null && contentList.isNotEmpty) {
        // 檢查第一個內容項目是否為文本類型
        final firstItem = contentList.first;
        if (firstItem.type == 'text') {  // 直接使用字串檢查類型
          text = firstItem.text ?? "";
        } else {
          text = "無法解析回應內容 (非文本類型)";
        }
      } else {
        text = "無法解析回應內容 (空回應)";
      }
      
      // 處理思考過程標記
      if (text.startsWith("<think>")) {
        int endIndex = text.indexOf("</think>");
        if (endIndex != -1) {
          text = text.substring(endIndex + "</think>".length).trim();
        }
      }
      
      // 記錄AI回應
      log("OpenAI response non-stream: $text");
      
      // 更新UI
      messages.removeWhere((message) => message.id == newId);
      messages.insert(0, types.TextMessage(author: assistant, id: newId, text: text));
      setState(() {});
      heavyHaptic();
    }
    
  } catch (e) {
    // 處理錯誤
    log("OpenAI error: $e");
    
    messages.removeWhere((message) => message.id == newId);
    setState(() {
      chatAllowed = true;
      if (messages.isNotEmpty) {
        messages.removeAt(0);
      }
      if (messages.isEmpty) {
        var chats = prefs.getStringList("chats") ?? [];
        chats.removeWhere((chat) => jsonDecode(chat)["uuid"] == chatUuid);
        prefs.setStringList("chats", chats);
        chatUuid = null;
      }
    });
    
    // 顯示錯誤訊息
    String errorMessage = e.toString().contains("timeout")
        ? "連接逾時，請檢查網絡或API設置"
        : "連接錯誤: ${e.toString()}";
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage),
      showCloseIcon: true,
      duration: const Duration(seconds: 5),
    ));
    
    if (onStream != null) {
      onStream("", true);
    }
    return "";
  }
  
  // 確保在完成後重置狀態
  setState(() {
    chatAllowed = true;
    sendable = true;
  });
  
  if ((prefs.getString("requestType") ?? "stream") == "stream" && onStream != null) {
    onStream(text, true);
  }
  
  saveChat(chatUuid!, setState);
  
  if (newChat && (prefs.getBool("generateTitles") ?? true)) {
    await setTitleAi(getHistoryString());
    setState(() {});
  }
  
  return text;
}
