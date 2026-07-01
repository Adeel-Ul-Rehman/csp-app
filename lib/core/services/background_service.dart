import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:css_mastery_app/core/services/notification_scheduler.dart';
import 'package:css_mastery_app/core/services/thread_manager.dart';
import 'package:css_mastery_app/services/error_logger.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'daily_reminder':
          await BackgroundService.handleDailyReminder();
          break;
        case 'auto_reschedule':
          await BackgroundService.handleAutoReschedule();
          break;
        case 'progress_check':
          await BackgroundService.handleProgressCheck();
          break;
        case 'cleanup':
          await BackgroundService.handleCleanup();
          break;
        default:
          debugPrint('⚠️ Unknown background task: $task');
      }
    } catch (e) {
      debugPrint('❌ Background task error: $e');
      await ErrorLogger.logError(
        source: 'BackgroundService',
        message: 'Task $task failed: $e',
        severity: Severity.error,
      );
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static bool _isInitialized = false;
  static const String _dailyReminderTask = 'daily_reminder';
  static const String _autoRescheduleTask = 'auto_reschedule';
  static const String _progressCheckTask = 'progress_check';
  static const String _cleanupTask = 'cleanup';

  // ============================================================
  // 1. INITIALIZE BACKGROUND SERVICE
  // ============================================================
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize Workmanager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      // Register background tasks
      await _registerTasks();

      _isInitialized = true;
      debugPrint('✅ Background service initialized');
    } catch (e) {
      debugPrint('❌ Background service initialization error: $e');
      await ErrorLogger.logError(
        source: 'BackgroundService.init',
        message: e.toString(),
        severity: Severity.critical,
      );
    }
  }

  // ============================================================
  // 2. REGISTER TASKS
  // ============================================================
  static Future<void> _registerTasks() async {
    // Daily Reminder - Every day at 8:00 AM
    await Workmanager().registerPeriodicTask(
      _dailyReminderTask,
      _dailyReminderTask,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(8, 0),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
      ),
    );

    // Auto Reschedule - Every day at 12:00 AM
    await Workmanager().registerPeriodicTask(
      _autoRescheduleTask,
      _autoRescheduleTask,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(0, 0),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
      ),
    );

    // Progress Check - Every 6 hours
    await Workmanager().registerPeriodicTask(
      _progressCheckTask,
      _progressCheckTask,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
      ),
    );

    // Cleanup - Every 7 days
    await Workmanager().registerPeriodicTask(
      _cleanupTask,
      _cleanupTask,
      frequency: const Duration(days: 7),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );

    debugPrint('✅ Background tasks registered');
  }

  // ============================================================
  // 3. TASK HANDLERS
  // ============================================================

  static Future<void> handleDailyReminder() async {
    debugPrint('🔔 Handling daily reminder...');

    try {
      // Get current day progress
      final progress = await ThreadManager.runInBackground(() async {
        // This runs in a separate thread
        return await _getDailyProgress();
      });

      // Send notification
      await NotificationScheduler.scheduleDailyReminder(progress);

      debugPrint('✅ Daily reminder sent');
    } catch (e) {
      debugPrint('❌ Daily reminder error: $e');
      await ErrorLogger.logError(
        source: 'BackgroundService.handleDailyReminder',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  static Future<void> handleAutoReschedule() async {
    debugPrint('🔄 Handling auto-reschedule...');

    try {
      // Run heavy operation in background thread
      final result = await ThreadManager.runInBackground(() async {
        return await _autoReschedulePendingDays();
      });

      if (result > 0) {
        debugPrint('✅ Auto-rescheduled $result days');

        // Send notification about rescheduling
        await NotificationScheduler.sendRescheduleNotification(result);
      }
    } catch (e) {
      debugPrint('❌ Auto-reschedule error: $e');
      await ErrorLogger.logError(
        source: 'BackgroundService.handleAutoReschedule',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  static Future<void> handleProgressCheck() async {
    debugPrint('📊 Handling progress check...');

    try {
      final stats = await ThreadManager.runInBackground(() async {
        return await _getProgressStats();
      });

      if (stats['pending'] > 3) {
        await NotificationScheduler.sendProgressReminder(stats);
      }
    } catch (e) {
      debugPrint('❌ Progress check error: $e');
      await ErrorLogger.logError(
        source: 'BackgroundService.handleProgressCheck',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  static Future<void> handleCleanup() async {
    debugPrint('🧹 Handling cleanup...');

    try {
      // Clean old chat history
      await ThreadManager.runInBackground(() async {
        await _cleanOldChatHistory();
        return true;
      });

      debugPrint('✅ Cleanup completed');
    } catch (e) {
      debugPrint('❌ Cleanup error: $e');
      await ErrorLogger.logError(
        source: 'BackgroundService.handleCleanup',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  // ============================================================
  // 4. HELPERS
  // ============================================================

  static Duration _calculateInitialDelay(int hour, int minute) {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledTime.isBefore(now)) {
      return Duration(
        seconds: scheduledTime
            .add(const Duration(days: 1))
            .difference(now)
            .inSeconds,
      );
    }

    return Duration(
      seconds: scheduledTime.difference(now).inSeconds,
    );
  }

  static Future<Map<String, dynamic>> _getDailyProgress() async {
    // Simulate getting daily progress
    // In production, this would query the database
    return {
      'day': DateTime.now().day,
      'topics': 3,
      'completed': 1,
      'pending': 2,
    };
  }

  static Future<int> _autoReschedulePendingDays() async {
    // Simulate auto-reschedule logic
    // In production, this would check and reschedule pending days
    await Future.delayed(const Duration(seconds: 1));
    return 2; // Number of days rescheduled
  }

  static Future<Map<String, dynamic>> _getProgressStats() async {
    // Simulate getting progress stats
    return {
      'total': 30,
      'completed': 15,
      'pending': 5,
      'offDays': 10,
    };
  }

  static Future<void> _cleanOldChatHistory() async {
    // In production, this would delete old chat messages
    // Keep only last 500 messages
    debugPrint('🧹 Cleaning old chat history...');
  }
}
