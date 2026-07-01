// lib/core/utils/rate_limit_manager.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:css_mastery_app/models/chat/chat_provider_model.dart';

class RateLimitManager {
  static final RateLimitManager _instance = RateLimitManager._internal();
  factory RateLimitManager() => _instance;
  RateLimitManager._internal();

  static const String _usageKey = 'provider_usage';

  Map<String, int> _usage = {};
  DateTime? _lastReset;
  bool _isInitialized = false;

  // Initialize from shared preferences
  Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Load usage data
    final usageJson = prefs.getString(_usageKey);
    if (usageJson != null) {
      _usage = Map<String, int>.from(jsonDecode(usageJson));
    }

    // Check if reset needed
    await _checkAndResetDaily();

    _isInitialized = true;
  }

  // Check if provider can be used
  Future<bool> canUseProvider(String providerName, int dailyLimit) async {
    await init();

    // Reset if needed
    await _checkAndResetDaily();

    final used = _usage[providerName] ?? 0;
    return used < dailyLimit;
  }

  // Record usage for provider
  Future<void> recordUsage(String providerName) async {
    await init();

    _usage[providerName] = (_usage[providerName] ?? 0) + 1;
    await _persistUsage();
  }

  // Get remaining quota for provider
  Future<int> getRemainingQuota(String providerName, int dailyLimit) async {
    await init();
    await _checkAndResetDaily();

    final used = _usage[providerName] ?? 0;
    return dailyLimit - used;
  }

  // Get usage percentage
  Future<double> getUsagePercentage(String providerName, int dailyLimit) async {
    await init();
    await _checkAndResetDaily();

    final used = _usage[providerName] ?? 0;
    return dailyLimit > 0 ? (used / dailyLimit * 100) : 0;
  }

  // Get best available provider
  Future<AIProviderModel?> getBestAvailableProvider() async {
    await init();
    await _checkAndResetDaily();

    final providers = AIProviderModel.getAllProviders()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    for (var provider in providers) {
      final canUse = await canUseProvider(provider.name, provider.dailyLimit);
      if (canUse && provider.isAvailable) {
        return provider;
      }
    }

    return null;
  }

  // Get all provider status
  Future<List<Map<String, dynamic>>> getProviderStatus() async {
    await init();
    await _checkAndResetDaily();

    final status = <Map<String, dynamic>>[];
    final providers = AIProviderModel.getAllProviders();

    for (var provider in providers) {
      final used = _usage[provider.name] ?? 0;
      final remaining = provider.dailyLimit - used;
      final percentage =
          provider.dailyLimit > 0 ? (used / provider.dailyLimit * 100) : 0;

      status.add({
        'name': provider.name,
        'used': used,
        'limit': provider.dailyLimit,
        'remaining': remaining,
        'percentage': percentage,
        'isAvailable': remaining > 0,
        'type': provider.type.toString().split('.').last,
      });
    }

    return status;
  }

  // Check and reset daily usage
  Future<void> _checkAndResetDaily() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastReset == null || _lastReset!.isBefore(today)) {
      // Reset all usage
      _usage.clear();
      _lastReset = now;
      await _persistUsage();
    }
  }

  // Persist usage data
  Future<void> _persistUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usageKey, jsonEncode(_usage));
  }

  // Reset all usage (manual)
  Future<void> resetAllUsage() async {
    _usage.clear();
    _lastReset = DateTime.now();
    await _persistUsage();
  }

  // Get usage summary
  Future<Map<String, dynamic>> getUsageSummary() async {
    await init();
    await _checkAndResetDaily();

    final summary = <String, dynamic>{};
    final providers = AIProviderModel.getAllProviders();

    for (var provider in providers) {
      final used = _usage[provider.name] ?? 0;
      summary[provider.name] = {
        'used': used,
        'limit': provider.dailyLimit,
        'remaining': provider.dailyLimit - used,
        'percentage':
            provider.dailyLimit > 0 ? (used / provider.dailyLimit * 100) : 0,
      };
    }

    return summary;
  }
}
