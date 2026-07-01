import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class PerformanceMonitor {
  static bool _isMonitoring = false;
  static double _currentFPS = 60.0;
  static int _frameCount = 0;
  static DateTime? _lastFrameTime;
  static final Map<String, int> _widgetBuildCounts = {};
  static final Map<String, Duration> _widgetBuildTimes = {};

  // ============================================================
  // 1. INITIALIZE PERFORMANCE MONITOR
  // ============================================================
  static Future<void> init() async {
    if (_isMonitoring) return;

    _isMonitoring = true;

    // Start FPS monitoring
    _startFPSMonitoring();

    // Start widget build tracking (in debug mode only)
    if (kDebugMode) {
      _startWidgetTracking();
    }

    debugPrint('📊 Performance monitor started');
  }

  // ============================================================
  // 2. FPS MONITORING
  // ============================================================
  static void _startFPSMonitoring() {
    if (!kDebugMode) return;

    _lastFrameTime = DateTime.now();
    _frameCount = 0;

    // Use scheduler to track frames
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackFrame();
    });
  }

  static void _trackFrame() {
    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFrameTime!);

    if (elapsed.inSeconds >= 1) {
      _currentFPS = _frameCount / elapsed.inSeconds;
      _frameCount = 0;
      _lastFrameTime = now;

      developer.log(
        'FPS: ${_currentFPS.toStringAsFixed(1)}',
        name: 'PerformanceMonitor',
      );
    }

    // Schedule next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackFrame();
    });
  }

  // ============================================================
  // 3. WIDGET BUILD TRACKING
  // ============================================================
  static void _startWidgetTracking() {
    // This is a simplified version - in production,
    // consider using a dedicated performance package
    debugPrint('🔍 Widget build tracking started');
  }

  static void trackWidgetBuild(String widgetName) {
    if (!_isMonitoring) return;

    _widgetBuildCounts[widgetName] = (_widgetBuildCounts[widgetName] ?? 0) + 1;
  }

  static void trackWidgetBuildTime(String widgetName, Duration buildTime) {
    if (!_isMonitoring) return;

    _widgetBuildTimes[widgetName] = buildTime;
  }

  // ============================================================
  // 4. GET PERFORMANCE METRICS
  // ============================================================
  static Future<Map<String, dynamic>> getMetrics() async {
    return {
      'fps': _currentFPS,
      'isMonitoring': _isMonitoring,
      'widgetBuilds': _widgetBuildCounts,
      'platform': Platform.operatingSystem,
      'widgetBuildTimes': _widgetBuildTimes.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
    };
  }

  // ============================================================
  // 5. MEMORY USAGE
  // ============================================================
  static Future<Map<String, dynamic>> getMemoryUsage() async {
    // Note: This is a simplified version
    // For production, use dart:developer or a dedicated package
    return {
      'used': 0, // Placeholder
      'max': 0, // Placeholder
      'percentage': 0,
    };
  }

  // ============================================================
  // 6. GET FPS
  // ============================================================
  static Future<double> getFPS() async {
    return _currentFPS;
  }

  // ============================================================
  // 7. RESET MONITOR
  // ============================================================
  static Future<void> reset() async {
    _isMonitoring = false;
    _currentFPS = 60.0;
    _frameCount = 0;
    _lastFrameTime = null;
    _widgetBuildCounts.clear();
    _widgetBuildTimes.clear();
    debugPrint('🔄 Performance monitor reset');
  }

  // ============================================================
  // 8. REPORT PERFORMANCE ISSUES
  // ============================================================
  static void reportIssue(String issue) {
    if (!_isMonitoring) return;

    developer.log(
      '⚠️ Performance Issue: $issue',
      name: 'PerformanceMonitor',
      level: 1000,
    );
  }

  // ============================================================
  // 9. CHECK PERFORMANCE THRESHOLDS
  // ============================================================
  static bool isFPSHealthy() {
    return _currentFPS >= 30.0;
  }

  static bool isMemoryHealthy() {
    // Placeholder implementation
    return true;
  }
}
