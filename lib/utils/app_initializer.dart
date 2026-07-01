import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:css_mastery_app/utils/performance_optimizer.dart';
import 'package:css_mastery_app/services/performance_monitor.dart';

class AppInitializer {
  static bool _isInitialized = false;

  // ============================================================
  // 1. INITIALIZE ALL SERVICES
  // ============================================================
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize SharedPreferences first
      await SharedPreferences.getInstance();

      // Initialize Performance Monitor
      await PerformanceMonitor.init();

      // Clear memory if needed
      PerformanceOptimizer.clearMemory();

      // Mark as initialized
      _isInitialized = true;

      debugPrint('✅ App initialized successfully');
      debugPrint('📊 Performance monitoring active');
    } catch (e) {
      debugPrint('❌ App initialization error: $e');
      rethrow;
    }
  }

  // ============================================================
  // 2. CHECK INITIALIZATION STATUS
  // ============================================================
  static bool get isInitialized => _isInitialized;

  // ============================================================
  // 3. RESET APP STATE (For testing)
  // ============================================================
  static Future<void> resetState() async {
    _isInitialized = false;
    PerformanceOptimizer.clearMemory();
    await PerformanceMonitor.reset();
    debugPrint('🔄 App state reset');
  }

  // ============================================================
  // 4. PERFORMANCE CHECK
  // ============================================================
  static Future<Map<String, dynamic>> getPerformanceStats() async {
    return {
      'isInitialized': _isInitialized,
      'memoryUsage': await PerformanceMonitor.getMemoryUsage(),
      'fps': await PerformanceMonitor.getFPS(),
    };
  }
}
