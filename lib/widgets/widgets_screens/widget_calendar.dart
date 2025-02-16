import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/service_theme.dart';
import '../../screens/screen_add_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/service_calendar_event.dart';
import 'dart:convert';

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

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return events.where((event) => isSameDay(event.dateTime, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = themeCurrent(context);
    final selectedDayEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Column(
      children: [
        TableCalendar(
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
                  '${(_selectedDay ?? _focusedDay).year}年${(_selectedDay ?? _focusedDay).month}月${(_selectedDay ?? _focusedDay).day}日',
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
                  child: const Text('新增預約'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (selectedDayEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('這一天沒有預約事件'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedDayEvents.length,
              itemBuilder: (context, index) {
                final event = selectedDayEvents[index];
                return Card(
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
                      '時間: ${event.dateTime.hour.toString().padLeft(2, '0')}:'
                      '${event.dateTime.minute.toString().padLeft(2, '0')}\n'
                      '提醒: ${event.notificationMinutes} 分鐘前',
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
