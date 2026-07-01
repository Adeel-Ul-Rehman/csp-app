import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:css_mastery_app/core/constants/app_strings.dart';
import 'package:css_mastery_app/utils/cache_manager.dart';
import 'package:css_mastery_app/utils/rate_limit_manager.dart';
import 'package:css_mastery_app/models/chat/chat_provider_model.dart';

void print(Object? object) {
  debugPrint(object?.toString());
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final CacheManager _cacheManager = CacheManager();
  final RateLimitManager _rateLimitManager = RateLimitManager();
  
  final Map<String, bool> _providerStatus = {};
  final Map<String, int> _providerFailCount = {};
  final Map<String, DateTime> _providerLastFail = {};

  Future<Map<String, dynamic>> getAIResponse({
    required String userMessage,
    required String topicContext,
    required String syllabusContext,
    List<String>? conversationHistory,
    bool useCache = true,
  }) async {
    try {
      await _cacheManager.init();
      await _rateLimitManager.init();

      if (useCache) {
        final cachedResponse = _cacheManager.getCachedResponse(userMessage);
        if (cachedResponse != null) {
          print('✅ [Cache] Hit for: ${userMessage.substring(0, min(50, userMessage.length))}...');
          return {
            'success': true,
            'response': cachedResponse,
            'source': '💾 Cache',
            'provider': 'Cache',
            'fromCache': true,
          };
        }
      }

      final systemPrompt = _buildSystemPrompt(
        topicContext: topicContext,
        syllabusContext: syllabusContext,
      );
      
      final userPrompt = _buildUserPrompt(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
      );

      print('📤 [AI] Topic: $topicContext');
      print('📤 [AI] Question: ${userMessage.substring(0, min(50, userMessage.length))}...');

      final response = await _tryProviders(
        systemPrompt: systemPrompt,
        userPrompt: userPrompt,
        userMessage: userMessage,
      );

      if (response['success'] && !(response['fromCache'] ?? false)) {
        await _cacheManager.saveResponse(userMessage, response['response']);
      }

      return response;

    } catch (e) {
      print('❌ [AI] Fatal Error: $e');
      return {
        'success': false,
        'response': '⚠️ I\'m having trouble connecting. Please try again later.',
        'source': 'Error',
        'provider': 'Error',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> _tryProviders({
    required String systemPrompt,
    required String userPrompt,
    required String userMessage,
  }) async {
    final providers = AIProviderModel.getAllProviders()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    Map<String, dynamic>? lastError;

    for (var provider in providers) {
      final canUse = await _rateLimitManager.canUseProvider(
        provider.name,
        provider.dailyLimit,
      );

      if (!canUse) {
        print('⚠️ [${provider.name}] Daily limit reached');
        continue;
      }

      if (_providerStatus.containsKey(provider.name) && 
          _providerStatus[provider.name] == false) {
        final lastFail = _providerLastFail[provider.name];
        if (lastFail != null) {
          final cooldown = DateTime.now().difference(lastFail);
          if (cooldown.inMinutes < 5) {
            print('⚠️ [${provider.name}] In cooldown period');
            continue;
          } else {
            _providerStatus[provider.name] = true;
          }
        }
      }

      try {
        print('📡 [${provider.name}] Trying...');
        
        final response = await _callProvider(
          provider: provider,
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
        );

        if (response['success']) {
          await _rateLimitManager.recordUsage(provider.name);
          _providerFailCount[provider.name] = 0;
          _providerStatus[provider.name] = true;
          print('✅ [${provider.name}] Success!');
          return response;
        } else {
          _providerFailCount[provider.name] = (_providerFailCount[provider.name] ?? 0) + 1;
          _providerLastFail[provider.name] = DateTime.now();
          if ((_providerFailCount[provider.name] ?? 0) >= 3) {
            _providerStatus[provider.name] = false;
            print('⚠️ [${provider.name}] Marked as unhealthy');
          }
          lastError = response;
        }
      } catch (e) {
        print('❌ [${provider.name}] Error: $e');
        _providerFailCount[provider.name] = (_providerFailCount[provider.name] ?? 0) + 1;
        _providerLastFail[provider.name] = DateTime.now();
        lastError = {'success': false, 'error': e.toString()};
      }
    }

    print('⚠️ [AI] All providers failed');
    return {
      'success': false,
      'response': '⚠️ All AI services are currently unavailable. Please try again later.',
      'source': 'Error',
      'provider': 'None',
      'error': lastError?['error'] ?? 'All providers failed',
    };
  }

  Future<Map<String, dynamic>> _callProvider({
    required AIProviderModel provider,
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final fullPrompt = '$systemPrompt\n\n$userPrompt';

    switch (provider.name) {
      case 'DevToolBox':
        return await _callDevToolBox(fullPrompt);
      case 'python-tgpt':
        return await _callPythonTgpt(fullPrompt);
      case 'HuggingFace':
        return await _callHuggingFace(fullPrompt);
      default:
        return {'success': false, 'error': 'Unknown provider'};
    }
  }

  Future<Map<String, dynamic>> _callDevToolBox(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(AppStrings.devToolBoxUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 5));

      print('📡 [DevToolBox] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['response'] ?? data['text'] ?? data['result'] ?? '';

        if (result.isNotEmpty && result.length > 10) {
          return {
            'success': true,
            'response': result,
            'source': '🌐 AI Assistant',
            'provider': 'DevToolBox',
            'fromCache': false,
          };
        }
      }
      return {'success': false, 'error': 'Empty or invalid response'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _callPythonTgpt(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(AppStrings.pythonTgptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 8));

      print('📡 [python-tgpt] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['response'] ?? data['text'] ?? data['message'] ?? '';

        if (result.isNotEmpty && result.length > 10) {
          return {
            'success': true,
            'response': result,
            'source': '🌐 AI Assistant',
            'provider': 'python-tgpt',
            'fromCache': false,
          };
        }
      }
      return {'success': false, 'error': 'Empty or invalid response'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _callHuggingFace(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(AppStrings.huggingFaceUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 800,
            'temperature': 0.7,
            'do_sample': true,
          },
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 [HuggingFace] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String result = '';

        if (data is List && data.isNotEmpty) {
          result = data[0]['generated_text'] ?? '';
        } else if (data is Map) {
          result = data['generated_text'] ?? '';
        }

        if (result.startsWith(prompt)) {
          result = result.substring(prompt.length).trim();
        }

        if (result.isNotEmpty && result.length > 10) {
          return {
            'success': true,
            'response': result,
            'source': '🌐 AI Assistant',
            'provider': 'HuggingFace',
            'fromCache': false,
          };
        }
      }
      return {'success': false, 'error': 'Empty or invalid response'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  String _buildSystemPrompt({
    required String topicContext,
    required String syllabusContext,
  }) {
    return '''
You are a CSS/Web Development Tutor. Your purpose is to help students learn CSS.

SYLLABUS CONTEXT (Your Knowledge Base):
$syllabusContext

CURRENT TOPIC (What the student is learning today):
$topicContext

YOUR RULES (Strictly Follow):
1. ONLY answer questions related to the syllabus context above
2. If the question is NOT in the syllabus, politely say: "I'm here to help with CSS topics from your syllabus. Would you like to ask about $topicContext?"
3. Explain concepts in simple language (mix of Urdu and English)
4. Provide practical examples with code when relevant
5. If you provide code, format it using triple backticks with language
6. Keep responses helpful and concise
7. Use a friendly, encouraging tone

YOUR ROLE:
You are a knowledgeable, patient tutor who helps students understand CSS concepts step by step.

IMPORTANT: Always format code with proper language tags:
```css
.code { }
```
Now respond to the student's question:
''';
  }

  String _buildUserPrompt({
    required String userMessage,
    List<String>? conversationHistory,
  }) {
    String result = '';

    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      result += 'Previous conversation:\n';
      for (var msg in conversationHistory) {
        result += '$msg\n';
      }
      result += '\n';
    }

    result += "Student's current question: $userMessage\n\n";
    result += 'Please respond as a helpful tutor with clear explanations.';

    return result;
  }

  List<String> getSuggestedPrompts(String topic) {
    final Map<String, List<String>> topicPrompts = {
      'Flexbox': [
        'Explain Flexbox with practical examples',
        'How to center a div using Flexbox?',
        'What is the difference between justify-content and align-items?',
        'How to make a responsive navigation bar with Flexbox?',
        'What are flex-grow and flex-shrink?',
      ],
      'Grid': [
        'Explain CSS Grid with examples',
        'What is the difference between Grid and Flexbox?',
        'How to create a 3-column layout with Grid?',
        'What is grid-template-areas and how to use it?',
        'How to make a responsive grid layout?',
      ],
      'Selectors': [
        'Explain CSS Selectors with examples',
        'What is the difference between class and ID selectors?',
        'How to use pseudo-classes like :hover and :nth-child?',
        'What are attribute selectors and how to use them?',
        'Explain CSS specificity with examples',
      ],
      'Box Model': [
        'Explain the CSS Box Model',
        'What is the difference between padding and margin?',
        'What does box-sizing: border-box do?',
        'How to center a div using the Box Model?',
        'Explain margin collapsing with examples',
      ],
      'Positioning': [
        'Explain CSS Positioning with examples',
        'What is the difference between absolute and relative position?',
        'How to use position: sticky?',
        'What is z-index and how does it work?',
        'How to overlay elements using positioning?',
      ],
      'CSS': [
        'Explain what CSS is and why it\'s important',
        'What is the cascade in CSS?',
        'Explain CSS specificity with examples',
        'What are CSS variables and how to use them?',
        'Explain CSS media queries with examples',
      ],
    };

    for (var key in topicPrompts.keys) {
      if (topic.toLowerCase().contains(key.toLowerCase()) ||
          key.toLowerCase().contains(topic.toLowerCase())) {
        return topicPrompts[key]!;
      }
    }

    return [
      'Explain this topic with examples',
      'What are the key concepts of this topic?',
      'Show me practical code examples',
      'What are common mistakes to avoid?',
      'Give me a practice exercise for this topic',
    ];
  }

  Future<Map<String, dynamic>> getProviderStatus() async {
    await _rateLimitManager.init();
    return await _rateLimitManager.getUsageSummary();
  }

  String formatSyllabusContext(List<String> topics) {
    if (topics.isEmpty) return 'No syllabus loaded yet.';

    String result = 'The student is learning the following CSS topics:\n';
    for (var topic in topics) {
      result += '- $topic\n';
    }
    result += '\nPlease only answer questions related to these topics.';
    return result;
  }

  String getTopicFromSyllabus(String dayTopics) {
    final topics = dayTopics.split(',').map((t) => t.trim()).toList();
    if (topics.isEmpty) return 'CSS';
    return topics.first;
  }

  Future<void> clearCache() async {
    await _cacheManager.init();
    await _cacheManager.clearCache();
  }

  Future<void> resetRateLimits() async {
    await _rateLimitManager.resetAllUsage();
  }

  int min(int a, int b) => a < b ? a : b;
}
