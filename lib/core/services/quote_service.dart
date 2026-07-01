import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:css_mastery_app/models/quote_model.dart';
import 'package:css_mastery_app/services/error_logger.dart';

class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  factory QuoteService() => _instance;
  QuoteService._internal();

  static const int _quotesPerWeek = 14; // 7 days × 2 quotes

  // ============================================================
  // 1. PRIMARY API: ZenQuotes.io (Free, No API Key)
  // ============================================================
  static const String _zenQuotesUrl = 'https://zenquotes.io/api/quotes';

  // ============================================================
  // 2. FALLBACK API: TypeFit (Free, No API Key)
  // ============================================================
  static const String _typeFitUrl = 'https://type.fit/api/quotes';

  // ============================================================
  // 3. SECONDARY FALLBACK: Programming Quotes
  // ============================================================
  static const String _programmingQuotesUrl =
      'https://programming-quotes-api.herokuapp.com/quotes?count=14';

  // ============================================================
  // 4. MAIN METHOD: FETCH WEEKLY QUOTES
  // ============================================================
  Future<List<QuoteModel>> fetchWeeklyQuotes() async {
    try {
      debugPrint('📡 Fetching weekly quotes...');

      // Try primary API
      final quotes = await _fetchFromZenQuotes();
      if (quotes.isNotEmpty) {
        debugPrint('✅ Fetched ${quotes.length} quotes from ZenQuotes');
        return quotes;
      }

      // Try fallback API
      final fallbackQuotes = await _fetchFromTypeFit();
      if (fallbackQuotes.isNotEmpty) {
        debugPrint('✅ Fetched ${fallbackQuotes.length} quotes from TypeFit');
        return fallbackQuotes;
      }

      // Try secondary fallback
      final secondaryQuotes = await _fetchFromProgrammingQuotes();
      if (secondaryQuotes.isNotEmpty) {
        debugPrint(
            '✅ Fetched ${secondaryQuotes.length} quotes from Programming Quotes');
        return secondaryQuotes;
      }

      // If all APIs fail, return default quotes
      debugPrint('⚠️ All APIs failed, using default quotes');
      return _getDefaultQuotes();
    } catch (e) {
      debugPrint('❌ Error fetching quotes: $e');
      await ErrorLogger.logError(
        source: 'QuoteService.fetchWeeklyQuotes',
        message: e.toString(),
        severity: Severity.warning,
      );
      return _getDefaultQuotes();
    }
  }

  // ============================================================
  // 5. ZEN QUOTES API
  // ============================================================
  Future<List<QuoteModel>> _fetchFromZenQuotes() async {
    try {
      final response = await http
          .get(
            Uri.parse(_zenQuotesUrl),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isEmpty) return [];

        // Take only what we need
        final limitedData = data.length > _quotesPerWeek
            ? data.sublist(0, _quotesPerWeek)
            : data;

        return limitedData.map((json) {
          return QuoteModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                limitedData.indexOf(json).toString(),
            text: json['q']?.toString() ?? '',
            author: json['a']?.toString() ?? 'Unknown',
            category: 'Motivational',
            fetchedDate: DateTime.now(),
            isMorningQuote: false,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ ZenQuotes error: $e');
      return [];
    }
  }

  // ============================================================
  // 6. TYPE FIT API
  // ============================================================
  Future<List<QuoteModel>> _fetchFromTypeFit() async {
    try {
      final response = await http
          .get(
            Uri.parse(_typeFitUrl),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isEmpty) return [];

        final limitedData = data.length > _quotesPerWeek
            ? data.sublist(0, _quotesPerWeek)
            : data;

        return limitedData.map((json) {
          return QuoteModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                limitedData.indexOf(json).toString(),
            text: json['text']?.toString() ?? '',
            author: json['author']?.toString() ?? 'Unknown',
            category: 'Inspirational',
            fetchedDate: DateTime.now(),
            isMorningQuote: false,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ TypeFit error: $e');
      return [];
    }
  }

  // ============================================================
  // 7. PROGRAMMING QUOTES API
  // ============================================================
  Future<List<QuoteModel>> _fetchFromProgrammingQuotes() async {
    try {
      final response = await http
          .get(
            Uri.parse(_programmingQuotesUrl),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isEmpty) return [];

        final limitedData = data.length > _quotesPerWeek
            ? data.sublist(0, _quotesPerWeek)
            : data;

        return limitedData.map((json) {
          return QuoteModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                limitedData.indexOf(json).toString(),
            text: json['text']?.toString() ?? '',
            author: json['author']?.toString() ?? 'Unknown',
            category: 'Coding',
            fetchedDate: DateTime.now(),
            isMorningQuote: false,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Programming Quotes error: $e');
      return [];
    }
  }

  // ============================================================
  // 8. DEFAULT QUOTES (When Offline)
  // ============================================================
  List<QuoteModel> _getDefaultQuotes() {
    const defaultQuotes = [
      {
        'text':
            'Success is the sum of small efforts repeated day in and day out.',
        'author': 'Robert Collier'
      },
      {
        'text': 'The expert in anything was once a beginner.',
        'author': 'Helen Hayes'
      },
      {
        'text': 'Consistency beats talent when talent doesn\'t work hard.',
        'author': 'Tim Notke'
      },
      {
        'text': 'Your future is created by what you do today, not tomorrow.',
        'author': 'Robert Kiyosaki'
      },
      {
        'text': 'The only way to do great work is to love what you do.',
        'author': 'Steve Jobs'
      },
      {
        'text': 'Believe you can and you\'re halfway there.',
        'author': 'Theodore Roosevelt'
      },
      {
        'text':
            'It does not matter how slowly you go as long as you do not stop.',
        'author': 'Confucius'
      },
      {
        'text':
            'The best time to start was yesterday. The next best time is now.',
        'author': 'Unknown'
      },
      {
        'text': 'Learning never exhausts the mind.',
        'author': 'Leonardo da Vinci'
      },
      {
        'text':
            'The beautiful thing about learning is nobody can take it away from you.',
        'author': 'B.B. King'
      },
      {
        'text':
            'Education is the most powerful weapon you can use to change the world.',
        'author': 'Nelson Mandela'
      },
      {
        'text':
            'The mind is not a vessel to be filled, but a fire to be kindled.',
        'author': 'Plutarch'
      },
      {
        'text': 'The more that you read, the more things you will know.',
        'author': 'Dr. Seuss'
      },
      {
        'text':
            'Live as if you were to die tomorrow. Learn as if you were to live forever.',
        'author': 'Mahatma Gandhi'
      },
    ];

    return defaultQuotes.map((json) {
      return QuoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            defaultQuotes.indexOf(json).toString(),
        text: json['text']!,
        author: json['author']!,
        category: 'Motivational',
        fetchedDate: DateTime.now(),
        isMorningQuote: false,
      );
    }).toList();
  }

  // ============================================================
  // 9. GET SINGLE QUOTE FOR IMMEDIATE USE
  // ============================================================
  Future<QuoteModel?> getSingleQuote() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://zenquotes.io/api/random'),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return QuoteModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: data[0]['q']?.toString() ?? '',
            author: data[0]['a']?.toString() ?? 'Unknown',
            category: 'Motivational',
            fetchedDate: DateTime.now(),
            isMorningQuote: false,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
