// lib/core/constants/app_strings.dart

class AppStrings {
  static const String appName = 'Mission Aqsa';
  static const String appVersion = '1.0.0';

  // ============ AI API URLs (All Free, No API Key) ============

  // PRIMARY: DevToolBox API (Cloudflare Workers)
  // Limit: 10,000 neurons/day (~500-1000 requests)
  // Best For: Fast responses, high reliability
  static const String devToolBoxUrl =
      'https://devtoolbox-api.devtoolbox-api.workers.dev/ai/generate';

  // FALLBACK 1: python-tgpt API
  // Limit: Depends on internal providers, typically 1000+ requests/day
  // Best For: Backup when primary fails, 45+ providers internally
  static const String pythonTgptUrl = 'https://api.pythontgpt.com/generate';

  // FALLBACK 2: HuggingFace Inference API (Free Tier)
  // Limit: Rate limited, ~50-100 requests/day
  // Best For: Last resort, uses Mistral-7B model
  static const String huggingFaceUrl =
      'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1';

  // ============ NOTIFICATION CHANNELS ============
  static const String notificationChannelId = 'css_mastery_channel';
  static const String notificationChannelName = 'CSS Mastery Notifications';
  static const String notificationChannelDesc =
      'Daily study reminders and updates';

  // ============ CACHE SETTINGS ============
  static const int cacheMaxAgeDays = 7; // Cache lifetime
  static const int cacheMaxSize = 100; // Max cached questions

  // ============ RATE LIMITS ============
  static const int devToolBoxDailyLimit = 500;
  static const int pythonTgptDailyLimit = 1000;
  static const int huggingFaceDailyLimit = 50;
}
