import 'package:flutter/material.dart';

import 'dart:convert';
import '../../services/service_calendar_event.dart';
import '../../l10n/app_localizations.dart';
import '../../services/service_notification.dart';
import '../../services/service_theme.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class ScreenCalendarList extends StatefulWidget {
  const ScreenCalendarList({super.key});

  @override
  State<ScreenCalendarList> createState() => _ScreenCalendarListState();
}

class _ScreenCalendarListState extends State<ScreenCalendarList> {
  List<CalendarEvent> events = [];
  String sortOrder = 'date_asc'; // 預設按日期升序排序

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = EncryptedSharedPreferences.getInstance();
    final eventStrings = prefs.getStringList('calendar_events') ?? [];
    setState(() {
      events = eventStrings.map((e) => CalendarEvent.fromJson(jsonDecode(e))).toList();
      _sortEvents();
    });
  }

  void _sortEvents() {
    switch (sortOrder) {
      case 'date_asc':
        events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case 'date_desc':
        events.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case 'title_asc':
        events.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        events.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
  }

  Future<void> _deleteEvent(CalendarEvent event, int index) async {
    try {
      final l10n = AppLocalizations.of(context);
      // 獲取當前事件列表
      final prefs = EncryptedSharedPreferences.getInstance();
      List<String> eventStrings = prefs.getStringList('calendar_events') ?? [];
      
      // 找到對應事件的索引
      final eventJson = jsonEncode(event.toJson());
      final originalIndex = eventStrings.indexWhere((e) => 
        CalendarEvent.fromJson(jsonDecode(e)).dateTime == event.dateTime && 
        CalendarEvent.fromJson(jsonDecode(e)).title == event.title);
      
      if (originalIndex != -1) {
        // 刪除指定事件
        eventStrings.removeAt(originalIndex);
        await prefs.setStringList('calendar_events', eventStrings);

        // 取消相關通知
        await NotificationService().cancelNotification(originalIndex + 1);

        // 重新加載事件列表
        await _loadEvents();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.calendarDeleteEvent(event.title) ?? 'Event deleted: ${event.title}'),
              action: SnackBarAction(
                label: l10n?.calendarDeleteEventUndo ?? 'Undo',
                onPressed: () async {
                  // 恢復刪除
                  eventStrings = prefs.getStringList('calendar_events') ?? [];
                  eventStrings.insert(originalIndex, eventJson);
                  await prefs.setStringList('calendar_events', eventStrings);

                  // 如果事件有通知且在未來，重新設置通知
                  if (event.notificationMinutes > 0) {
                    final notificationTime = event.dateTime.subtract(Duration(minutes: event.notificationMinutes));
                    if (notificationTime.isAfter(DateTime.now())) {
                      await NotificationService().scheduleNotification(
                        id: eventStrings.length,
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

  @override
  Widget build(BuildContext context) {
    final theme = themeCurrent(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.calendarEventList ?? 'Event List'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: l10n?.calendarSortEvents ?? 'Sort Events',
            onSelected: (value) {
              setState(() {
                sortOrder = value;
                _sortEvents();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date_asc',
                child: Text(l10n?.calendarSortDateAsc ?? 'Date (Oldest first)'),
              ),
              PopupMenuItem(
                value: 'date_desc',
                child: Text(l10n?.calendarSortDateDesc ?? 'Date (Newest first)'),
              ),
              PopupMenuItem(
                value: 'title_asc',
                child: Text(l10n?.calendarSortTitleAsc ?? 'Title (A to Z)'),
              ),
              PopupMenuItem(
                value: 'title_desc',
                child: Text(l10n?.calendarSortTitleDesc ?? 'Title (Z to A)'),
              ),
            ],
          ),
        ],
      ),
      body: events.isEmpty
          ? Center(
              child: Text(l10n?.calendarNoEvents ?? 'No events'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final bool isPastEvent = event.dateTime.isBefore(DateTime.now());
                
                return Dismissible(
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
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.event,
                        color: isPastEvent ? Colors.grey : theme.colorScheme.primary,
                      ),
                      title: Text(
                        event.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPastEvent ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n?.calendarEventDate ?? 'Date'}: ${event.dateTime.year}/${event.dateTime.month}/${event.dateTime.day}',
                          ),
                          Text(
                            '${l10n?.calendarEventTime ?? 'Time'}: ${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                          ),
                          if (event.notificationMinutes > 0)
                            Text(
                              '${l10n?.calendarEventNotification ?? 'Reminder'}: ${event.notificationMinutes} ${l10n?.calendarEventMinutesBefore ?? 'minutes before'}',
                            ),
                        ],
                      ),
                      trailing: isPastEvent
                          ? const Icon(Icons.history, color: Colors.grey)
                          : Icon(
                              Icons.notifications_active,
                              color: event.notificationMinutes > 0 ? Colors.amber : Colors.grey,
                            ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
