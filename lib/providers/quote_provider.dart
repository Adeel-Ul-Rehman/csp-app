import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/services/quote_scheduler.dart';
import 'package:css_mastery_app/models/quote_model.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteScheduler _scheduler = QuoteScheduler();
  QuoteModel? _currentQuote;
  bool _isLoading = false;

  QuoteModel? get currentQuote => _currentQuote;
  bool get isLoading => _isLoading;

  QuoteProvider() {
    // Listen for quote updates
    QuoteScheduler.onQuoteUpdated = (quote) {
      _currentQuote = quote;
      notifyListeners();
    };

    // Initialize and load current quote
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _scheduler.init();
      _currentQuote = await _scheduler.getCurrentQuote();
    } catch (e) {
      debugPrint('❌ QuoteProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual refresh for testing
  Future<void> refreshQuote() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _scheduler.manualRefresh();
      _currentQuote = await _scheduler.getCurrentQuote();
    } catch (e) {
      debugPrint('❌ Refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _scheduler.dispose();
    super.dispose();
  }
}
