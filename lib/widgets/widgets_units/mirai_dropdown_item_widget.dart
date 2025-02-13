/*
* Created By Mirai Devs.
* On 3/28/2022.
*/

// import 'package:example/app/core/utils/app_theme.dart';
import 'package:flutter/material.dart';
import './widget_button.dart';
import './widget_title.dart';
import '../../services/service_theme.dart';
// import 'package:mirai_substring_highlight/mirai_substring_highlight.dart';

class MiraiDropDownItemWidget extends StatelessWidget {
  const MiraiDropDownItemWidget({
    super.key,
    required this.item,
    required this.isItemSelected,
    this.showHighLight = false,
    this.query,
  });

  final String? item;
  final bool showHighLight;
  final String? query;
  final bool isItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final brightness = theme.brightness;
    
    return Container(
      decoration: BoxDecoration(
        color: isItemSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 16.0,
      ),
      child: Text(
        '$item',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isItemSelected 
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface.withOpacity(0.85),
          fontWeight: isItemSelected ? FontWeight.w600 : FontWeight.normal,
          overflow: TextOverflow.ellipsis,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}