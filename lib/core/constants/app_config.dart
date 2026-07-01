class AppConfig {
  // ============================================================
  // APP INFORMATION
  // ============================================================
  static const String appName = 'Mission Aqsa';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appEnvironment =
      'production'; // 'development', 'staging', 'production'

  // ============================================================
  // FEATURE FLAGS
  // ============================================================
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableDebugLogs = false;
  static const bool enableCaching = true;
  static const bool enableVoiceInput = true;
  static const bool enableExport = true;

  // ============================================================
  // PERFORMANCE SETTINGS
  // ============================================================
  static const int cacheMaxAgeDays = 7;
  static const int cacheMaxSize = 100;
  static const int maxConcurrentDownloads = 3;
  static const int imageCacheSize = 50; // MB
  static const int networkTimeoutSeconds = 30;

  // ============================================================
  // UI SETTINGS
  // ============================================================
  static const int maxRecentChatMessages = 50;
  static const int maxSuggestedPrompts = 6;
  static const int maxErrorLogs = 100;
  static const int maxChatHistory = 500;

  // ============================================================
  // DEPLOYMENT SETTINGS
  // ============================================================
  static const String baseUrl = 'https://css-mastery-app.com';
  static const String apiEndpoint = '$baseUrl/api/v1';
  static const String webBasePath = '/';

  // ============================================================
  // HELPER METHODS
  // ============================================================
  static bool get isProduction => appEnvironment == 'production';
  static bool get isDevelopment => appEnvironment == 'development';
  static bool get isStaging => appEnvironment == 'staging';

  static String getAppInfo() {
    return '${appName}_v${appVersion}_$appEnvironment';
  }

  static Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'appBuildNumber': appBuildNumber,
      'appEnvironment': appEnvironment,
      'isProduction': isProduction,
    };
  }
}
