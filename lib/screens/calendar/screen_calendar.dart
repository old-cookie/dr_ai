import 'package:flutter/material.dart';
import '../../widgets/widgets_screens/calendar/widget_calendar.dart';
import '../../../l10n/app_localizations.dart';
import './screen_calendar_list.dart'; // 新增導入

class ScreenCalendar extends StatelessWidget {
  const ScreenCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.calendarTitle ?? 'Calendar'),
        actions: [
          // 新增按鈕到列表視圖
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: l10n?.calendarEventList ?? 'Event List',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScreenCalendarList(),
                ),
              );
            },
          ),
        ],
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
