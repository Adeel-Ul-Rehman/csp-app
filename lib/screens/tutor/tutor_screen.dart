import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/providers/chat_provider.dart';
import 'package:css_mastery_app/providers/syllabus_provider.dart';
import 'package:css_mastery_app/core/services/ai_service.dart';
import 'package:css_mastery_app/widgets/chat/chat_message_widget.dart';
import 'package:css_mastery_app/widgets/chat/typing_indicator.dart';
import 'package:css_mastery_app/widgets/chat/suggested_prompts.dart';
import 'package:css_mastery_app/widgets/chat/message_input_bar.dart';
import 'package:css_mastery_app/widgets/common/custom_app_bar.dart';
import 'package:css_mastery_app/widgets/chat/session_indicator.dart';
import 'package:css_mastery_app/widgets/export/export_dialog.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final syllabusProvider = context.watch<SyllabusProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayTopic =
        syllabusProvider.todayDay?.topics.firstOrNull?.title ?? 'CSS';
    final allTopics = syllabusProvider.days
        .expand((day) => day.topics.map((t) => t.title))
        .toList();

    // Get suggested prompts
    final prompts = AIService().getSuggestedPrompts(todayTopic);

    return Scaffold(
      backgroundColor: isDark ? AppColors.nearBlack : AppColors.offWhite,
      appBar: CustomAppBar(
        title: 'AI Tutor',
        actions: [
          // Export chat button
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export Chat',
            onPressed: () {
              if (chatProvider.messages.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No messages in current chat to export'),
                    backgroundColor: AppColors.warning,
                  ),
                );
                return;
              }
              showDialog(
                context: context,
                builder: (context) => const ExportDialog(),
              );
            },
          ),
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: () => _clearChat(chatProvider),
          ),
          // Provider status indicator
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Provider Status',
            onPressed: () => _showProviderStatus(chatProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Topic Context
          _buildTopicContext(isDark, todayTopic),

          // Session Indicator
          FutureBuilder<String?>(
            future: chatProvider.getLastSessionInfo(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return SessionIndicator(
                  lastSessionInfo: snapshot.data,
                  messageCount: chatProvider.messages.length,
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Chat Messages
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      return ChatMessageWidget(
                        message: message,
                        isDark: isDark,
                      );
                    },
                  ),
          ),

          // Suggested Prompts (show when few messages)
          if (chatProvider.messages.length < 6)
            SuggestedPrompts(
              prompts: prompts,
              onPromptSelected: (prompt) {
                _sendMessage(
                  context,
                  prompt,
                  todayTopic,
                  allTopics,
                  chatProvider,
                );
              },
            ),

          // Typing Indicator
          if (chatProvider.isTyping) const TypingIndicator(),

          // Input Bar with Voice Support
          MessageInputBar(
            controller: _messageController,
            isLoading: chatProvider.isLoading,
            onSend: () => _sendMessage(
              context,
              _messageController.text,
              todayTopic,
              allTopics,
              chatProvider,
            ),
            onStop: () {
              // Stop processing if needed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Processing stopped'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            onVoiceTextReceived: (text) {
              // Set the text in the input field
              _messageController.text = text;
              // Send the message
              _sendVoiceMessage(
                context,
                text,
                todayTopic,
                allTopics,
                chatProvider,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopicContext(bool isDark, String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? const Color(0xFF2D2E30) : AppColors.lightGray,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.book_outlined,
              size: 16,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Topic',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mediumGray,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Live',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_outlined,
            size: 72,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: 20),
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask anything about CSS or web development',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 14, color: AppColors.success),
              SizedBox(width: 6),
              Text(
                'Powered by multiple AI providers',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              const Text(
                'Try voice input with 🎤 button',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Main send message method
  void _sendMessage(
    BuildContext context,
    String text,
    String topic,
    List<String> allTopics,
    ChatProvider chatProvider,
  ) {
    if (text.trim().isEmpty) return;

    final syllabusContext = AIService().formatSyllabusContext(allTopics);
    final conversationHistory = chatProvider.getRecentConversationHistory();

    // Clear the input field
    _messageController.clear();

    // Send the message
    chatProvider
        .sendMessage(
      message: text,
      topicContext: topic,
      syllabusContext: syllabusContext,
      conversationHistory: conversationHistory,
    )
        .then((_) {
      _scrollToBottom();
    });
  }

  // Voice input method
  void _sendVoiceMessage(
    BuildContext context,
    String text,
    String topic,
    List<String> allTopics,
    ChatProvider chatProvider,
  ) {
    if (text.trim().isEmpty) return;

    final syllabusContext = AIService().formatSyllabusContext(allTopics);
    final conversationHistory = chatProvider.getRecentConversationHistory();

    // Clear the input field
    _messageController.clear();

    // Send the voice message
    chatProvider
        .sendMessageFromVoice(
      message: text,
      topicContext: topic,
      syllabusContext: syllabusContext,
      conversationHistory: conversationHistory,
    )
        .then((_) {
      _scrollToBottom();
    });
  }

  void _clearChat(ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Chat'),
        content: const Text(
          'This will clear all messages in the conversation. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              chatProvider.clearChat();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Chat cleared successfully'),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showProviderStatus(ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) {
        final status = chatProvider.providerStatus;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              const Text('AI Provider Status'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: status.entries.map((entry) {
              final data = entry.value as Map<String, dynamic>;
              final percentage = data['percentage'] ?? 0;
              final remaining = data['remaining'] ?? 0;
              final used = data['used'] ?? 0;
              final limit = data['limit'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: percentage > 80
                      ? AppColors.accentRed.withValues(alpha: 0.1)
                      : percentage > 50
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: percentage > 80
                        ? AppColors.accentRed.withValues(alpha: 0.3)
                        : percentage > 50
                            ? AppColors.warning.withValues(alpha: 0.3)
                            : AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: remaining > 0
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.accentRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            remaining > 0 ? 'Available' : 'Exhausted',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: remaining > 0
                                  ? AppColors.success
                                  : AppColors.accentRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$used / $limit',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Requests Used',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$remaining remaining',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: remaining > 0
                                      ? AppColors.success
                                      : AppColors.accentRed,
                                ),
                              ),
                              const Text(
                                'Daily Limit',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: limit > 0 ? used / limit : 0,
                        minHeight: 4,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : AppColors.lightGray,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage > 80
                              ? AppColors.accentRed
                              : percentage > 50
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}% used',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
