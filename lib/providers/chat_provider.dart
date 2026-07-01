import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/services/ai_service.dart';
import 'package:css_mastery_app/models/chat/chat_message_model.dart';
import 'package:css_mastery_app/services/chat_storage_service.dart';
import 'package:css_mastery_app/services/error_logger.dart';

class ChatProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  final ChatStorageService _storageService = ChatStorageService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;
  Map<String, dynamic> _providerStatus = {};
  bool _isInitialized = false;
  bool _hasLoadedHistory = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get error => _error;
  Map<String, dynamic> get providerStatus => _providerStatus;
  bool get hasLoadedHistory => _hasLoadedHistory;
  bool get hasMessages => _messages.isNotEmpty;

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      await _storageService.init();
      _isInitialized = true;
      await _loadChatHistory();
    } catch (e) {
      print('❌ ChatProvider initialization error: $e');
      _error = e.toString();
      _isInitialized = true;
      _addWelcomeMessage();
      notifyListeners();
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final savedMessages = await _storageService.loadChatHistory();

      if (savedMessages.isNotEmpty) {
        _messages = savedMessages;
        _hasLoadedHistory = true;
        print('📂 Loaded ${savedMessages.length} messages from history');

        // Show session info
        final lastSession = await _storageService.getLastSessionInfo();
        if (lastSession != null) {
          print('📅 Last session: $lastSession');
        }
      } else {
        _hasLoadedHistory = true;
        _addWelcomeMessage();
        print('📂 No saved chat history found');
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error loading chat history: $e');
      _error = e.toString();
      _hasLoadedHistory = true;
      _addWelcomeMessage();
      notifyListeners();
    }
  }

  // Save chat history to storage
  Future<void> _saveChatHistory() async {
    if (!_isInitialized) return;

    try {
      await _storageService.saveChatHistory(_messages);
    } catch (e) {
      print('❌ Error saving chat history: $e');
    }
  }

  void _addWelcomeMessage() {
    final hasHistory = _messages.isNotEmpty;

    if (!hasHistory) {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '''👋 Welcome back to CSS Tutor!

I'm your AI assistant powered by multiple AI providers. I can help you with:

📐 **Layout:** Flexbox, Grid, Positioning
🎯 **Selectors:** Classes, IDs, Attributes
📦 **Box Model:** Content, Padding, Border, Margin
🎨 **Styling:** Colors, Fonts, Animations
📱 **Responsive:** Media Queries, Mobile First

Just ask me anything about CSS and I'll help you learn!

💡 **Tip:** You can also use the 🎤 button to ask questions using your voice!''',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> _loadProviderStatus() async {
    _providerStatus = await _aiService.getProviderStatus();
    notifyListeners();
  }

  Future<void> sendMessage({
    required String message,
    required String topicContext,
    required String syllabusContext,
    List<String>? conversationHistory,
  }) async {
    if (message.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _isLoading = true;
    _isTyping = true;
    notifyListeners();

    // Save immediately after user message
    await _saveChatHistory();

    try {
      final response = await _aiService.getAIResponse(
        userMessage: message,
        topicContext: topicContext,
        syllabusContext: syllabusContext,
        conversationHistory: conversationHistory,
        useCache: true,
      );

      if (response['success']) {
        final responseText = response['response'] as String;
        final source = response['source'] ?? 'AI';
        final provider = response['provider'] ?? '';
        final isFromCache = response['fromCache'] ?? false;

        String sourceBadge = '🧠 $source';
        if (provider.isNotEmpty && !isFromCache) {
          sourceBadge = '🧠 $source ($provider)';
        } else if (isFromCache) {
          sourceBadge = '💾 Cached Response';
        }

        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
          topic: sourceBadge,
        ));
      } else {
        // Log error
        await ErrorLogger.logError(
          source: 'ChatProvider.sendMessage',
          message: 'AI response failed',
          additionalData: {
            'message': message,
            'response': response,
          },
          severity: Severity.warning,
        );

        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response['response'] ??
              'Sorry, I could not process your request. Please try again later.',
          isUser: false,
          timestamp: DateTime.now(),
          topic: '⚠️ Error',
        ));
      }
    } catch (e, stackTrace) {
      // Log critical error
      await ErrorLogger.logError(
        source: 'ChatProvider.sendMessage',
        message: e.toString(),
        stackTrace: stackTrace.toString(),
        additionalData: {
          'message': message,
          'topicContext': topicContext,
        },
        severity: Severity.critical,
      );

      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            '⚠️ Error: ${e.toString().substring(0, e.toString().length > 150 ? 150 : e.toString().length)}...\n\nPlease try again later.',
        isUser: false,
        timestamp: DateTime.now(),
        topic: '⚠️ Error',
      ));
    } finally {
      _isLoading = false;
      _isTyping = false;
      await _loadProviderStatus();
      // Save after AI response
      await _saveChatHistory();
      notifyListeners();
    }
  }

  // Special method for voice input
  Future<void> sendMessageFromVoice({
    required String message,
    required String topicContext,
    required String syllabusContext,
    List<String>? conversationHistory,
  }) async {
    if (message.trim().isEmpty) return;

    // Add user message with voice indicator
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '🎤 $message',
      isUser: true,
      timestamp: DateTime.now(),
      topic: 'Voice Input',
    ));

    _isLoading = true;
    _isTyping = true;
    notifyListeners();

    // Save immediately after voice message
    await _saveChatHistory();

    try {
      final response = await _aiService.getAIResponse(
        userMessage: message,
        topicContext: topicContext,
        syllabusContext: syllabusContext,
        conversationHistory: conversationHistory,
        useCache: true,
      );

      if (response['success']) {
        final responseText = response['response'] as String;
        final source = response['source'] ?? 'AI';
        final provider = response['provider'] ?? '';
        final isFromCache = response['fromCache'] ?? false;

        String sourceBadge = '🧠 $source';
        if (provider.isNotEmpty && !isFromCache) {
          sourceBadge = '🧠 $source ($provider)';
        } else if (isFromCache) {
          sourceBadge = '💾 Cached Response';
        }

        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
          topic: sourceBadge,
        ));
      } else {
        // Log error
        await ErrorLogger.logError(
          source: 'ChatProvider.sendMessageFromVoice',
          message: 'AI response failed',
          additionalData: {
            'message': message,
            'response': response,
          },
          severity: Severity.warning,
        );

        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response['response'] ??
              'Sorry, I could not process your request. Please try again later.',
          isUser: false,
          timestamp: DateTime.now(),
          topic: '⚠️ Error',
        ));
      }
    } catch (e, stackTrace) {
      // Log critical error
      await ErrorLogger.logError(
        source: 'ChatProvider.sendMessageFromVoice',
        message: e.toString(),
        stackTrace: stackTrace.toString(),
        additionalData: {
          'message': message,
          'topicContext': topicContext,
        },
        severity: Severity.critical,
      );

      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            '⚠️ Error: ${e.toString().substring(0, e.toString().length > 150 ? 150 : e.toString().length)}...\n\nPlease try again later.',
        isUser: false,
        timestamp: DateTime.now(),
        topic: '⚠️ Error',
      ));
    } finally {
      _isLoading = false;
      _isTyping = false;
      await _loadProviderStatus();
      // Save after AI response
      await _saveChatHistory();
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _addWelcomeMessage();
    _storageService.clearChatHistory();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<String> getConversationHistory() {
    return _messages
        .where((m) => m.isUser || !m.isUser)
        .map((m) => '${m.isUser ? "Student" : "Tutor"}: ${m.text}')
        .toList();
  }

  // Get last N messages for context
  List<String> getRecentConversationHistory({int count = 6}) {
    final recent = _messages.length > count
        ? _messages.sublist(_messages.length - count)
        : _messages;

    return recent
        .where((m) => m.isUser || !m.isUser)
        .map((m) => '${m.isUser ? "Student" : "Tutor"}: ${m.text}')
        .toList();
  }

  // Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    if (!_isInitialized) return {};
    return await _storageService.getStorageStats();
  }

  // Get last session info
  Future<String?> getLastSessionInfo() async {
    if (!_isInitialized) return null;
    return await _storageService.getLastSessionInfo();
  }

  // Check if chat history exists
  Future<bool> hasChatHistory() async {
    if (!_isInitialized) return false;
    return await _storageService.hasChatHistory();
  }
}
