import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'calendar_notification_channel';
  static const String _channelName = '預約提醒';
  static const String _channelDesc = '用於預約時間提醒的通知';
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 初始化時區
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // 初始化設定 - 修改圖標設定
      // 使用 mipmap/ic_launcher 作為 Android 的預設圖標，這是 Flutter 專案的標準圖標位置
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentSound: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      // 初始化通知插件
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('通知回應: ${details.payload}');
        },
      );

      // 在 Android 上創建通知頻道
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            // 移除或更新聲音設定，確保資源存在
            // sound: RawResourceAndroidNotificationSound('notificationsound'),
          ),
        );

        // 請求權限
        await requestPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('通知初始化錯誤: $e');
    }
  }

  Future<void> requestPermission() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('請求通知權限錯誤: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // 檢查時間是否在未來
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        debugPrint('警告：不能設定過去的時間，跳過通知設置');
        return;
      }

      final notificationTime = tz.TZDateTime.from(scheduledDate, tz.local);
      debugPrint('準備設置通知: ${notificationTime.toString()}');
      debugPrint('通知標題: $title');
      debugPrint('通知內容: $body');

      // 確保標題和內容不為空
      final String safeTitle = title.isNotEmpty ? title : '預約提醒';
      final String safeBody = body.isNotEmpty ? body : '您有一個即將到來的預約';

      await _notifications.zonedSchedule(
        id,
        safeTitle,
        safeBody,
        notificationTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(
              safeBody,
              contentTitle: safeTitle,
              summaryText: '預約提醒',
            ),
            channelShowBadge: true,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'notification_sound.aiff',
            interruptionLevel: InterruptionLevel.timeSensitive,
            subtitle: safeBody,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'calendar_appointment_$id',
      );
      debugPrint('通知已排程: ID=$id, 時間=${notificationTime.toString()}');
    } catch (e) {
      debugPrint('排程通知錯誤: $e');
    }
  }

  Future<void> showPopupNotification({
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _notifications.show(
        DateTime.now().millisecond, // 使用當前時間毫秒數作為唯一ID
        title,
        body,
        NotificationDetails(
          android: const AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            // 確保使用系統預設圖標
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      debugPrint('跳出通知已顯示');
    } catch (e) {
      debugPrint('顯示跳出通知錯誤: $e');
      // 錯誤處理但不重拋，避免應用崩潰
      // rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
