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
  final CalendarEvent? eventToEdit; // 添加編輯事件參數
  final int? eventIndex; // 添加事件索引參數

  const ScreenAddCalendar({super.key, this.eventToEdit, this.eventIndex});

  @override
  State<ScreenAddCalendar> createState() => _ScreenAddCalendarState();
}

class _ScreenAddCalendarState extends State<ScreenAddCalendar> {
  DateTime? _selectedDateTime;
  String? selectedDateTime;
  final TextEditingController eventController = TextEditingController();
  int? notificationMinutes = 15; // 改為可為 null
  bool isPastDate = false; // 新增判斷是否為過去時間

  // 預設顏色為藍色 (0xFF2196F3)
  int selectedColorValue = 0xFF2196F3;

  // 預設顏色選項
  final List<ColorOption> colorOptions = [
    ColorOption(name: '藍色', value: 0xFF2196F3),
    ColorOption(name: '紅色', value: 0xFFF44336),
    ColorOption(name: '綠色', value: 0xFF4CAF50),
    ColorOption(name: '橙色', value: 0xFFFF9800),
    ColorOption(name: '紫色', value: 0xFF9C27B0),
    ColorOption(name: '青色', value: 0xFF00BCD4),
  ];

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      notificationMinutes = null;
    }

    // 若有傳入要編輯的事件，載入其資料
    if (widget.eventToEdit != null) {
      _selectedDateTime = widget.eventToEdit!.dateTime;
      eventController.text = widget.eventToEdit!.title;
      notificationMinutes = widget.eventToEdit!.notificationMinutes > 0 ? widget.eventToEdit!.notificationMinutes : null;
      selectedColorValue = widget.eventToEdit!.colorValue;

      // 設置選擇的日期時間顯示
      selectedDateTime =
          '${_selectedDateTime!.month}/${_selectedDateTime!.day}/${_selectedDateTime!.year} '
          '${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}';

      // 檢查是否為過去時間
      isPastDate = _selectedDateTime!.isBefore(DateTime.now());
    }
  }

  Future<void> _openDateTimePicker(BuildContext context) async {
    // 設置初始日期，如果是編輯模式，使用已存在的日期
    DateTime initialDate = _selectedDateTime ?? DateTime.now();

    final DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      is24HourMode: false,
      isForce2Digits: true,
      minutesInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1.drive(Tween(begin: 0, end: 1)), child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (dateTime != null) {
      setState(() {
        _selectedDateTime = dateTime;
        selectedDateTime =
            '${dateTime.month}/${dateTime.day}/${dateTime.year} '
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n?.calendarEventNoEvents ?? 'Please fill in event title and select time')));
        return;
      }

      final event = CalendarEvent(
        title: eventController.text,
        dateTime: _selectedDateTime!,
        notificationMinutes: notificationMinutes ?? 0, // 如果沒有設置通知，使用 0
        colorValue: selectedColorValue, // 添加顏色值
      );

      // 儲存事件
      final prefs = EncryptedSharedPreferences.getInstance();
      List<String> events = prefs.getStringList('calendar_events') ?? [];

      // 判斷是新增還是編輯模式
      if (widget.eventIndex != null) {
        // 編輯模式：更新現有事件
        events[widget.eventIndex!] = jsonEncode(event.toJson());

        // 嘗試取消之前的通知
        try {
          await NotificationService().cancelNotification(widget.eventIndex! + 1);
        } catch (e) {
          debugPrint('取消舊通知時發生錯誤: $e');
        }
      } else {
        // 新增模式：添加新事件
        events.add(jsonEncode(event.toJson()));
      }

      await prefs.setStringList('calendar_events', events);

      // 只有當有設置通知時間且不是過去的時間才設置通知
      if (notificationMinutes != null && !isPastDate) {
        final notificationTime = event.dateTime.subtract(Duration(minutes: event.notificationMinutes));

        // 準備通知文本
        final String notificationTitle = l10n?.calendarReminderTitle ?? 'Appointment Reminder';
        // 直接替換事件標題，不使用複雜的模板格式
        final String notificationBody = '您有一個即將到來的預約：${event.title}';

        // 通知ID：如果是編輯，使用相同的索引；如果是新增，使用列表長度
        final int notificationId = widget.eventIndex != null ? widget.eventIndex! + 1 : events.length;

        try {
          await NotificationService().scheduleNotification(
            id: notificationId,
            title: notificationTitle,
            body: notificationBody,
            scheduledDate: notificationTime,
          );
          debugPrint('設置了通知: $notificationTitle - $notificationBody');
        } catch (e) {
          debugPrint('通知設置錯誤: $e');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n?.calendarEventSave ?? 'Event saved, but notification setup failed')));
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('儲存事件失敗')));
      debugPrint('儲存事件錯誤: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 根據是否是編輯模式設置不同的標題
    final String pageTitle = widget.eventToEdit != null ? (l10n?.calendarEventEdit ?? 'Edit Event') : (l10n?.calendarEventTitle ?? 'Add Event');

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            widgetTitle(l10n?.calendarEventTitle ?? 'Event Title', top: 0, bottom: 8),
            TextField(
              controller: eventController,
              decoration: InputDecoration(border: const OutlineInputBorder(), hintText: l10n?.calendarEventTitle ?? 'Enter event title'),
            ),
            const SizedBox(height: 16),
            widgetTitle(l10n?.calendarEventDate ?? 'Date and Time', top: 0, bottom: 8),
            widgetButton(l10n?.selectDate ?? 'Select Date and Time', Icons.calendar_today, () => _openDateTimePicker(context), context: context),
            if (selectedDateTime != null)
              Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('已選擇: $selectedDateTime', style: const TextStyle(fontSize: 16))),
            const SizedBox(height: 16),
            widgetTitle('事件顏色', top: 0, bottom: 8),
            Wrap(
              spacing: 10,
              children:
                  colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColorValue = color.value;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Color(color.value),
                          shape: BoxShape.circle,
                          border: selectedColorValue == color.value ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: selectedColorValue == color.value ? const Icon(Icons.check, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
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
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ] else if (_selectedDateTime != null && isPastDate) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n?.calendarEventNoEvents ?? 'Cannot set notification for past time', style: const TextStyle(color: Colors.red)),
              ),
            ],
            const SizedBox(height: 24),
            widgetButton(l10n?.calendarEventSave ?? 'Save', Icons.save, _saveEvent, context: context),
          ],
        ),
      ),
    );
  }
}

// 新增一個顏色選項類，方便管理
class ColorOption {
  final String name;
  final int value;

  ColorOption({required this.name, required this.value});
}
