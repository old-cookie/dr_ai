import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../worker/haptic.dart';
import '../../worker/desktop.dart';
import '../widgets_units/widget_toggle.dart';
import '../widgets_units/widget_button.dart';

class WidgetBehavior extends StatelessWidget {
  final TextEditingController systemInputController;
  final bool useSystem;
  final bool noMarkdown;
  final Function(bool) onUseSystemChanged;
  final Function(bool) onNoMarkdownChanged;
  final Function() onSystemMessageSaved;

  const WidgetBehavior({
    super.key,
    required this.systemInputController,
    required this.useSystem,
    required this.noMarkdown,
    required this.onUseSystemChanged,
    required this.onNoMarkdownChanged,
    required this.onSystemMessageSaved,
  });

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Theme.of(context).colorScheme.surface,
      child: Scaffold(
          appBar: AppBar(
              title: Row(
                  children: [Text(AppLocalizations.of(context)!.settingsTitleBehavior), Expanded(child: SizedBox(height: 200, child: MoveWindow()))]),
              actions: desktopControlsActions(context)),
          body: Center(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(children: [
                  Expanded(
                    child: ListView(children: [
                      const SizedBox(height: 8),
                      TextField(
                          controller: systemInputController,
                          keyboardType: TextInputType.multiline,
                          maxLines: desktopLayoutNotRequired(context) ? 5 : 2,
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.settingsSystemMessage,
                              alignLabelWithHint: true,
                              hintText: "You are a helpful assistant",
                              suffixIcon: IconButton(
                                enableFeedback: false,
                                tooltip: AppLocalizations.of(context)!.tooltipSave,
                                onPressed: onSystemMessageSaved,
                                icon: const Icon(Icons.save_rounded),
                              ),
                              border: const OutlineInputBorder())),
                      const SizedBox(height: 16),
                      widgetToggle(
                          context,
                          AppLocalizations.of(context)!.settingsUseSystem,
                          useSystem,
                          onUseSystemChanged,
                          icon: const Icon(Icons.info_rounded, color: Colors.grey),
                          iconAfterwards: true,
                          onLongTap: () {
                            selectionHaptic();
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.settingsUseSystemDescription), showCloseIcon: true));
                          }),
                      widgetToggle(context, AppLocalizations.of(context)!.settingsDisableMarkdown, noMarkdown, onNoMarkdownChanged)
                    ]),
                  ),
                  const SizedBox(height: 8),
                  widgetButton(AppLocalizations.of(context)!.settingsBehaviorNotUpdatedForOlderChats, Icons.info_rounded, null,
                      color: Colors.grey.harmonizeWith(Theme.of(context).colorScheme.primary))
                ])),
          )),
    );
  }
}