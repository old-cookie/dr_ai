class CalendarEvent {
  final String title;
  final DateTime dateTime;
  final int notificationMinutes;

  CalendarEvent({
    required this.title,
    required this.dateTime,
    required this.notificationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'notificationMinutes': notificationMinutes,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      notificationMinutes: json['notificationMinutes'],
    );
  }
}
