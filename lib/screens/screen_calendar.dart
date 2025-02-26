import 'package:flutter/material.dart';
import '../../widgets/widgets_screens/widget_calendar.dart';
import '../../l10n/app_localizations.dart';

/// 疫苗記錄管理畫面
/// 提供疫苗接種記錄的查看、新增和刪除功能
class ScreenCalendar extends StatelessWidget {
  const ScreenCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.calendarTitle ?? 'Calendar'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: WidgetCalendar(),
        ),
      ),
    );
  }
}
