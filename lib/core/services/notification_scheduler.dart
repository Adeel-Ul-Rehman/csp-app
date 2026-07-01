import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:css_mastery_app/core/constants/app_strings.dart';
import 'package:css_mastery_app/services/error_logger.dart';

class NotificationScheduler {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // ============================================================
  // 1. INITIALIZE NOTIFICATIONS
  // ============================================================
  static Future<void> init() async {
    if (_isInitialized) return;

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

    _isInitialized = true;
    debugPrint('✅ Notification scheduler initialized');
  }

  // ============================================================
  // 2. NOTIFICATION TAP HANDLER
  // ============================================================
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');

    // Handle different notification types
    if (response.payload == 'daily_reminder') {
      // Open app to today's schedule
      debugPrint('📚 Open daily schedule');
    } else if (response.payload == 'reschedule_notification') {
      // Open app to syllabus
      debugPrint('📋 Open syllabus');
    } else if (response.payload == 'progress_reminder') {
      // Open app to progress
      debugPrint('📊 Open progress');
    }
  }

  // ============================================================
  // 3. SCHEDULE DAILY REMINDER
  // ============================================================
  static Future<void> scheduleDailyReminder(
      Map<String, dynamic> progress) async {
    try {
      final now = DateTime.now();
      final scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        8, // 8:00 AM
        0,
      );

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        AppStrings.notificationChannelId,
        AppStrings.notificationChannelName,
        channelDescription: AppStrings.notificationChannelDesc,
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
        '📚 Daily CSS Reminder',
        _getDailyReminderMessage(progress),
        tzScheduledDate,
        details,
        payload: 'daily_reminder',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('✅ Daily reminder scheduled for ${tzScheduledDate.toLocal()}');
    } catch (e) {
      debugPrint('❌ Failed to schedule daily reminder: $e');
      await ErrorLogger.logError(
        source: 'NotificationScheduler.scheduleDailyReminder',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  // ============================================================
  // 4. SEND RESCHEDULE NOTIFICATION
  // ============================================================
  static Future<void> sendRescheduleNotification(int rescheduledCount) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        AppStrings.notificationChannelId,
        AppStrings.notificationChannelName,
        channelDescription: AppStrings.notificationChannelDesc,
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
        2,
        '🔄 Auto-Rescheduled',
        "$rescheduledCount day${rescheduledCount > 1 ? 's' : ''} auto-rescheduled. Check your syllabus!",
        details,
        payload: 'reschedule_notification',
      );

      debugPrint('✅ Reschedule notification sent');
    } catch (e) {
      debugPrint('❌ Failed to send reschedule notification: $e');
      await ErrorLogger.logError(
        source: 'NotificationScheduler.sendRescheduleNotification',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  // ============================================================
  // 5. SEND PROGRESS REMINDER
  // ============================================================
  static Future<void> sendProgressReminder(Map<String, dynamic> stats) async {
    try {
      final pending = stats['pending'] ?? 0;
      final completed = stats['completed'] ?? 0;
      final total = stats['total'] ?? 0;
      final percentage =
          total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        AppStrings.notificationChannelId,
        AppStrings.notificationChannelName,
        channelDescription: AppStrings.notificationChannelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        3,
        '📊 Progress Update',
        '$pending days pending • $percentage% complete • Keep going! 💪',
        details,
        payload: 'progress_reminder',
      );

      debugPrint('✅ Progress reminder sent');
    } catch (e) {
      debugPrint('❌ Failed to send progress reminder: $e');
      await ErrorLogger.logError(
        source: 'NotificationScheduler.sendProgressReminder',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  // ============================================================
  // 6. SCHEDULE MOTIVATIONAL QUOTE
  // ============================================================
  static Future<void> scheduleMotivationalQuote() async {
    try {
      final quotes = [
        '💪 "Consistency beats talent when talent doesn\'t work hard."',
        '🌟 "Small daily improvements lead to stunning results."',
        '🎯 "Your future is created by what you do today."',
        '🚀 "The expert in anything was once a beginner."',
        '💡 "Learning never exhausts the mind."',
        '📚 "The beautiful thing about learning is nobody can take it away from you."',
        '🔥 "Success is the sum of small efforts repeated day in and day out."',
      ];

      final randomQuote = quotes[DateTime.now().second % quotes.length];

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        AppStrings.notificationChannelId,
        AppStrings.notificationChannelName,
        channelDescription: AppStrings.notificationChannelDesc,
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
        4,
        '✨ Daily Motivation',
        randomQuote,
        details,
        payload: 'motivation',
      );
    } catch (e) {
      debugPrint('❌ Failed to schedule motivational quote: $e');
    }
  }

  // ============================================================
  // 7. HELPERS
  // ============================================================
  static String _getDailyReminderMessage(Map<String, dynamic> progress) {
    final topics = progress['topics'] ?? 3;
    final completed = progress['completed'] ?? 1;
    final pending = topics - completed;

    if (pending <= 0) {
      return '🎉 You completed all topics for today! Great job!';
    } else if (pending == 1) {
      return '⚡ 1 topic pending today. Complete it now!';
    } else {
      return '📚 $pending topics pending today. Start learning now!';
    }
  }

  // ============================================================
  // 8. CANCEL NOTIFICATIONS
  // ============================================================
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🔕 All notifications cancelled');
  }

  // ============================================================
  // 9. CHECK PERMISSIONS
  // ============================================================
  static Future<bool> checkPermissions() async {
    final bool? isGranted = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return isGranted ?? false;
  }

  // ============================================================
  // 10. REQUEST PERMISSIONS
  // ============================================================
  static Future<void> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  static Future<void> showMotivationalQuote({
    required String title,
    required String quote,
    required String author,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            AppStrings.notificationChannelId,
            AppStrings.notificationChannelName,
            channelDescription: AppStrings.notificationChannelDesc,
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
        5,
        title,
        '"$quote"\n\n— $author',
        details,
        payload: 'motivation_quote',
      );

      debugPrint('✅ Motivational quote notification sent');
    } catch (e) {
      debugPrint('❌ Failed to send motivational quote: $e');
      await ErrorLogger.logError(
        source: 'NotificationScheduler.showMotivationalQuote',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }
}
