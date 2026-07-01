// lib/core/services/background/notification_service.dart
import 'package:flutter/material.dart' show TimeOfDay, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  // Show daily reminder
  static Future<void> showDailyReminder() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily study reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '📚 Time to Study!',
      'Your daily CSS lesson is waiting. Stay consistent! 💪',
      details,
      payload: 'daily_reminder',
    );
  }

  // Schedule daily notification
  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time is in past, schedule for tomorrow
    final finalDate = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    final tzScheduledDate = tz.TZDateTime.from(finalDate, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily study reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      1,
      '📚 Time to Study!',
      'Complete your daily CSS mission today! 🎯',
      tzScheduledDate,
      details,
      payload: 'daily_reminder',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Show progress reminder
  static Future<void> showProgressReminder(int completed, int total) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'progress_channel',
          'Progress Updates',
          channelDescription: 'Progress reminders',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      '📊 Progress Update',
      'You have completed $completed out of $total days! Keep going! 🚀',
      details,
      payload: 'progress_update',
    );
  }

  // Show motivation quote
  static Future<void> showMotivationQuote() async {
    final quotes = [
      '💪 "Consistency beats talent when talent doesn\'t work hard."',
      '🌟 "Small daily improvements lead to stunning results."',
      '🎯 "Your future is created by what you do today."',
      '🚀 "The expert in anything was once a beginner."',
      '💡 "Learning never exhausts the mind."',
    ];

    final randomQuote = quotes[DateTime.now().second % quotes.length];

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'motivation_channel',
          'Daily Motivation',
          channelDescription: 'Motivational quotes',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      '✨ Daily Motivation',
      randomQuote,
      details,
      payload: 'motivation',
    );
  }

  // Show general notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Check permissions
  static Future<bool> checkPermissions() async {
    final bool? isGranted = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return isGranted ?? false;
  }

  // Request permissions
  static Future<void> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }
}