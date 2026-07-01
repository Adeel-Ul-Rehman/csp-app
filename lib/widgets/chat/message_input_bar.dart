// lib/widgets/chat/message_input_bar.dart

import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/services/voice_service.dart';
import 'package:css_mastery_app/widgets/chat/voice_recorder_button.dart';

class MessageInputBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final Function(String) onVoiceTextReceived;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.onStop,
    required this.onVoiceTextReceived,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  late VoiceService _voiceService;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isListening = _voiceService.isListening;
    final hasText = widget.controller.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2E30) : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Voice Recorder Button (NEW)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: VoiceRecorderButton(
              voiceService: _voiceService,
              onTextRecognized: () {
                final text = _voiceService.recognizedText;
                if (text.isNotEmpty) {
                  widget.onVoiceTextReceived(text);
                  _voiceService.reset();
                }
              },
            ),
          ),

          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.nearBlack : AppColors.lightGray,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.controller,
                onSubmitted: (_) => widget.onSend(),
                decoration: InputDecoration(
                  hintText: isListening
                      ? '🎤 Listening...'
                      : widget.isLoading
                          ? 'Processing...'
                          : 'Ask a question...',
                  hintStyle: TextStyle(
                    color: isListening
                        ? AppColors.accentRed
                        : isDark
                            ? AppColors.mediumGray
                            : AppColors.darkGray,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: isListening
                      ? const Icon(
                          Icons.surround_sound,
                          color: AppColors.accentRed,
                        )
                      : null,
                  suffixIcon: hasText && !widget.isLoading
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.mediumGray,
                          ),
                          onPressed: () {
                            widget.controller.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send/Stop button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.isLoading
                  ? AppColors.accentRed
                  : hasText
                      ? AppColors.primaryBlue
                      : AppColors.mediumGray,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                widget.isLoading ? Icons.stop : Icons.send,
                color: Colors.white,
                size: 20,
              ),
              onPressed: widget.isLoading
                  ? widget.onStop
                  : hasText
                      ? widget.onSend
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
