import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'worker/haptic.dart';
import 'widgets/widget_screen_settings.dart';


class ScreenSettings extends StatefulWidget {
  const ScreenSettings({super.key});

  @override
  State<ScreenSettings> createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  late SharedPreferences prefs;
  bool useHost = false;
  String fixedHost = '';
  String? host;

  final hostInputController = TextEditingController();
  bool hostLoading = false;
  bool hostInvalidUrl = false;
  bool hostInvalidHost = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      useHost = prefs.getBool('useHost') ?? false;
      fixedHost = prefs.getString('fixedHost') ?? '';
      host = prefs.getString('host') ?? 'http://localhost:11434';
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

  void checkHost() async {
    setState(() {
      hostLoading = true;
      hostInvalidUrl = false;
      hostInvalidHost = false;
    });
    var tmpHost = hostInputController.text.trim().replaceAll(RegExp(r'/$'), '').trim();

    if (tmpHost.isEmpty || !Uri.parse(tmpHost).isAbsolute) {
      setState(() {
        hostInvalidUrl = true;
        hostLoading = false;
      });
      return;
    }

    http.Response? request;
    try {
      var client = http.Client();
      final requestBase = http.Request("get", Uri.parse(tmpHost))
        ..headers.addAll(
          (jsonDecode(prefs.getString("hostHeaders") ?? "{}") as Map).cast<String, String>(),
        )
        ..followRedirects = false;
      request = await http.Response.fromStream(
        await requestBase.send().timeout(
              Duration(milliseconds: (5000.0 * (prefs.getDouble("timeoutMultiplier") ?? 1.0)).round()),
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
    if ((request.statusCode == 200 && request.body == "Ollama is running") || (Uri.parse(tmpHost).toString() == fixedHost)) {
      setState(() {
        hostLoading = false;
        host = tmpHost;
        if (hostInputController.text != host! && (Uri.parse(tmpHost).toString() != fixedHost)) {
          hostInputController.text = host!;
        }
      });
      prefs.setString("host", host!);
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
    return WidgetScreenSettings(
      hostInputController: hostInputController,
      hostLoading: hostLoading,
      hostInvalidUrl: hostInvalidUrl,
      hostInvalidHost: hostInvalidHost,
      checkHost: checkHost,
      useHost: useHost,
      prefs: prefs,
    );
  }
}