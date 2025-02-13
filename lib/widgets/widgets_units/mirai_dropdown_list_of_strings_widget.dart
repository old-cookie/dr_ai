/*
* Created By Mirai Devs.
* On 3/28/2022.
*/
// import 'package:example/app/core/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';

class MiraiDropdownWidget<String> extends StatelessWidget {
  const MiraiDropdownWidget({
    super.key,
    this.dropdownKey,
    required this.valueNotifier,
    required this.itemWidgetBuilder,
    required this.children,
    required this.onChanged,
    this.itemMargin,
    this.underline = false,
    this.showSeparator = true,
    this.exit = MiraiExit.fromAll,
    this.chevronDownColor,
    this.showMode = MiraiShowMode.bottom,
    this.maxHeight,
    this.showSearchTextField = false,
    this.showOtherAndItsTextField = false,
    this.other,
    this.otherController,
    this.otherDecoration,
    this.otherValidator,
    this.otherOnFieldSubmitted,
    this.otherHeight,
    this.otherMargin,
  });

  final Key? dropdownKey;
  final ValueNotifier<String> valueNotifier;
  final MiraiDropdownBuilder<String> itemWidgetBuilder;
  final EdgeInsetsGeometry? itemMargin;
  final List<String> children;
  final ValueChanged<String> onChanged;
  final bool underline;
  final bool showSeparator;
  final MiraiExit exit;
  final Color? chevronDownColor;
  final MiraiShowMode showMode;
  final double? maxHeight;
  final bool showSearchTextField;
  final bool showOtherAndItsTextField;
  final Widget? other;

  final TextEditingController? otherController;
  final InputDecoration? otherDecoration;
  final FormFieldValidator<String>? otherValidator;
  final ValueChanged<String>? otherOnFieldSubmitted;
  final double? otherHeight;
  final EdgeInsetsGeometry? otherMargin;

  @override
  Widget build(BuildContext context) {
    return MiraiDropDownMenu<String>(
      key: dropdownKey ?? UniqueKey(),
      enable: true,
      space: 4,
      showMode: showMode,
      exit: exit,
      showSeparator: showSeparator,
      children: children,
      itemWidgetBuilder: itemWidgetBuilder,
      itemMargin: itemMargin,
      onChanged: onChanged,
      maxHeight: maxHeight,
      showOtherAndItsTextField: showOtherAndItsTextField,
      showSearchTextField: showSearchTextField,
      other: other,
      otherController: otherController,
      otherDecoration: otherDecoration,
      //otherValidator: this.otherValidator,

      //  otherOnFieldSubmitted: print,
      otherHeight: otherHeight,
      otherMargin: otherMargin,

      valueNotifier: valueNotifier,
      child: Container(
        key: GlobalKey(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: underline ? null : BorderRadius.circular(8.0),
          border: underline
              ? Border(
                  bottom: BorderSide(
                    width: 1.0,
                    color: Theme.of(context).brightness == Brightness.light 
                        ? Colors.black26
                        : Colors.white24,
                  ),
                )
              : Border.all(
                  color: Theme.of(context).brightness == Brightness.light 
                      ? Colors.black26
                      : Colors.white24,
                  width: 1.0,
                ),
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
        ),
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: ValueListenableBuilder<String>(
                valueListenable: valueNotifier,
                builder: (_, String chosenTitle, __) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 100),
                      child: Text(
                        '$chosenTitle',
                        key: ValueKey<String>(chosenTitle),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.black87
                              : Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            FaIcon(
              FontAwesomeIcons.chevronDown,
              color: chevronDownColor ?? (Theme.of(context).brightness == Brightness.light 
                  ? Colors.black54
                  : Colors.white70),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
