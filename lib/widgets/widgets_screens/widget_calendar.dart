import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/service_theme.dart';
import '../../screens/screen_add_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/service_calendar_event.dart';
import 'dart:convert';
import '../../services/service_notification.dart';
import '../../l10n/app_localizations.dart';

class WidgetCalendar extends StatefulWidget {
  const WidgetCalendar({super.key});

  @override
  State<WidgetCalendar> createState() => _WidgetCalendarState();
}

class _WidgetCalendarState extends State<WidgetCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CalendarEvent> events = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // 設置當前日期為選中日期
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventStrings = prefs.getStringList('calendar_events') ?? [];
    setState(() {
      events = eventStrings.map((e) => CalendarEvent.fromJson(jsonDecode(e))).toList();
    });
  }

  Future<void> _deleteEvent(CalendarEvent event, int index) async {
    try {
      final l10n = AppLocalizations.of(context);
      // 獲取當前事件列表
      final prefs = await SharedPreferences.getInstance();
      List<String> events = prefs.getStringList('calendar_events') ?? [];

      // 刪除指定事件
      events.removeAt(index);
      await prefs.setStringList('calendar_events', events);

      // 取消相關通知
      await NotificationService().cancelNotification(index + 1); // 因為我們使用 events.length 作為 ID

      // 重新加載事件列表
      await _loadEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.calendarDeleteEvent(event.title) ?? 'Event deleted: ${event.title}'),
            action: SnackBarAction(
              label: l10n?.calendarDeleteEventUndo ?? 'Undo',
              onPressed: () async {
                // 復原刪除
                events.insert(index, jsonEncode(event.toJson()));
                await prefs.setStringList('calendar_events', events);

                // 如果事件有通知且在未來，重新設置通知
                if (event.notificationMinutes > 0) {
                  final notificationTime = event.dateTime.subtract(Duration(minutes: event.notificationMinutes));
                  if (notificationTime.isAfter(DateTime.now())) {
                    await NotificationService().scheduleNotification(
                      id: events.length,
                      title: l10n?.calendarReminderTitle ?? 'Appointment Reminder',
                      body: l10n?.calendarReminderBody(event.title) ?? 'You have an upcoming appointment "${event.title}"',
                      scheduledDate: notificationTime,
                    );
                  }
                }

                await _loadEvents();
              },
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('刪除事件錯誤: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('刪除事件失敗')),
        );
      }
    }
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return events.where((event) => isSameDay(event.dateTime, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = themeCurrent(context);
    final selectedDayEvents = _getEventsForDay(_selectedDay ?? _focusedDay);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Column(
      children: [
        TableCalendar(
          locale: locale, // 添加本地化支援
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: theme.colorScheme.onPrimary,
            ),
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(76),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 17,
            ),
          ),
          eventLoader: _getEventsForDay,
        ),
        const SizedBox(height: 20),
        if (_selectedDay != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // 使用 Intl 格式化日期
                  '${_selectedDay?.year}年${_selectedDay?.month}月${_selectedDay?.day}日',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScreenAddCalendar(),
                      ),
                    );
                    if (result == true) {
                      _loadEvents();
                    }
                  },
                  child: Text(l10n?.calendarEventAdd ?? 'Add Event'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (selectedDayEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(l10n?.calendarEventNoEvents ?? 'No events for this day'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedDayEvents.length,
              itemBuilder: (context, index) {
                final event = selectedDayEvents[index];
                return Dismissible(
                  // 添加滑動刪除功能
                  key: Key(event.dateTime.toIso8601String() + index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (direction) {
                    _deleteEvent(event, index);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.event,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        event.notificationMinutes > 0
                            ? '${l10n?.calendarEventTime ?? 'Time'}: ${event.dateTime.hour.toString().padLeft(2, '0')}:'
                                '${event.dateTime.minute.toString().padLeft(2, '0')}\n'
                                '${l10n?.calendarEventNotification ?? 'Reminder'}: ${event.notificationMinutes} '
                                '${l10n?.calendarEventNotification ?? 'minutes before'}'
                            : '${l10n?.calendarEventTime ?? 'Time'}: ${event.dateTime.hour.toString().padLeft(2, '0')}:'
                                '${event.dateTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}
