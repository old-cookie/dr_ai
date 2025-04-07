import 'package:flutter/material.dart';

class CalendarEvent {
  final String title;
  final DateTime dateTime;
  final int notificationMinutes;
  final int colorValue; // 添加顏色屬性，使用 int 存儲顏色值

  CalendarEvent({
    required this.title,
    required this.dateTime,
    required this.notificationMinutes,
    this.colorValue = 0xFF2196F3, // 預設藍色
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'notificationMinutes': notificationMinutes,
      'colorValue': colorValue, // 保存顏色值
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      notificationMinutes: json['notificationMinutes'],
      colorValue: json['colorValue'] ?? 0xFF2196F3, // 如果舊數據沒有顏色值，使用預設藍色
    );
  }

  // 便利方法將 int 轉換為 Color 對象
  Color get color => Color(colorValue);
}
