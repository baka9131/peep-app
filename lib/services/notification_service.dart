import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // timezone 데이터 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 초기화 설정
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // 초기화 설정 통합
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // 알림을 탭했을 때의 동작을 여기에 구현할 수 있습니다.
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ 알림 권한 요청
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // Android 13 이상에서는 POST_NOTIFICATIONS 권한 요청
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted ?? false) {
          // 정확한 알람 권한도 요청 (예약 알림을 위해)
          await androidPlugin.requestExactAlarmsPermission();
        }
        return granted ?? false;
      }
      
      // 폴백: permission_handler 사용
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS 알림 권한 요청
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'peep_channel',
          'PEEP 알림',
          channelDescription: '체크인/체크아웃 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          icon: '@drawable/ic_notification',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleCheckInReminder(TimeOfDay time) async {
    if (!_isInitialized) await initialize();

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 만약 설정된 시간이 이미 지났다면 다음 날로 설정
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'checkin_reminder',
          '체크인 알림',
          channelDescription: '체크인 시간 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      1001, // 체크인 알림 ID
      '체크인 시간입니다 ⏰',
      '좋은 하루 시작하세요! 체크인을 잊지 마세요.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복

      payload: 'checkin_reminder',
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  Future<void> scheduleCheckOutReminder(TimeOfDay time) async {
    if (!_isInitialized) await initialize();

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 만약 설정된 시간이 이미 지났다면 다음 날로 설정
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'checkout_reminder',
          '체크아웃 알림',
          channelDescription: '체크아웃 시간 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      1002, // 체크아웃 알림 ID
      '체크아웃 시간입니다 🏃‍♂️',
      '오늘도 수고하셨습니다! 체크아웃을 해주세요.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
      payload: 'checkout_reminder',
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }

  Future<void> cancelCheckInReminder() async {
    await _notifications.cancel(1001);
  }

  Future<void> cancelCheckOutReminder() async {
    await _notifications.cancel(1002);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancel(1001); // 체크인
    await _notifications.cancel(1002); // 체크아웃
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  Future<void> showCheckInSuccessNotification() async {
    await showInstantNotification(
      title: '체크인 완료! ✅',
      body: '좋은 하루 보내세요! 😊',
      payload: 'checkin_success',
    );
  }

  Future<void> showCheckOutSuccessNotification() async {
    await showInstantNotification(
      title: '체크아웃 완료! 🎉',
      body: '오늘도 수고하셨습니다! 👏',
      payload: 'checkout_success',
    );
  }
}
