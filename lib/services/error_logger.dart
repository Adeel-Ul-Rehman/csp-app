import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ErrorLogger {
  static const String _errorLogKey = 'error_log';
  static const int _maxLogEntries = 100;
  static const int _maxLogAgeDays = 30;

  // Log an error
  static Future<void> logError({
    required String source,
    required String message,
    String? stackTrace,
    Map<String, dynamic>? additionalData,
    Severity severity = Severity.error,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final logEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'source': source,
        'message': message,
        'stackTrace': stackTrace ?? '',
        'severity': severity.toString().split('.').last,
        'additionalData': additionalData ?? {},
        'appVersion': _getAppVersion(),
        'platform': _getPlatform(),
      };

      // Get existing log
      final existingLog = prefs.getString(_errorLogKey);
      List<dynamic> logList =
          existingLog != null ? jsonDecode(existingLog) as List : [];

      // Add new entry
      logList.add(logEntry);

      // Clean old entries
      logList = _cleanOldEntries(logList);

      // Keep only latest entries
      if (logList.length > _maxLogEntries) {
        logList = logList.sublist(logList.length - _maxLogEntries);
      }

      await prefs.setString(_errorLogKey, jsonEncode(logList));

      // Also print to console for debugging
      debugPrint('📝 [${severity.toString().split('.').last}] $source: $message');
    } catch (e) {
      // Silent fail for logging errors
      debugPrint('❌ Error logging failed: $e');
    }
  }

  // Get all error logs
  static Future<List<Map<String, dynamic>>> getErrorLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingLog = prefs.getString(_errorLogKey);
      if (existingLog == null) return [];

      final logList = jsonDecode(existingLog) as List;
      return logList.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  // Get errors by severity
  static Future<List<Map<String, dynamic>>> getErrorsBySeverity(
      Severity severity) async {
    final allErrors = await getErrorLog();
    return allErrors
        .where((e) => e['severity'] == severity.toString().split('.').last)
        .toList();
  }

  // Get errors by source
  static Future<List<Map<String, dynamic>>> getErrorsBySource(
      String source) async {
    final allErrors = await getErrorLog();
    return allErrors.where((e) => e['source'] == source).toList();
  }

  // Get recent errors (last 24 hours)
  static Future<List<Map<String, dynamic>>> getRecentErrors() async {
    final allErrors = await getErrorLog();
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));

    return allErrors.where((e) {
      final timestamp = DateTime.parse(e['timestamp'] as String);
      return timestamp.isAfter(cutoff);
    }).toList();
  }

  // Get error statistics
  static Future<Map<String, dynamic>> getErrorStats() async {
    final allErrors = await getErrorLog();

    final bySeverity = <String, int>{};
    final bySource = <String, int>{};
    int last24Hours = 0;

    final cutoff = DateTime.now().subtract(const Duration(hours: 24));

    for (var error in allErrors) {
      final severity = error['severity'] as String;
      final source = error['source'] as String;
      final timestamp = DateTime.parse(error['timestamp'] as String);

      bySeverity[severity] = (bySeverity[severity] ?? 0) + 1;
      bySource[source] = (bySource[source] ?? 0) + 1;

      if (timestamp.isAfter(cutoff)) {
        last24Hours++;
      }
    }

    String oldest = '';
    String newest = '';
    if (allErrors.isNotEmpty) {
      oldest = allErrors.first['timestamp'] as String? ?? '';
      newest = allErrors.last['timestamp'] as String? ?? '';
    }

    return {
      'total': allErrors.length,
      'bySeverity': bySeverity,
      'bySource': bySource,
      'last24Hours': last24Hours,
      'oldest': oldest,
      'newest': newest,
    };
  }

  // Clear error log
  static Future<void> clearErrorLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_errorLogKey);
      debugPrint('🗑️ Error log cleared');
    } catch (e) {
      // Silent fail
    }
  }

  // Clean old entries
  static List<dynamic> _cleanOldEntries(List<dynamic> logList) {
    final cutoff = DateTime.now().subtract(const Duration(days: _maxLogAgeDays));

    return logList.where((entry) {
      try {
        final timestamp = DateTime.parse(entry['timestamp'] as String);
        return timestamp.isAfter(cutoff);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get app version
  static String _getAppVersion() {
    // You can get this from pubspec.yaml
    return '1.0.0';
  }

  // Get platform
  static String _getPlatform() {
    if (Theme.of(WidgetsBinding.instance.rootElement!).platform ==
        TargetPlatform.android) {
      return 'Android';
    } else if (Theme.of(WidgetsBinding.instance.rootElement!).platform ==
        TargetPlatform.iOS) {
      return 'iOS';
    } else if (Theme.of(WidgetsBinding.instance.rootElement!).platform ==
        TargetPlatform.windows) {
      return 'Windows';
    } else if (Theme.of(WidgetsBinding.instance.rootElement!).platform ==
        TargetPlatform.macOS) {
      return 'macOS';
    } else if (Theme.of(WidgetsBinding.instance.rootElement!).platform ==
        TargetPlatform.linux) {
      return 'Linux';
    } else {
      return 'Web';
    }
  }
}

enum Severity {
  info,
  warning,
  error,
  critical,
}
