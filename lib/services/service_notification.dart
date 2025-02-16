import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  static const String _channelId = 'calendar_notification_channel';
  static const String _channelName = '預約提醒';
  static const String _channelDesc = '用於預約時間提醒的通知';

  Future<void> initialize() async {
    try {
      // 初始化時區
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // 創建高優先級的通知頻道
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notificationsound'),
        enableLights: true,
        showBadge: true,
      );

      // 獲取 Android 特定實現
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // 創建通知頻道
      await androidPlugin?.createNotificationChannel(androidChannel);

      // 初始化設定，使用新的圖標設定
      const androidSettings = AndroidInitializationSettings('app_icon');
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

      // 請求所需權限
      await requestPermission();
      
    } catch (e) {
      debugPrint('通知初始化錯誤: $e');
    }
  }

  Future<void> requestPermission() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
          
      // 請求通知權限
      await androidPlugin?.requestNotificationsPermission();
      
      // 請求精確鬧鐘權限
      await androidPlugin?.requestExactAlarmsPermission();
      
    } catch (e) {
      debugPrint('請求權限錯誤: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // 檢查時間是否在未來
      final now = DateTime.now();
      if (scheduledDate.isBefore(now)) {
        debugPrint('警告：不能設定過去的時間，跳過通知設置');
        return;
      }

      final notificationTime = tz.TZDateTime.from(scheduledDate, tz.local);
      debugPrint('準備設置通知: ${notificationTime.toString()}');
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        notificationTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.max,    // 設為最高重要性
            priority: Priority.max,        // 設為最高優先級
            enableVibration: true,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('notificationsound'),
            enableLights: true,
            color: Colors.blue,
            ledColor: Colors.blue,
            ledOnMs: 1000,
            ledOffMs: 500,
            ticker: '新的預約提醒',
            channelShowBadge: true,
            fullScreenIntent: true,        // 啟用全螢幕意圖
            visibility: NotificationVisibility.public,  // 在鎖屏上也顯示
            category: AndroidNotificationCategory.alarm,  // 設為警報類別
            additionalFlags: Int32List.fromList(<int>[4]),  // 添加堅持標誌
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            presentBanner: true,           // 確保顯示橫幅
            presentList: true,
            sound: 'notification_sound.aiff',
            badgeNumber: 1,
            interruptionLevel: InterruptionLevel.timeSensitive,  // 設為時間敏感
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('通知已排程: ID=$id, 時間=${notificationTime.toString()}');
    } catch (e) {
      debugPrint('排程通知錯誤: $e');
      rethrow;
    }
  }

  /// 顯示即時通知
  Future<void> showPopupNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _notifications.show(
        DateTime.now().millisecond, // 使用當前時間毫秒數作為唯一ID
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('notificationsound'),
            enableLights: true,
            color: Colors.blue,
            ledColor: Colors.blue,
            ledOnMs: 1000,
            ledOffMs: 500,
            fullScreenIntent: true, // 啟用全螢幕意圖
            category: AndroidNotificationCategory.alarm, // 設為警報類別
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'notification_sound.aiff',
            interruptionLevel: InterruptionLevel.active, // 設置中斷級別
          ),
        ),
      );
      debugPrint('跳出通知已顯示');
    } catch (e) {
      debugPrint('顯示跳出通知錯誤: $e');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
