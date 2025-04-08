import 'package:flutter/material.dart';

import 'dart:convert';
import '../../services/service_calendar_event.dart';
import '../../l10n/app_localizations.dart';
import '../../services/service_notification.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'screen_add_calendar.dart';

class ScreenCalendarList extends StatefulWidget {
  const ScreenCalendarList({super.key});

  @override
  State<ScreenCalendarList> createState() => _ScreenCalendarListState();
}

class _ScreenCalendarListState extends State<ScreenCalendarList> {
  List<CalendarEvent> events = [];
  List<CalendarEvent> filteredEvents = []; // 用於存儲搜尋結果
  String sortOrder = 'date_asc'; // 預設按日期升序排序
  final TextEditingController _searchController = TextEditingController(); // 搜尋控制器
  bool _isSearching = false; // 是否正在搜尋

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _searchController.addListener(_onSearchChanged); // 添加搜尋變化監聽
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // 移除監聽
    _searchController.dispose(); // 釋放控制器
    super.dispose();
  }

  // 搜尋變化監聽方法
  void _onSearchChanged() {
    _searchEvents(_searchController.text);
  }

  // 搜尋事件方法
  void _searchEvents(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        filteredEvents = events;
      });
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _isSearching = true;
      filteredEvents =
          events.where((event) {
            return event.title.toLowerCase().contains(lowerCaseQuery);
          }).toList();
      _sortFilteredEvents(); // 排序搜尋結果
    });
  }

  // 排序搜尋結果
  void _sortFilteredEvents() {
    switch (sortOrder) {
      case 'date_asc':
        filteredEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case 'date_desc':
        filteredEvents.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case 'title_asc':
        filteredEvents.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'title_desc':
        filteredEvents.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
  }

  Future<void> _loadEvents() async {
    final prefs = EncryptedSharedPreferences.getInstance();
    final eventStrings = prefs.getStringList('calendar_events') ?? [];
    setState(() {
      events = eventStrings.map((e) => CalendarEvent.fromJson(jsonDecode(e))).toList();
      filteredEvents = events; // 初始化過濾後的事件列表
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

    // 如果正在搜尋，也需要對過濾後的列表排序
    if (_isSearching) {
      _sortFilteredEvents();
    } else {
      filteredEvents = List.from(events);
    }
  }

  // 添加編輯事件功能
  void _editEvent(CalendarEvent event, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ScreenAddCalendar(eventToEdit: event, eventIndex: index))).then((result) {
      if (result == true) {
        _loadEvents();
      }
    });
  }

  Future<void> _deleteEvent(CalendarEvent event, int index) async {
    try {
      final l10n = AppLocalizations.of(context);
      // 獲取當前事件列表
      final prefs = EncryptedSharedPreferences.getInstance();
      List<String> eventStrings = prefs.getStringList('calendar_events') ?? [];

      // 找到對應事件的索引
      final eventJson = jsonEncode(event.toJson());
      final originalIndex = eventStrings.indexWhere(
        (e) => CalendarEvent.fromJson(jsonDecode(e)).dateTime == event.dateTime && CalendarEvent.fromJson(jsonDecode(e)).title == event.title,
      );

      if (originalIndex != -1) {
        // 刪除指定事件
        eventStrings.removeAt(originalIndex);
        await prefs.setStringList('calendar_events', eventStrings);

        // 安全地取消相關通知
        try {
          await NotificationService().cancelNotification(originalIndex + 1);
        } catch (e) {
          debugPrint('取消通知時發生錯誤: $e');
        }

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
                      try {
                        // 使用更簡單、確定的通知內容格式
                        final String notificationTitle = l10n?.calendarReminderTitle ?? 'Appointment Reminder';
                        final String notificationBody = '您有一個即將到來的預約：${event.title}';

                        await NotificationService().scheduleNotification(
                          id: eventStrings.length,
                          title: notificationTitle,
                          body: notificationBody,
                          scheduledDate: notificationTime,
                        );
                      } catch (e) {
                        debugPrint('重新設置通知時發生錯誤: $e');
                      }
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('刪除事件失敗')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.calendarEventList ?? 'Event List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n?.calendarSearchEvents ?? 'Search Events',
            onPressed: () {
              showSearch(context: context, delegate: CalendarSearchDelegate(events, _searchEvents));
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: l10n?.calendarSortEvents ?? 'Sort Events',
            onSelected: (value) {
              setState(() {
                sortOrder = value;
                _sortEvents();
              });
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'date_asc', child: Text(l10n?.calendarSortDateAsc ?? 'Date (Oldest first)')),
                  PopupMenuItem(value: 'date_desc', child: Text(l10n?.calendarSortDateDesc ?? 'Date (Newest first)')),
                  PopupMenuItem(value: 'title_asc', child: Text(l10n?.calendarSortTitleAsc ?? 'Title (A to Z)')),
                  PopupMenuItem(value: 'title_desc', child: Text(l10n?.calendarSortTitleDesc ?? 'Title (Z to A)')),
                ],
          ),
        ],
      ),
      body:
          filteredEvents.isEmpty
              ? Center(child: Text(l10n?.calendarNoEvents ?? 'No events'))
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  final bool isPastEvent = event.dateTime.isBefore(DateTime.now());
                  // 找到在原始事件列表中的索引
                  final originalIndex = events.indexWhere((e) => e.dateTime == event.dateTime && e.title == event.title);

                  return Dismissible(
                    key: Key(event.dateTime.toIso8601String() + index.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      _deleteEvent(event, index);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(backgroundColor: Color(event.colorValue), child: Icon(Icons.event, color: Colors.white)),
                            title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold, color: isPastEvent ? Colors.grey : null)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n?.calendarEventDate ?? 'Date'}: ${event.dateTime.year}/${event.dateTime.month}/${event.dateTime.day}',
                                  style: TextStyle(color: isPastEvent ? Colors.grey : null),
                                ),
                                Text(
                                  '${l10n?.calendarEventTime ?? 'Time'}: ${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(color: isPastEvent ? Colors.grey : null),
                                ),
                                if (event.notificationMinutes > 0)
                                  Text(
                                    '${l10n?.calendarEventNotification ?? 'Reminder'}: ${l10n?.calendarEventMinutesBefore(event.notificationMinutes.toString()) ?? '${event.notificationMinutes} minutes before'}',
                                    style: TextStyle(color: isPastEvent ? Colors.grey : null),
                                  ),
                              ],
                            ),
                            trailing:
                                isPastEvent
                                    ? const Icon(Icons.history, color: Colors.grey)
                                    : Icon(Icons.notifications_active, color: event.notificationMinutes > 0 ? Colors.amber : Colors.grey),
                          ),
                          // 添加編輯按鈕，使風格與疫苗記錄頁面相同
                          Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: Text(l10n?.edit ?? 'Edit'),
                                  onPressed: () => _editEvent(event, originalIndex),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class CalendarSearchDelegate extends SearchDelegate {
  final List<CalendarEvent> events;
  final Function(String) onSearch;

  CalendarSearchDelegate(this.events, this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch(query);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    final filteredEvents =
        events.where((event) {
          return event.title.toLowerCase().contains(query.toLowerCase());
        }).toList();

    return ListView.builder(
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text('${event.dateTime.year}/${event.dateTime.month}/${event.dateTime.day}'),
          onTap: () {
            close(context, event);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredEvents =
        events.where((event) {
          return event.title.toLowerCase().contains(query.toLowerCase());
        }).toList();

    return ListView.builder(
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text('${event.dateTime.year}/${event.dateTime.month}/${event.dateTime.day}'),
          onTap: () {
            query = event.title;
            showResults(context);
          },
        );
      },
    );
  }
}
