import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ollama_dart/ollama_dart.dart' as llama;
import 'package:dartx/dartx.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../main.dart';
import 'desktop.dart';
import 'haptic.dart';
import 'sender.dart';
import 'theme.dart';

/// 設置 AI 模型的對話框
/// 顯示可用模型列表供使用者選擇
void setModel(BuildContext context, Function setState) {
  List<String> models = []; // 存儲模型名稱
  List<String> modelsReal = []; // 存儲完整模型標識符
  List<bool> modal = []; // 存儲模型是否支援多模態
  int usedIndex = -1; // 當前選中的模型索引
  int oldIndex = -1; // 上一個選中的模型索引
  int addIndex = -1; // "添加模型"選項的索引
  bool loaded = false; // 是否已加載模型列表
  Function? setModalState;
  desktopTitleVisible = false;
  setState(() {});

  /// 載入模型列表
  void load() async {
    try {
      // 從 API 獲取模型列表
      var list =
          await llama.OllamaClient(headers: (jsonDecode(prefs!.getString("hostHeaders") ?? "{}") as Map).cast<String, String>(), baseUrl: "$host/api")
              .listModels()
              .timeout(Duration(seconds: (10.0 * (prefs!.getDouble("timeoutMultiplier") ?? 1.0)).round()));
      for (var i = 0; i < list.models!.length; i++) {
        models.add(list.models![i].model!.split(":")[0]);
        modelsReal.add(list.models![i].model!);
        modal.add((list.models![i].details!.families ?? []).contains("clip"));
      }
      addIndex = models.length;
      models.add(AppLocalizations.of(context)!.modelDialogAddModel);
      modelsReal.add(AppLocalizations.of(context)!.modelDialogAddModel);
      modal.add(false);
      for (var i = 0; i < modelsReal.length; i++) {
        if (modelsReal[i] == model) {
          usedIndex = i;
          oldIndex = usedIndex;
        }
      }
      if (prefs!.getBool("modelTags") == null) {
        List duplicateFinder = [];
        for (var model in models) {
          if (duplicateFinder.contains(model)) {
            prefs!.setBool("modelTags", true);
            break;
          } else {
            duplicateFinder.add(model);
          }
        }
      }
      loaded = true;
      setModalState!(() {});
    } catch (_) {
      setState(() {
        desktopTitleVisible = true;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsHostInvalid("timeout")), showCloseIcon: true));
    }
  }

  if (useModel) return;
  selectionHaptic();
  load();
  var content = StatefulBuilder(builder: (context, setLocalState) {
    setModalState = setLocalState;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!loaded) return;
          loaded = false;
          bool preload = false;
          if (usedIndex >= 0 && modelsReal[usedIndex] != model) {
            preload = true;
            if (prefs!.getBool("resetOnModelSelect") ?? true && allowMultipleChats) {
              messages = [];
              chatUuid = null;
            }
          }
          model = (usedIndex >= 0) ? modelsReal[usedIndex] : null;
          chatAllowed = !(model == null);
          multimodal = (usedIndex >= 0) ? modal[usedIndex] : false;
          if (model != null) {
            prefs?.setString("model", model!);
          } else {
            prefs?.remove("model");
          }
          prefs?.setBool("multimodal", multimodal);
          if (model != null && preload && int.parse(prefs!.getString("keepAlive") ?? "300") != 0 && (prefs!.getBool("preloadModel") ?? true)) {
            setLocalState(() {});
            try {
              await http
                  .post(
                    Uri.parse("$host/api/generate"),
                    headers:
                        {"Content-Type": "application/json", ...(jsonDecode(prefs!.getString("hostHeaders") ?? "{}") as Map)}.cast<String, String>(),
                    body: jsonEncode({"model": model!, "keep_alive": int.parse(prefs!.getString("keepAlive") ?? "300")}),
                  )
                  .timeout(Duration(seconds: (10.0 * (prefs!.getDouble("timeoutMultiplier") ?? 1.0)).round()));
            } catch (_) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsHostInvalid("timeout")), showCloseIcon: true));
              setState(() {
                model = null;
                chatAllowed = false;
              });
            }
            setState(() {
              desktopTitleVisible = true;
            });
            Navigator.of(context).pop();
          } else {
            setState(() {
              desktopTitleVisible = true;
            });
            try {
              Navigator.of(context).pop();
            } catch (_) {}
          }
        },
        child: Container(
            width: shouldUseDesktopLayout(context) ? null : double.infinity,
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: shouldUseDesktopLayout(context) ? 16 : 0),
            child: (!loaded)
                ? SizedBox(width: shouldUseDesktopLayout(context) ? 300 : double.infinity, child: const LinearProgressIndicator())
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: shouldUseDesktopLayout(context) ? 300 : double.infinity,
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: shouldUseDesktopLayout(context) ? 10.0 : 5.0,
                              runSpacing: isDesktopPlatform(includeWeb: true) ? 10.0 : 0.0,
                              alignment: WrapAlignment.center,
                              children: List<Widget>.generate(
                                models.length,
                                (int index) {
                                  return ChoiceChip(
                                    label: Row(mainAxisSize: MainAxisSize.min, children: [
                                      Text(models[index]),
                                      ((prefs!.getBool("modelTags") ?? false) && modelsReal[index].split(":").length > 1)
                                          ? Text(":${modelsReal[index].split(":")[1]}", style: const TextStyle(color: Colors.grey))
                                          : const SizedBox.shrink()
                                    ]),
                                    selected: usedIndex == index,
                                    avatar: (usedIndex == index)
                                        ? null
                                        : (addIndex == index)
                                            ? const Icon(Icons.add_rounded)
                                            : ((recommendedModels.contains(models[index]))
                                                ? const Icon(Icons.star_rounded)
                                                : ((modal[index]) ? const Icon(Icons.collections_rounded) : null)),
                                    checkmarkColor: (usedIndex == index && !(prefs?.getBool("useDeviceTheme") ?? false))
                                        ? ((MediaQuery.of(context).platformBrightness == Brightness.light)
                                            ? themeLight().colorScheme.secondary
                                            : themeDark().colorScheme.secondary)
                                        : null,
                                    labelStyle: (usedIndex == index && !(prefs?.getBool("useDeviceTheme") ?? false))
                                        ? TextStyle(
                                            color: (MediaQuery.of(context).platformBrightness == Brightness.light)
                                                ? themeLight().colorScheme.secondary
                                                : themeDark().colorScheme.secondary)
                                        : null,
                                    selectedColor: (prefs?.getBool("useDeviceTheme") ?? false)
                                        ? null
                                        : (MediaQuery.of(context).platformBrightness == Brightness.light)
                                            ? themeLight().colorScheme.primary
                                            : themeDark().colorScheme.primary,
                                    onSelected: (bool selected) {
                                      selectionHaptic();
                                      if (addIndex == index) {
                                        usedIndex = oldIndex;
                                        Navigator.of(context).pop();
                                        addModel(context, setState);
                                      }
                                      if (!chatAllowed && model != null) {
                                        return;
                                      }
                                      setLocalState(() {
                                        usedIndex = selected ? index : -1;
                                      });
                                    },
                                  );
                                },
                              ).toList(),
                            )))
                  ])));
  });
  if (isDesktopLayoutNotRequired(context)) {
    showDialog(
        context: context,
        builder: (context) {
          return Transform.translate(
            offset: isDesktopLayoutRequired(context) ? const Offset(289, 0) : const Offset(0, 0),
            child: Dialog(
                surfaceTintColor: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey[800] : null,
                alignment: isDesktopLayoutRequired(context) ? Alignment.topLeft : Alignment.topCenter,
                child: content),
          );
        });
  } else {
    showModalBottomSheet(context: context, builder: (context) => Container(child: content));
  }
}

/// 添加新的 AI 模型
/// 顯示輸入對話框讓使用者輸入模型名稱並下載
void addModel(BuildContext context, Function setState) async {
  var client = llama.OllamaClient(headers: (jsonDecode(prefs!.getString("hostHeaders") ?? "{}") as Map).cast<String, String>(), baseUrl: "$host/api");
  bool canceled = false;
  bool networkError = false;
  bool ratelimitError = false;
  bool alreadyExists = false;
  final String invalidText = AppLocalizations.of(context)!.modelDialogAddPromptInvalid;
  final networkErrorText = AppLocalizations.of(context)!.settingsHostInvalid("other");
  final timeoutErrorText = AppLocalizations.of(context)!.settingsHostInvalid("timeout");
  final ratelimitErrorText = AppLocalizations.of(context)!.settingsHostInvalid("ratelimit");
  final alreadyExistsText = AppLocalizations.of(context)!.modelDialogAddPromptAlreadyExists;
  final downloadSuccessText = AppLocalizations.of(context)!.modelDialogAddDownloadSuccess;
  final downloadFailedText = AppLocalizations.of(context)!.modelDialogAddDownloadFailed;
  var requestedModel = await prompt(
    context,
    title: AppLocalizations.of(context)!.modelDialogAddPromptTitle,
    description: AppLocalizations.of(context)!.modelDialogAddPromptDescription,
    placeholder: "llama3:latest",
    enableSuggestions: false,
    validator: (content) async {
      var model = content;
      model = model.removeSuffix(":latest");
      if (model == "") return false;
      canceled = false;
      networkError = false;
      ratelimitError = false;
      alreadyExists = false;
      try {
        var request = await client.listModels().timeout(Duration(seconds: (10.0 * (prefs!.getDouble("timeoutMultiplier") ?? 1.0)).round()));
        for (var element in request.models!) {
          var localModel = element.model!.removeSuffix(":latest");
          if (localModel == model) {
            alreadyExists = true;
          }
        }
        if (alreadyExists) return false;
      } catch (_) {
        networkError = true;
        return false;
      }
      var endpoint = "https://ollama.com/library/";
      if (kIsWeb) {
        if (!(prefs!.getBool("allowWebProxy") ?? false)) {
          bool returnValue = false;
          await showDialog(
              context: mainContext!,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.modelDialogAddAllowanceTitle),
                    content: SizedBox(
                      width: 640,
                      child: Text(AppLocalizations.of(context)!.modelDialogAddAllowanceDescription),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            canceled = true;
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.modelDialogAddAllowanceDeny)),
                      TextButton(
                          onPressed: () {
                            returnValue = true;
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.modelDialogAddAllowanceAllow))
                    ]);
              });
          if (!returnValue) return false;
          prefs!.setBool("allowWebProxy", true);
        }
        endpoint = "https://end.jhubi1.com/ollama-proxy/";
      }
      http.Response response;
      try {
        response =
            await http.get(Uri.parse("$endpoint$model")).timeout(Duration(seconds: (10.0 * (prefs!.getDouble("timeoutMultiplier") ?? 1.0)).round()));
      } catch (_) {
        networkError = true;
        return false;
      }
      if (response.statusCode == 200) {
        bool returnValue = false;
        resetSystemNavigation(mainContext!, systemNavigationBarColor: Color.alphaBlend(Colors.black54, Theme.of(mainContext!).colorScheme.surface));
        await showDialog(
            context: mainContext!,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.modelDialogAddAssuranceTitle(model)),
                  content: SizedBox(
                    width: 640,
                    child: Text(AppLocalizations.of(context)!.modelDialogAddAssuranceDescription(model)),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          canceled = true;
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.modelDialogAddAssuranceCancel)),
                    TextButton(
                        onPressed: () {
                          returnValue = true;
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.modelDialogAddAssuranceAdd))
                  ]);
            });
        resetSystemNavigation(mainContext!);
        return returnValue;
      }
      if (response.statusCode == 429) {
        ratelimitError = true;
      }
      return false;
    },
    validatorErrorCallback: (content) {
      if (networkError) return networkErrorText;
      if (ratelimitError) return ratelimitErrorText;
      if (alreadyExists) return alreadyExistsText;
      if (canceled) return null;
      return invalidText;
    },
  );
  if (requestedModel == "") return;
  requestedModel = requestedModel.removeSuffix(":latest");
  double? percent;
  Function? setDialogState;
  showModalBottomSheet(
      context: mainContext!,
      builder: (context) {
        return StatefulBuilder(builder: (context, setLocalState) {
          setDialogState = setLocalState;
          return PopScope(
              canPop: false,
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: shouldUseDesktopLayout(context) ? 16 : 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        percent == null
                            ? AppLocalizations.of(context)!.modelDialogAddDownloadPercentLoading
                            : AppLocalizations.of(context)!.modelDialogAddDownloadPercent((percent * 100).round().toString()),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 8)),
                      LinearProgressIndicator(value: percent),
                    ],
                  )));
        });
      });
  try {
    final stream = client
        .pullModelStream(request: llama.PullModelRequest(model: requestedModel))
        .timeout(Duration(seconds: (10.0 * (prefs!.getDouble("timeoutMultiplier") ?? 1.0)).round()));
    bool alreadyProgressed = false;
    await for (final res in stream) {
      double tmpPercent = ((res.completed ?? 0).toInt() / (res.total ?? 100).toInt());
      if ((tmpPercent * 100).round() == 0) {
        if (!alreadyProgressed) {
          percent = null;
        }
      } else {
        percent = tmpPercent;
        alreadyProgressed = true;
      }
      setDialogState!(() {});
    }
    if (prefs!.getBool("resetOnModelSelect") ?? true && allowMultipleChats) {
      messages = [];
      chatUuid = null;
    }
    model = requestedModel;
    if (model!.split(":").length == 1) {
      model = "$model:latest";
    }
    bool exists = false;
    try {
      var request = await client.listModels().timeout(Duration(seconds: (10.0 * (prefs!.getDouble("timeoutMultiplier") ?? 1.0)).round()));
      for (var element in request.models!) {
        if (element.model == model) {
          exists = true;
          multimodal = (element.details!.families ?? []).contains("clip");
        }
      }
      if (!exists) {
        throw Exception();
      }
    } catch (_) {
      setState(() {
        model = null;
        multimodal = false;
        chatAllowed = false;
      });
      prefs?.remove("model");
      prefs?.setBool("multimodal", multimodal);
      Navigator.of(mainContext!).pop();
      if (!exists) {
        ScaffoldMessenger.of(mainContext!).showSnackBar(SnackBar(content: Text(downloadFailedText), showCloseIcon: true));
      } else {
        ScaffoldMessenger.of(mainContext!).showSnackBar(SnackBar(content: Text(timeoutErrorText), showCloseIcon: true));
      }
      return;
    }
    prefs?.setString("model", model!);
    prefs?.setBool("multimodal", multimodal);
    setState(() {
      chatAllowed = true;
    });
    Navigator.of(mainContext!).pop();
    ScaffoldMessenger.of(mainContext!).showSnackBar(SnackBar(content: Text(downloadSuccessText), showCloseIcon: true));
  } catch (_) {
    Navigator.of(mainContext!).pop();
    ScaffoldMessenger.of(mainContext!).showSnackBar(SnackBar(content: Text(downloadFailedText), showCloseIcon: true));
  }
}

/// 儲存當前聊天記錄
/// @param uuid 聊天的唯一標識符
void saveChat(String uuid, Function setState) async {
  int index = -1;
  for (var i = 0; i < (prefs!.getStringList("chats") ?? []).length; i++) {
    if (jsonDecode((prefs!.getStringList("chats") ?? [])[i])["uuid"] == uuid) {
      index = i;
    }
  }
  if (index == -1) return;
  List<Map<String, String>> history = [];
  for (var i = 0; i < messages.length; i++) {
    if ((jsonDecode(jsonEncode(messages[i])) as Map).containsKey("text")) {
      history.add({"role": (messages[i].author == user) ? "user" : "assistant", "content": jsonDecode(jsonEncode(messages[i]))["text"]});
    } else {
      var uri = jsonDecode(jsonEncode(messages[i]))["uri"] as String;
      String content =
          (uri.startsWith("data:image/png;base64,")) ? uri.removePrefix("data:image/png;base64,") : base64.encode(await File(uri).readAsBytes());
      history.add({
        "role": (messages[i].author == user) ? "user" : "assistant",
        "type": "image",
        "name": (messages[i] as types.ImageMessage).name,
        "size": (messages[i] as types.ImageMessage).size.toString(),
        "content": content
      });
    }
  }
  if (messages.isEmpty && uuid == chatUuid) {
    for (var i = 0; i < (prefs!.getStringList("chats") ?? []).length; i++) {
      if (jsonDecode((prefs!.getStringList("chats") ?? [])[i])["uuid"] == chatUuid) {
        List<String> tmp = prefs!.getStringList("chats")!;
        tmp.removeAt(i);
        prefs!.setStringList("chats", tmp);
        chatUuid = null;
        return;
      }
    }
  }
  if (jsonDecode((prefs!.getStringList("chats") ?? [])[index])["messages"].length >= 1) {
    if (jsonDecode(jsonDecode((prefs!.getStringList("chats") ?? [])[index])["messages"])[0]["role"] == "system") {
      history.add({"role": "system", "content": jsonDecode(jsonDecode((prefs!.getStringList("chats") ?? [])[index])["messages"])[0]["content"]});
    }
  } else {
    var system = prefs?.getString("system") ?? "You are a helpful assistant";
    if (prefs!.getBool("noMarkdown") ?? false) {
      system += " You must not use markdown or any other formatting language in any way!";
    }
    history.add({"role": "system", "content": system});
  }
  history = history.reversed.toList();
  List<String> tmp = prefs!.getStringList("chats") ?? [];
  tmp.removeAt(index);
  tmp.insert(
      0,
      jsonEncode({
        "title": jsonDecode((prefs!.getStringList("chats") ?? [])[index])["title"],
        "uuid": uuid,
        "model": model,
        "messages": jsonEncode(history)
      }));
  prefs!.setStringList("chats", tmp);
  setState(() {});
}

/// 載入指定的聊天記錄
/// @param uuid 要載入的聊天記錄的唯一標識符
void loadChat(String uuid, Function setState) {
  int index = -1;
  for (var i = 0; i < (prefs!.getStringList("chats") ?? []).length; i++) {
    if (jsonDecode((prefs!.getStringList("chats") ?? [])[i])["uuid"] == uuid) {
      index = i;
    }
  }
  if (index == -1) return;
  messages = [];
  model = null;
  setState(() {});
  var history = jsonDecode(jsonDecode((prefs!.getStringList("chats") ?? [])[index])["messages"]);
  for (var i = 0; i < history.length; i++) {
    if (history[i]["role"] != "system") {
      if ((history[i] as Map).containsKey("type") && history[i]["type"] == "image") {
        messages.insert(
            0,
            types.ImageMessage(
                author: (history[i]["role"] == "user") ? user : assistant,
                id: const Uuid().v4(),
                name: history[i]["name"],
                size: int.parse(history[i]["size"]),
                uri: "data:image/png;base64,${history[i]["content"]}"));
      } else {
        messages.insert(
            0, types.TextMessage(author: (history[i]["role"] == "user") ? user : assistant, id: const Uuid().v4(), text: history[i]["content"]));
      }
    }
  }
  model = jsonDecode((prefs!.getStringList("chats") ?? [])[index])["model"];
  setState(() {});
}

/// 刪除聊天記錄的確認對話框
/// @param context 上下文
/// @param setState 狀態更新函數
/// @param takeAction 是否執行刪除操作
/// @param additionalCondition 額外條件
/// @param uuid 要刪除的聊天記錄的唯一標識符
/// @param popSidebar 是否關閉側邊欄
Future<bool> deleteChatDialog(BuildContext context, Function setState,
    {bool takeAction = true, bool? additionalCondition, String? uuid, bool popSidebar = false}) async {
  additionalCondition ??= true;
  uuid ??= chatUuid;
  bool returnValue = false;
  void delete(BuildContext context) {
    returnValue = true;
    if (takeAction) {
      for (var i = 0; i < (prefs!.getStringList("chats") ?? []).length; i++) {
        if (jsonDecode((prefs!.getStringList("chats") ?? [])[i])["uuid"] == uuid) {
          List<String> tmp = prefs!.getStringList("chats")!;
          tmp.removeAt(i);
          prefs!.setStringList("chats", tmp);
          break;
        }
      }
      if (chatUuid == uuid) {
        messages = [];
        chatUuid = null;
        if (!isDesktopLayoutRequired(context) && Navigator.of(context).canPop() && popSidebar) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  if ((prefs!.getBool("askBeforeDeletion") ?? false) && additionalCondition) {
    resetSystemNavigation(context, systemNavigationBarColor: Color.alphaBlend(Colors.black54, Theme.of(context).colorScheme.surface));
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setLocalState) {
            return AlertDialog(
                title: Text(AppLocalizations.of(context)!.deleteDialogTitle),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(AppLocalizations.of(context)!.deleteDialogDescription),
                ]),
                actions: [
                  TextButton(
                      onPressed: () {
                        selectionHaptic();
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.deleteDialogCancel)),
                  TextButton(
                      onPressed: () {
                        selectionHaptic();
                        Navigator.of(context).pop();
                        delete(context);
                      },
                      child: Text(AppLocalizations.of(context)!.deleteDialogDelete))
                ]);
          });
        });
    resetSystemNavigation(context);
  } else {
    delete(context);
  }
  setState(() {});
  return returnValue;
}

/// 通用輸入對話框
/// @param context 上下文
/// @param description 描述文字
/// @param value 預設值
/// @param title 標題
/// @param keyboard 鍵盤類型
/// @param validator 輸入驗證函數
Future<String> prompt(BuildContext context,
    {String description = "",
    String value = "",
    String title = "",
    String? valueIfCanceled,
    TextInputType keyboard = TextInputType.text,
    bool autocorrect = true,
    Iterable<String> autofillHints = const [],
    bool enableSuggestions = true,
    Icon? prefixIcon,
    int maxLines = 1,
    String? uuid,
    Future<bool> Function(String content)? validator,
    String? validatorError,
    String? Function(String content)? validatorErrorCallback,
    String? placeholder,
    bool prefill = true}) async {
  var returnText = (valueIfCanceled != null) ? valueIfCanceled : value;
  final TextEditingController controller = TextEditingController(text: prefill ? value : "");
  bool loading = false;
  String? error;
  await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setLocalState) {
          void submit() async {
            selectionHaptic();
            if (validator != null) {
              setLocalState(() {
                error = null;
                loading = true;
              });
              bool valid = await validator(controller.text);
              setLocalState(() {
                loading = false;
              });
              if (!valid) {
                setLocalState(() {
                  if (validatorError != null) {
                    error = validatorError;
                  } else if (validatorErrorCallback != null) {
                    error = validatorErrorCallback(controller.text);
                  } else {
                    error = null;
                  }
                });
                return;
              }
            }
            returnText = controller.text;
            Navigator.of(context).pop();
          }

          return PopScope(
              child: Container(
                  padding: EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: isDesktopPlatform(includeWeb: true) ? 12 : MediaQuery.of(context).viewInsets.bottom),
                  width: double.infinity,
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    (title != "") ? Text(title, style: const TextStyle(fontWeight: FontWeight.bold)) : const SizedBox.shrink(),
                    (title != "") ? const Divider() : const SizedBox.shrink(),
                    (description != "") ? Text(description) : const SizedBox.shrink(),
                    const SizedBox(height: 8),
                    TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: keyboard,
                        autocorrect: autocorrect,
                        autofillHints: autofillHints,
                        enableSuggestions: enableSuggestions,
                        maxLines: maxLines,
                        onSubmitted: (_) => submit(),
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: placeholder,
                            errorText: error,
                            suffixIcon: IconButton(
                                enableFeedback: false,
                                tooltip: AppLocalizations.of(context)!.tooltipSave,
                                onPressed: submit,
                                icon: const Icon(Icons.save_rounded)),
                            prefixIcon: (title == AppLocalizations.of(context)!.dialogEnterNewTitle && uuid != null)
                                ? IconButton(
                                    enableFeedback: false,
                                    tooltip: AppLocalizations.of(context)!.tooltipLetAIThink,
                                    onPressed: () async {
                                      selectionHaptic();
                                      setLocalState(() {
                                        loading = true;
                                      });
                                      try {
                                        var title = await getTitleAi(getHistoryString(uuid));
                                        controller.text = title;
                                        setLocalState(() {
                                          loading = false;
                                        });
                                      } catch (_) {
                                        try {
                                          setLocalState(() {
                                            loading = false;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(AppLocalizations.of(context)!.settingsHostInvalid("timeout")), showCloseIcon: true));
                                        } catch (_) {}
                                      }
                                    },
                                    icon: const Icon(Icons.auto_awesome_rounded))
                                : prefixIcon)),
                    SizedBox(height: 3, child: (loading) ? const LinearProgressIndicator() : const SizedBox.shrink()),
                    (MediaQuery.of(context).viewInsets.bottom != 0) ? const SizedBox(height: 16) : const SizedBox.shrink()
                  ])));
        });
      });
  return returnText;
}
