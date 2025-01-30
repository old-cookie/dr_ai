import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';

import '../../main.dart';
import '../../services/desktop.dart';
import '../../widgets/widgets_units/widget_button.dart';


class WidgetExport extends StatelessWidget {
  final Future<void> Function(BuildContext) exportChats;
  final Future<void> Function(BuildContext) importChats;

  const WidgetExport({
    super.key,
    required this.exportChats,
    required this.importChats,
  });

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsTitleExport),
              Expanded(child: SizedBox(height: 200, child: MoveWindow())),
            ],
          ),
          actions: getDesktopControlsActions(context),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      widgetButton(
                        AppLocalizations.of(context)!.settingsExportChats,
                        Icons.upload_rounded,
                        () => exportChats(context),
                      ),
                      if (allowMultipleChats)
                        widgetButton(
                          AppLocalizations.of(context)!.settingsImportChats,
                          Icons.download_rounded,
                          () => importChats(context),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                widgetButton(
                  AppLocalizations.of(context)!.settingsExportInfo,
                  Icons.info_rounded,
                  null,
                  color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary),
                ),
                widgetButton(
                  AppLocalizations.of(context)!.settingsExportWarning,
                  Icons.warning_rounded,
                  null,
                  color: Colors.orange.harmonizeWith(Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}