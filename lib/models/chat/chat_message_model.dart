// lib/models/chat/chat_message_model.dart

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? topic;
  final bool hasCode;
  final String? codeContent;
  final String? codeLanguage;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.topic,
    this.hasCode = false,
    this.codeContent,
    this.codeLanguage,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      text: map['message'] as String,
      isUser: map['is_user'] == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
      topic: map['topic'] as String?,
      hasCode: map['has_code'] == 1,
      codeContent: map['code_content'] as String?,
      codeLanguage: map['code_language'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': text,
      'is_user': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'topic': topic,
      'has_code': hasCode ? 1 : 0,
      'code_content': codeContent,
      'code_language': codeLanguage,
    };
  }

  // Helper to check if message contains code block
  bool get containsCodeBlock {
    if (!hasCode && codeContent != null) return true;
    return text.contains('```') || text.contains('```') || hasCode;
  }

  // Extract code from message
  static ChatMessage extractCode(String text) {
    final codeRegex = RegExp(r'```(\w+)?\n([\s\S]*?)```');
    final match = codeRegex.firstMatch(text);

    if (match != null) {
      final language = match.group(1) ?? 'text';
      final code = match.group(2) ?? '';
      final cleanText = text.replaceAll(match.group(0)!, '').trim();

      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: cleanText.isNotEmpty ? cleanText : 'Here\'s the code:',
        isUser: false,
        timestamp: DateTime.now(),
        hasCode: true,
        codeContent: code,
        codeLanguage: language,
      );
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      hasCode: false,
    );
  }
}
