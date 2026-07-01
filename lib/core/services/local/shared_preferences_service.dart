// lib/core/services/local/shared_preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String keyUserId = 'user_id';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotifications = 'notifications_enabled';
  static const String keyStudyReminderTime = 'study_reminder_time';
  static const String keyWeeklyOff = 'weekly_off';
  static const String keyAutoReschedule = 'auto_reschedule';
  static const String keyBufferDays = 'buffer_days';
  static const String keyDailyGoal = 'daily_goal_hours';

  // Getters
  static String? getUserId() => _prefs?.getString(keyUserId);
  static bool getIsLoggedIn() => _prefs?.getBool(keyIsLoggedIn) ?? false;
  static String getThemeMode() => _prefs?.getString(keyThemeMode) ?? 'dark';
  static bool getNotificationsEnabled() => _prefs?.getBool(keyNotifications) ?? true;
  static String getStudyReminderTime() => _prefs?.getString(keyStudyReminderTime) ?? '08:00';
  static String getWeeklyOff() => _prefs?.getString(keyWeeklyOff) ?? 'Sunday';
  static bool getAutoReschedule() => _prefs?.getBool(keyAutoReschedule) ?? true;
  static int getBufferDays() => _prefs?.getInt(keyBufferDays) ?? 30;
  static int getDailyGoal() => _prefs?.getInt(keyDailyGoal) ?? 4;

  // ✅ Fixed: Proper async setters
  static Future<void> setUserId(String value) async {
    await _prefs?.setString(keyUserId, value);
  }
  
  static Future<void> setIsLoggedIn(bool value) async {
    await _prefs?.setBool(keyIsLoggedIn, value);
  }
  
  static Future<void> setThemeMode(String value) async {
    await _prefs?.setString(keyThemeMode, value);
  }
  
  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool(keyNotifications, value);
  }
  
  static Future<void> setStudyReminderTime(String value) async {
    await _prefs?.setString(keyStudyReminderTime, value);
  }
  
  static Future<void> setWeeklyOff(String value) async {
    await _prefs?.setString(keyWeeklyOff, value);
  }
  
  static Future<void> setAutoReschedule(bool value) async {
    await _prefs?.setBool(keyAutoReschedule, value);
  }
  
  static Future<void> setBufferDays(int value) async {
    await _prefs?.setInt(keyBufferDays, value);
  }
  
  static Future<void> setDailyGoal(int value) async {
    await _prefs?.setInt(keyDailyGoal, value);
  }

  // Clear all
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }
}