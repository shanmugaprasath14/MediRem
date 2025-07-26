// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter/material.dart';
import 'dart:convert';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      _notificationsPlugin;

  static Future<void> initialize(DidReceiveNotificationResponseCallback onDidReceiveResponse) async {
    tzdata.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveResponse,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medirem_channel',
      'Medication Reminders',
      description: 'Channel for scheduling medication notifications',
      importance: Importance.max,
      playSound: true, // Keep this true for the channel, but override in NotificationDetails
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required TimeOfDay time,
    required int id,
    String? medicineName,
    String? imagePath,
    String? customSoundPath,
    int? pillCount, // Added pillCount parameter
  }) async {
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final tz.TZDateTime tzDateTime =
    tz.TZDateTime.from(scheduledDate, tz.local).isBefore(tz.TZDateTime.now(tz.local))
        ? tz.TZDateTime.from(scheduledDate.add(const Duration(days: 1)), tz.local)
        : tz.TZDateTime.from(scheduledDate, tz.local);

    final payload = json.encode({
      'id': id,
      'medicineName': medicineName,
      'imagePath': imagePath,
      'customSoundPath': customSoundPath, // Pass the custom sound path in payload
      'pillCount': pillCount, // Pass the pillCount in payload
    });

    debugPrint('--- NOTIFICATION SCHEDULE DEBUG ---');
    debugPrint('Current TZ time: ${tz.TZDateTime.now(tz.local).toIso8601String()}');
    debugPrint('Scheduled TZ time: ${tzDateTime.toIso8601String()}');
    debugPrint('Notification ID: $id');
    debugPrint('Title: $title, Body: $body');
    debugPrint('Payload: $payload');
    debugPrint('Custom Sound Path for Scheduling: $customSoundPath');
    debugPrint('Pill Count for Scheduling: $pillCount');
    debugPrint('--- END DEBUG ---');

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medirem_channel',
          'Medication Reminders',
          channelDescription: 'Channel for scheduling medication notifications',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          playSound: true, // Set to true here!
          sound: RawResourceAndroidNotificationSound('iphone_alarm'), // Reference by filename without extension
          category: AndroidNotificationCategory.alarm,
          autoCancel: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false, // Set to false: AlarmPage will play the sound
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint('Notification with ID $id cancelled.');
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('All notifications cancelled.');
  }

  static Future<void> listPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotifications =
    await _notificationsPlugin.pendingNotificationRequests();
    debugPrint('--- Pending Notifications ---');
    if (pendingNotifications.isEmpty) {
      debugPrint('No pending notifications.');
    } else {
      for (var notification in pendingNotifications) {
        debugPrint('ID: ${notification.id}, Title: ${notification.title}, Payload: ${notification.payload}');
      }
    }
    debugPrint('---------------------------');
  }
}