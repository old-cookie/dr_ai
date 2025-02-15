import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import '../widgets/widgets_units/widget_title.dart';
import '../widgets/widgets_units/widget_button.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_calendar_event.dart';
import 'dart:convert';

class ScreenAddCalendar extends StatefulWidget {
  const ScreenAddCalendar({super.key});

  @override
  State<ScreenAddCalendar> createState() => _ScreenAddCalendarState();
}

class _ScreenAddCalendarState extends State<ScreenAddCalendar> {
  DateTime? _selectedDateTime;
  String? selectedDateTime;
  final TextEditingController eventController = TextEditingController();
  int notificationMinutes = 15;

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
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_selectedDateTime == null || eventController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填寫事件名稱和選擇時間')),
      );
      return;
    }

    final event = CalendarEvent(
      title: eventController.text,
      dateTime: _selectedDateTime!,
      notificationMinutes: notificationMinutes,
    );

    final prefs = await SharedPreferences.getInstance();
    List<String> events = prefs.getStringList('calendar_events') ?? [];
    events.add(jsonEncode(event.toJson()));
    await prefs.setStringList('calendar_events', events);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增日曆事件'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            widgetTitle('事件名稱', top: 0, bottom: 8),
            TextField(
              controller: eventController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '請輸入事件名稱',
              ),
            ),
            const SizedBox(height: 16),
            widgetTitle('日期和時間', top: 0, bottom: 8),
            widgetButton(
              '選擇日期和時間',
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
            const SizedBox(height: 16),
            widgetTitle('提前通知時間', top: 0, bottom: 8),
            DropdownButtonFormField<int>(
              value: notificationMinutes,
              items: [
                const DropdownMenuItem(value: 5, child: Text('5 分鐘')),
                const DropdownMenuItem(value: 15, child: Text('15 分鐘')),
                const DropdownMenuItem(value: 30, child: Text('30 分鐘')),
                const DropdownMenuItem(value: 60, child: Text('1 小時')),
              ],
              onChanged: (value) {
                setState(() {
                  notificationMinutes = value!;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            widgetButton(
              '儲存',
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
