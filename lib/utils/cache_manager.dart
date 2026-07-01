// lib/core/utils/cache_manager.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:css_mastery_app/core/constants/app_strings.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  static const String _cacheKey = 'ai_response_cache';
  static const String _cacheTimestampsKey = 'ai_cache_timestamps';

  Map<String, String> _cache = {};
  Map<String, DateTime> _timestamps = {};

  // Initialize cache from shared preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load cache
    final cacheJson = prefs.getString(_cacheKey);
    if (cacheJson != null) {
      _cache = Map<String, String>.from(jsonDecode(cacheJson));
    }

    // Load timestamps
    final timestampsJson = prefs.getString(_cacheTimestampsKey);
    if (timestampsJson != null) {
      final map = Map<String, String>.from(jsonDecode(timestampsJson));
      _timestamps =
          map.map((key, value) => MapEntry(key, DateTime.parse(value)));
    }

    // Clean expired cache
    _cleanExpiredCache();
  }

  // Get cached response
  String? getCachedResponse(String question) {
    final key = _generateKey(question);

    // Check if exists and not expired
    if (_cache.containsKey(key) && _timestamps.containsKey(key)) {
      final age = DateTime.now().difference(_timestamps[key]!);
      if (age.inDays < AppStrings.cacheMaxAgeDays) {
        return _cache[key];
      }
    }

    return null;
  }

  // Save response to cache
  Future<void> saveResponse(String question, String response) async {
    final key = _generateKey(question);

    // Check if cache is full
    if (_cache.length >= AppStrings.cacheMaxSize) {
      _removeOldestCache();
    }

    _cache[key] = response;
    _timestamps[key] = DateTime.now();
    await _persistCache();
  }

  // Generate unique key for question
  String _generateKey(String question) {
    // Remove extra spaces, convert to lowercase
    final normalized = question.trim().toLowerCase();
    // Create simple hash (first 50 chars + length)
    final hash = normalized.substring(
        0, normalized.length > 50 ? 50 : normalized.length);
    return '${hash}_${normalized.length}';
  }

  // Remove oldest cache entry
  void _removeOldestCache() {
    if (_timestamps.isEmpty) return;

    // Find oldest entry
    String? oldestKey;
    DateTime? oldestTime;

    _timestamps.forEach((key, time) {
      if (oldestTime == null || time.isBefore(oldestTime!)) {
        oldestTime = time;
        oldestKey = key;
      }
    });

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _timestamps.remove(oldestKey);
    }
  }

  // Clean expired cache entries
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _timestamps.forEach((key, time) {
      if (now.difference(time).inDays >= AppStrings.cacheMaxAgeDays) {
        keysToRemove.add(key);
      }
    });

    for (var key in keysToRemove) {
      _cache.remove(key);
      _timestamps.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      _persistCache();
    }
  }

  // Persist cache to shared preferences
  Future<void> _persistCache() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_cacheKey, jsonEncode(_cache));

    final timestampsJson =
        _timestamps.map((key, value) => MapEntry(key, value.toIso8601String()));
    await prefs.setString(_cacheTimestampsKey, jsonEncode(timestampsJson));
  }

  // Clear all cache
  Future<void> clearCache() async {
    _cache.clear();
    _timestamps.clear();
    await _persistCache();
  }

  // Get cache stats
  Map<String, dynamic> getStats() {
    return {
      'totalCached': _cache.length,
      'maxSize': AppStrings.cacheMaxSize,
      'expiryDays': AppStrings.cacheMaxAgeDays,
      'oldestEntry': _timestamps.values.fold<DateTime?>(
        null,
        (min, time) => min == null || time.isBefore(min) ? time : min,
      ),
    };
  }
}
