import 'package:flutter/material.dart';
import '../../widgets/widgets_screens/calendar/widget_calendar.dart';
import '../../../l10n/app_localizations.dart';
import './screen_calendar_list.dart'; // 新增導入
import 'dart:convert';
import '../../services/service_calendar_event.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class ScreenCalendar extends StatefulWidget {
  const ScreenCalendar({super.key});

  @override
  State<ScreenCalendar> createState() => _ScreenCalendarState();
}

class _ScreenCalendarState extends State<ScreenCalendar> {
  List<CalendarEvent> events = [];
  List<CalendarEvent> filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final prefs = EncryptedSharedPreferences.getInstance();
    final eventStrings = prefs.getStringList('calendar_events') ?? [];
    setState(() {
      events = eventStrings.map((e) => CalendarEvent.fromJson(jsonDecode(e))).toList();
    });
  }

  void _searchEvents(String query) {
    final lowerCaseQuery = query.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      filteredEvents = events.where((event) {
        return event.title.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

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
      body: Column(
        children: [
          // 搜尋欄
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n?.calendarSearchEvents ?? '搜尋預約',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _searchEvents,
            ),
          ),
          // 搜尋結果顯示
          if (_isSearching) 
            Expanded(
              child: filteredEvents.isEmpty
                ? Center(
                    child: Text(l10n?.calendarNoEvents ?? '沒有匹配的預約'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(event.colorValue),
                            child: const Icon(
                              Icons.event,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n?.calendarEventDate ?? '日期'}: ${event.dateTime.year}/${event.dateTime.month}/${event.dateTime.day}',
                              ),
                              Text(
                                '${l10n?.calendarEventTime ?? '時間'}: ${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            )
          else
            // 原有的日曆視圖
            const Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: WidgetCalendar(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
