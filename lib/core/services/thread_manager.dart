import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:css_mastery_app/services/error_logger.dart';

class ThreadManager {
  // ============================================================
  // 1. CHECK ISOLATE SUPPORT
  // ============================================================
  static final bool isIsolateSupported = () {
    try {
      final receivePort = ReceivePort();
      Isolate.spawn((message) {}, receivePort.sendPort);
      receivePort.close();
      return true;
    } catch (e) {
      return false;
    }
  }();

  // ============================================================
  // 2. RUN IN BACKGROUND ISOLATE
  // ============================================================
  static Future<T> runInBackground<T>(Future<T> Function() computation) async {
    // If isolates are not supported, run on main thread
    if (!isIsolateSupported || kIsWeb) {
      return await computation();
    }

    try {
      // Run in a separate isolate for heavy operations
      return await compute((message) async {
        return await computation();
      }, null);
    } catch (e) {
      debugPrint('⚠️ Isolate failed, falling back to main thread: $e');
      await ErrorLogger.logError(
        source: 'ThreadManager.runInBackground',
        message: e.toString(),
        severity: Severity.warning,
      );
      return await computation();
    }
  }

  // ============================================================
  // 3. RUN WITH DELAY
  // ============================================================
  static Future<void> runWithDelay(VoidCallback task, Duration delay) async {
    await Future.delayed(delay);
    task();
  }

  // ============================================================
  // 4. RUN WITH RETRY
  // ============================================================
  static Future<T> runWithRetry<T>(
    Future<T> Function() task, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await task();
      } catch (e) {
        attempts++;
        if (attempts == maxRetries) rethrow;
        await Future.delayed(delay * attempts);
        await ErrorLogger.logError(
          source: 'ThreadManager.runWithRetry',
          message: 'Attempt $attempts failed: $e',
          severity: Severity.warning,
        );
      }
    }
    throw Exception('All retry attempts failed');
  }

  // ============================================================
  // 5. BATCH PROCESS
  // ============================================================
  static Future<List<R>> batchProcess<T, R>(
    List<T> items,
    Future<R> Function(T) processor, {
    int batchSize = 10,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final results = <R>[];

    for (var i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(batch.map(processor));
      results.addAll(batchResults);

      if (i + batchSize < items.length) {
        await Future.delayed(delay);
      }
    }

    return results;
  }

  // ============================================================
  // 6. THROTTLE
  // ============================================================
  static Timer? _throttleTimer;

  static void throttle(VoidCallback callback, Duration delay) {
    if (_throttleTimer?.isActive ?? false) {
      _throttleTimer?.cancel();
    }
    _throttleTimer = Timer(delay, callback);
  }

  // ============================================================
  // 7. DEBOUNCE
  // ============================================================
  static Timer? _debounceTimer;

  static void debounce(VoidCallback callback, Duration delay) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // ============================================================
  // 8. SCHEDULED TASK
  // ============================================================
  static Timer scheduleTask(VoidCallback callback, Duration interval,
      {bool repeat = true}) {
    if (repeat) {
      return Timer.periodic(interval, (_) => callback());
    } else {
      return Timer(interval, callback);
    }
  }

  // ============================================================
  // 9. ASYNC MAP (Parallel Processing)
  // ============================================================
  static Future<List<R>> asyncMap<T, R>(
    List<T> items,
    Future<R> Function(T) mapper, {
    int concurrency = 5,
  }) async {
    final results = <R>[];
    final queue = List<T>.from(items);
    final List<Future<R>> running = [];

    while (queue.isNotEmpty || running.isNotEmpty) {
      // Fill up to concurrency
      while (running.length < concurrency && queue.isNotEmpty) {
        final item = queue.removeAt(0);
        late final Future<R> future;
        future = mapper(item).then((result) {
          running.remove(future);
          results.add(result);
          return result;
        });
        running.add(future);
      }

      // Wait for at least one to complete
      if (running.isNotEmpty) {
        await Future.any(running);
      }
    }

    return results;
  }

  // ============================================================
  // 10. GET MEMORY INFO
  // ============================================================
  static Future<Map<String, dynamic>> getMemoryInfo() async {
    if (kIsWeb) {
      // Web doesn't have access to memory info
      return {
        'used': 0,
        'total': 0,
        'percentage': 0,
      };
    }

    try {
      // This is a simplified version
      // For production, consider using dart:io or a package
      return {
        'used': 0,
        'total': 0,
        'percentage': 0,
      };
    } catch (e) {
      return {
        'used': 0,
        'total': 0,
        'percentage': 0,
        'error': e.toString(),
      };
    }
  }
}
