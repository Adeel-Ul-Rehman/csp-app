import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:css_mastery_app/models/quote_model.dart';

class QuoteStorage {
  static const String _quotesKey = 'weekly_quotes';
  static const String _currentIndexKey = 'current_quote_index';
  static const String _lastFetchKey = 'last_quote_fetch';
  static const String _weekStartKey = 'week_start_date';
  static const String _morningQuoteIdKey = 'morning_quote_id';
  static const String _eveningQuoteIdKey = 'evening_quote_id';

  static final QuoteStorage _instance = QuoteStorage._internal();
  factory QuoteStorage() => _instance;
  QuoteStorage._internal();

  SharedPreferences? _prefs;

  // ============================================================
  // 1. INITIALIZE
  // ============================================================
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============================================================
  // 2. SAVE WEEKLY QUOTES
  // ============================================================
  Future<void> saveWeeklyQuotes(List<QuoteModel> quotes) async {
    if (_prefs == null) return;

    try {
      final jsonList = quotes.map((q) => q.toJson()).toList();
      await _prefs!.setString(_quotesKey, jsonEncode(jsonList));
      await _prefs!.setInt(_currentIndexKey, 0);
      await _prefs!.setString(_lastFetchKey, DateTime.now().toIso8601String());

      // Calculate week start (Monday)
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      await _prefs!.setString(_weekStartKey, weekStart.toIso8601String());

      debugPrint('💾 Saved ${quotes.length} quotes for the week');
    } catch (e) {
      debugPrint('❌ Error saving quotes: $e');
    }
  }

  // ============================================================
  // 3. LOAD WEEKLY QUOTES
  // ============================================================
  Future<List<QuoteModel>> loadWeeklyQuotes() async {
    if (_prefs == null) return [];

    try {
      final jsonString = _prefs!.getString(_quotesKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => QuoteModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error loading quotes: $e');
      return [];
    }
  }

  // ============================================================
  // 4. GET CURRENT QUOTE (Morning)
  // ============================================================
  Future<QuoteModel?> getCurrentMorningQuote() async {
    final quotes = await loadWeeklyQuotes();
    if (quotes.isEmpty) return null;

    final index = _prefs?.getInt(_currentIndexKey) ?? 0;
    if (index >= quotes.length) return null;

    return quotes[index];
  }

  // ============================================================
  // 5. GET EVENING QUOTE
  // ============================================================
  Future<QuoteModel?> getCurrentEveningQuote() async {
    final quotes = await loadWeeklyQuotes();
    if (quotes.isEmpty || quotes.length < 2) return null;

    final index = (_prefs?.getInt(_currentIndexKey) ?? 0) + 1;
    if (index >= quotes.length) return null;

    return quotes[index];
  }

  // ============================================================
  // 6. GET QUOTE BY ID
  // ============================================================
  Future<QuoteModel?> getQuoteById(String id) async {
    final quotes = await loadWeeklyQuotes();
    try {
      return quotes.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 7. MARK QUOTE AS USED (Morning)
  // ============================================================
  Future<void> markMorningQuoteUsed() async {
    if (_prefs == null) return;

    final currentIndex = _prefs!.getInt(_currentIndexKey) ?? 0;
    await _prefs!.setInt(_currentIndexKey, currentIndex + 1);
    await _prefs!.setString(_morningQuoteIdKey, 'used');
  }

  // ============================================================
  // 8. MARK QUOTE AS USED (Evening)
  // ============================================================
  Future<void> markEveningQuoteUsed() async {
    if (_prefs == null) return;

    final currentIndex = _prefs!.getInt(_currentIndexKey) ?? 0;
    await _prefs!.setInt(_currentIndexKey, currentIndex + 1);
    await _prefs!.setString(_eveningQuoteIdKey, 'used');
  }

  // ============================================================
  // 9. CHECK IF NEEDS REFRESH
  // ============================================================
  Future<bool> needsRefresh() async {
    if (_prefs == null) return true;

    final lastFetch = _prefs!.getString(_lastFetchKey);
    if (lastFetch == null) return true;

    try {
      final lastFetchDate = DateTime.parse(lastFetch);
      final daysSince = DateTime.now().difference(lastFetchDate).inDays;

      // Refresh if more than 7 days old
      return daysSince >= 7;
    } catch (e) {
      return true;
    }
  }

  // ============================================================
  // 10. CHECK IF QUOTES EXIST
  // ============================================================
  Future<bool> hasQuotes() async {
    final quotes = await loadWeeklyQuotes();
    return quotes.isNotEmpty;
  }

  // ============================================================
  // 11. GET NEXT QUOTE (For testing)
  // ============================================================
  Future<QuoteModel?> getNextQuote() async {
    final quotes = await loadWeeklyQuotes();
    if (quotes.isEmpty) return null;

    final currentIndex = _prefs?.getInt(_currentIndexKey) ?? 0;
    if (currentIndex >= quotes.length) return null;

    return quotes[currentIndex];
  }

  // ============================================================
  // 12. GET QUOTE COUNT
  // ============================================================
  Future<int> getQuoteCount() async {
    final quotes = await loadWeeklyQuotes();
    return quotes.length;
  }

  // ============================================================
  // 13. GET CURRENT INDEX
  // ============================================================
  Future<int> getCurrentIndex() async {
    if (_prefs == null) return 0;
    return _prefs!.getInt(_currentIndexKey) ?? 0;
  }

  // ============================================================
  // 14. CLEAR QUOTES
  // ============================================================
  Future<void> clearQuotes() async {
    if (_prefs == null) return;
    await _prefs!.remove(_quotesKey);
    await _prefs!.remove(_currentIndexKey);
    await _prefs!.remove(_lastFetchKey);
    await _prefs!.remove(_weekStartKey);
    debugPrint('🗑️ Quotes cleared');
  }
}
