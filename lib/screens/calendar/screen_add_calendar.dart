import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import '../../widgets/widgets_units/widget_title.dart';
import '../../widgets/widgets_units/widget_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/service_calendar_event.dart';
import 'dart:convert';
import '../../services/service_notification.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ScreenAddCalendar extends StatefulWidget {
  const ScreenAddCalendar({super.key});

  @override
  State<ScreenAddCalendar> createState() => _ScreenAddCalendarState();
}

class _ScreenAddCalendarState extends State<ScreenAddCalendar> {
  DateTime? _selectedDateTime;
  String? selectedDateTime;
  final TextEditingController eventController = TextEditingController();
  int? notificationMinutes = 15; // 改為可為 null
  bool isPastDate = false; // 新增判斷是否為過去時間

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      notificationMinutes = null;
    }
  }

  Future<void> _openDateTimePicker(BuildContext context) async {
    final DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      is24HourMode: false,
      isForce2Digits: true,
      minutesInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (dateTime != null) {
      setState(() {
        _selectedDateTime = dateTime;
        selectedDateTime = '${dateTime.month}/${dateTime.day}/${dateTime.year} '
            '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

        // 檢查是否為過去時間
        isPastDate = dateTime.isBefore(DateTime.now());
        // 如果是過去時間，清除通知設定
        if (isPastDate) {
          notificationMinutes = null;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    try {
      final l10n = AppLocalizations.of(context);
      if (_selectedDateTime == null || eventController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.calendarEventNoEvents ?? 'Please fill in event title and select time')),
        );
        return;
      }

      final event = CalendarEvent(
        title: eventController.text,
        dateTime: _selectedDateTime!,
        notificationMinutes: notificationMinutes ?? 0, // 如果沒有設置通知，使用 0
      );

      // 儲存事件
      final prefs = EncryptedSharedPreferences.getInstance();
      List<String> events = prefs.getStringList('calendar_events') ?? [];
      events.add(jsonEncode(event.toJson()));
      await prefs.setStringList('calendar_events', events);

      // 只有當有設置通知時間且不是過去的時間才設置通知
      if (notificationMinutes != null && !isPastDate) {
        final notificationTime = event.dateTime.subtract(Duration(minutes: event.notificationMinutes));
        try {
          await NotificationService().scheduleNotification(
            id: events.length,
            title: l10n?.calendarReminderTitle ?? 'Appointment Reminder',
            body: (l10n?.calendarReminderBody ?? 'You have an upcoming appointment "{eventTitle}"')
                .toString()
                .replaceFirst('{eventTitle}', event.title),
            scheduledDate: notificationTime,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.calendarEventSave ?? 'Notification setup failed, but event was saved')),
          );
          debugPrint('通知設置錯誤: $e');
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('儲存事件失敗')),
      );
      debugPrint('儲存事件錯誤: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.calendarEventTitle ?? 'Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            widgetTitle(l10n?.calendarEventTitle ?? 'Event Title', top: 0, bottom: 8),
            TextField(
              controller: eventController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n?.calendarEventTitle ?? 'Enter event title',
              ),
            ),
            const SizedBox(height: 16),
            widgetTitle(l10n?.calendarEventDate ?? 'Date and Time', top: 0, bottom: 8),
            widgetButton(
              l10n?.selectDate ?? 'Select Date and Time',
              Icons.calendar_today,
              () => _openDateTimePicker(context),
              context: context,
            ),
            if (selectedDateTime != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '已選擇: $selectedDateTime',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (!isPastDate && _selectedDateTime != null && !kIsWeb) ...[
              const SizedBox(height: 16),
              widgetTitle(l10n?.calendarEventNotification ?? 'Notification', top: 0, bottom: 8),
              DropdownButtonFormField<int?>(
                value: notificationMinutes,
                items: [
                  const DropdownMenuItem(value: null, child: Text('不設置通知')),
                  const DropdownMenuItem(value: 1, child: Text('1 分鐘')),
                  const DropdownMenuItem(value: 5, child: Text('5 分鐘')),
                  const DropdownMenuItem(value: 15, child: Text('15 分鐘')),
                  const DropdownMenuItem(value: 30, child: Text('30 分鐘')),
                  const DropdownMenuItem(value: 60, child: Text('1 小時')),
                ],
                onChanged: (value) {
                  setState(() {
                    notificationMinutes = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ] else if (_selectedDateTime != null && isPastDate) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n?.calendarEventNoEvents ?? 'Cannot set notification for past time',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
            const SizedBox(height: 24),
            widgetButton(
              l10n?.calendarEventSave ?? 'Save',
              Icons.save,
              _saveEvent,
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}
