import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:css_mastery_app/models/chat/chat_message_model.dart';

class ChatStorageService {
  static const String _chatHistoryKey = 'chat_history';
  static const String _chatTimestampKey = 'chat_timestamp';
  static const String _chatIdCounterKey = 'chat_id_counter';

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  ChatStorageService();

  // Initialize the service
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    debugPrint('💾 Chat Storage Service initialized');
  }

  // Save chat history
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    if (!_isInitialized || _prefs == null) return;

    try {
      final jsonList = messages
          .map((msg) => {
                'id': msg.id,
                'text': msg.text,
                'isUser': msg.isUser,
                'timestamp': msg.timestamp.toIso8601String(),
                'topic': msg.topic,
                'hasCode': msg.hasCode,
                'codeContent': msg.codeContent,
                'codeLanguage': msg.codeLanguage,
              })
          .toList();

      await _prefs!.setString(_chatHistoryKey, jsonEncode(jsonList));
      await _prefs!
          .setString(_chatTimestampKey, DateTime.now().toIso8601String());

      debugPrint('💾 Chat history saved: ${jsonList.length} messages');
    } catch (e) {
      debugPrint('❌ Error saving chat history: $e');
    }
  }

  // Load chat history
  Future<List<ChatMessage>> loadChatHistory() async {
    if (!_isInitialized || _prefs == null) return [];

    try {
      final jsonString = _prefs!.getString(_chatHistoryKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;

      final messages = jsonList.map((json) {
        return ChatMessage(
          id: json['id'] as String,
          text: json['text'] as String,
          isUser: json['isUser'] as bool,
          timestamp: DateTime.parse(json['timestamp'] as String),
          topic: json['topic'] as String?,
          hasCode: json['hasCode'] as bool? ?? false,
          codeContent: json['codeContent'] as String?,
          codeLanguage: json['codeLanguage'] as String?,
        );
      }).toList();

      debugPrint('📂 Loaded ${messages.length} messages from history');
      return messages;
    } catch (e) {
      debugPrint('❌ Error loading chat history: $e');
      return [];
    }
  }

  // Get last session timestamp
  Future<DateTime?> getLastSessionTimestamp() async {
    if (!_isInitialized || _prefs == null) return null;

    final timestamp = _prefs!.getString(_chatTimestampKey);
    if (timestamp == null) return null;

    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  // Get last session info as string
  Future<String?> getLastSessionInfo() async {
    final timestamp = await getLastSessionTimestamp();
    if (timestamp == null) return null;

    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if chat history exists
  Future<bool> hasChatHistory() async {
    if (!_isInitialized || _prefs == null) return false;
    return _prefs!.containsKey(_chatHistoryKey);
  }

  // Get chat history count
  Future<int> getChatHistoryCount() async {
    final messages = await loadChatHistory();
    return messages.length;
  }

  // Clear chat history
  Future<void> clearChatHistory() async {
    if (!_isInitialized || _prefs == null) return;

    await _prefs!.remove(_chatHistoryKey);
    await _prefs!.remove(_chatTimestampKey);
    await _prefs!.remove(_chatIdCounterKey);
    debugPrint('🗑️ Chat history cleared');
  }

  // Get storage size in KB
  Future<double> getStorageSize() async {
    if (!_isInitialized || _prefs == null) return 0.0;

    try {
      final history = _prefs!.getString(_chatHistoryKey);
      if (history == null) return 0.0;
      return history.length / 1024; // Convert to KB
    } catch (e) {
      return 0.0;
    }
  }

  // Get statistics about stored chat
  Future<Map<String, dynamic>> getStorageStats() async {
    final messages = await loadChatHistory();
    final userMessages = messages.where((m) => m.isUser).length;
    final aiMessages = messages.length - userMessages;
    final size = await getStorageSize();
    final timestamp = await getLastSessionTimestamp();

    return {
      'totalMessages': messages.length,
      'userMessages': userMessages,
      'aiMessages': aiMessages,
      'storageSizeKB': size.toStringAsFixed(2),
      'lastSession': timestamp?.toIso8601String(),
      'hasHistory': messages.isNotEmpty,
    };
  }
}
