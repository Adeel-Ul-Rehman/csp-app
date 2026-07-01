import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:css_mastery_app/core/services/quote_service.dart';
import 'package:css_mastery_app/core/services/quote_storage.dart';
import 'package:css_mastery_app/core/services/notification_scheduler.dart';
import 'package:css_mastery_app/models/quote_model.dart';
import 'package:css_mastery_app/services/error_logger.dart';

class QuoteScheduler {
  static final QuoteScheduler _instance = QuoteScheduler._internal();
  factory QuoteScheduler() => _instance;
  QuoteScheduler._internal();

  final QuoteService _quoteService = QuoteService();
  final QuoteStorage _storage = QuoteStorage();
  Timer? _morningTimer;
  Timer? _eveningTimer;
  bool _isInitialized = false;

  // Quote update callback for UI
  static Function(QuoteModel?)? onQuoteUpdated;

  // ============================================================
  // 1. INITIALIZE SCHEDULER
  // ============================================================
  Future<void> init() async {
    if (_isInitialized) return;

    await _storage.init();
    await _refreshQuotesIfNeeded();

    // Schedule daily tasks
    _scheduleMorningQuote();
    _scheduleEveningQuote();

    _isInitialized = true;
    debugPrint('✅ Quote scheduler initialized');
  }

  // ============================================================
  // 2. REFRESH QUOTES IF NEEDED
  // ============================================================
  Future<void> _refreshQuotesIfNeeded() async {
    try {
      final needsRefresh = await _storage.needsRefresh();
      final hasQuotes = await _storage.hasQuotes();

      if (needsRefresh || !hasQuotes) {
        debugPrint('🔄 Refreshing weekly quotes...');
        final quotes = await _quoteService.fetchWeeklyQuotes();

        if (quotes.isNotEmpty) {
          await _storage.saveWeeklyQuotes(quotes);
          debugPrint('✅ Weekly quotes refreshed');
        }
      } else {
        debugPrint('📚 Using cached quotes');
      }
    } catch (e) {
      debugPrint('❌ Error refreshing quotes: $e');
      await ErrorLogger.logError(
        source: 'QuoteScheduler._refreshQuotesIfNeeded',
        message: e.toString(),
        severity: Severity.warning,
      );
    }
  }

  // ============================================================
  // 3. SCHEDULE MORNING QUOTE (6:00 AM - 8:00 AM)
  // ============================================================
  void _scheduleMorningQuote() {
    final now = DateTime.now();
    final morningTime = DateTime(
      now.year,
      now.month,
      now.day,
      6, // 6:00 AM
      0,
    );

    // If morning time has passed today, schedule for tomorrow
    final scheduledTime = morningTime.isBefore(now)
        ? morningTime.add(const Duration(days: 1))
        : morningTime;

    final delay = scheduledTime.difference(now);

    _morningTimer = Timer(delay, () {
      _deliverMorningQuote();
      // Reschedule for next day
      _scheduleMorningQuote();
    });

    debugPrint('🌅 Morning quote scheduled at ${scheduledTime.toLocal()}');
  }

  // ============================================================
  // 4. SCHEDULE EVENING QUOTE (8:00 PM - 10:00 PM)
  // ============================================================
  void _scheduleEveningQuote() {
    final now = DateTime.now();
    final eveningTime = DateTime(
      now.year,
      now.month,
      now.day,
      20, // 8:00 PM
      0,
    );

    // If evening time has passed today, schedule for tomorrow
    final scheduledTime = eveningTime.isBefore(now)
        ? eveningTime.add(const Duration(days: 1))
        : eveningTime;

    final delay = scheduledTime.difference(now);

    _eveningTimer = Timer(delay, () {
      _deliverEveningQuote();
      // Reschedule for next day
      _scheduleEveningQuote();
    });

    debugPrint('🌙 Evening quote scheduled at ${scheduledTime.toLocal()}');
  }

  // ============================================================
  // 5. DELIVER MORNING QUOTE
  // ============================================================
  Future<void> _deliverMorningQuote() async {
    try {
      final quote = await _storage.getCurrentMorningQuote();

      if (quote != null) {
        // Send notification
        await NotificationScheduler.showMotivationalQuote(
          title: '🌅 Good Morning!',
          quote: quote.text,
          author: quote.author,
        );

        // Update Home screen
        onQuoteUpdated?.call(quote);

        // Mark as used
        await _storage.markMorningQuoteUsed();

        // Prepare next week's quotes if running low
        await _prepareNextWeekQuotes();

        debugPrint('✅ Morning quote delivered: "${quote.text}"');
      } else {
        // No more quotes, refresh
        await _refreshQuotesIfNeeded();
        // Try again
        final newQuote = await _storage.getCurrentMorningQuote();
        if (newQuote != null) {
          await _deliverMorningQuote();
        }
      }
    } catch (e) {
      debugPrint('❌ Error delivering morning quote: $e');
      await ErrorLogger.logError(
        source: 'QuoteScheduler._deliverMorningQuote',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  // ============================================================
  // 6. DELIVER EVENING QUOTE
  // ============================================================
  Future<void> _deliverEveningQuote() async {
    try {
      final quote = await _storage.getCurrentEveningQuote();

      if (quote != null) {
        // Send notification
        await NotificationScheduler.showMotivationalQuote(
          title: '🌙 Evening Inspiration',
          quote: quote.text,
          author: quote.author,
        );

        // Update Home screen
        onQuoteUpdated?.call(quote);

        // Mark as used
        await _storage.markEveningQuoteUsed();

        // Prepare next week's quotes if running low
        await _prepareNextWeekQuotes();

        debugPrint('✅ Evening quote delivered: "${quote.text}"');
      } else {
        // No more quotes, refresh
        await _refreshQuotesIfNeeded();
        // Try again
        final newQuote = await _storage.getCurrentEveningQuote();
        if (newQuote != null) {
          await _deliverEveningQuote();
        }
      }
    } catch (e) {
      debugPrint('❌ Error delivering evening quote: $e');
      await ErrorLogger.logError(
        source: 'QuoteScheduler._deliverEveningQuote',
        message: e.toString(),
        severity: Severity.error,
      );
    }
  }

  // ============================================================
  // 7. PREPARE NEXT WEEK'S QUOTES
  // ============================================================
  Future<void> _prepareNextWeekQuotes() async {
    try {
      final remaining = await _storage.getQuoteCount();
      final currentIndex = await _storage.getCurrentIndex();

      // If less than 4 quotes remaining, fetch next batch
      if (remaining - currentIndex <= 4) {
        debugPrint('🔄 Preparing next week\'s quotes...');
        final quotes = await _quoteService.fetchWeeklyQuotes();
        if (quotes.isNotEmpty) {
          // Append to existing quotes or replace
          await _storage.saveWeeklyQuotes(quotes);
          debugPrint('✅ Next week\'s quotes prepared');
        }
      }
    } catch (e) {
      debugPrint('❌ Error preparing next week quotes: $e');
    }
  }

  // ============================================================
  // 8. GET CURRENT QUOTE (For Home Screen)
  // ============================================================
  Future<QuoteModel?> getCurrentQuote() async {
    try {
      final morningQuote = await _storage.getCurrentMorningQuote();
      if (morningQuote != null) return morningQuote;

      final eveningQuote = await _storage.getCurrentEveningQuote();
      return eveningQuote;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 9. MANUAL QUOTE REFRESH (For testing)
  // ============================================================
  Future<void> manualRefresh() async {
    debugPrint('🔄 Manual quote refresh triggered');
    await _refreshQuotesIfNeeded();
    await _deliverMorningQuote();
  }

  // ============================================================
  // 10. DISPOSE
  // ============================================================
  void dispose() {
    _morningTimer?.cancel();
    _eveningTimer?.cancel();
    _isInitialized = false;
  }
}
