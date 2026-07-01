// lib/widgets/chat/voice_recorder_button.dart

import 'package:flutter/material.dart';
import 'package:css_mastery_app/services/voice_service.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class VoiceRecorderButton extends StatefulWidget {
  final VoiceService voiceService;
  final VoidCallback onTextRecognized;

  const VoiceRecorderButton({
    super.key,
    required this.voiceService,
    required this.onTextRecognized,
  });

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Listen to voice service changes
    widget.voiceService.addListener(_onVoiceStateChanged);
  }

  void _onVoiceStateChanged() {
    setState(() {});
    if (widget.voiceService.isListening) {
      // Start pulse animation when listening
      _pulseController.forward();
    } else {
      // Reset pulse when not listening
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    widget.voiceService.removeListener(_onVoiceStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isListening = widget.voiceService.isListening;
    final isAvailable = widget.voiceService.isAvailable;
    final recognizedText = widget.voiceService.recognizedText;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse Animation (when listening)
        if (isListening)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentRed.withValues(alpha: 0.2),
                  ),
                ),
              );
            },
          ),

        // Main Button
        GestureDetector(
          onLongPress: () async {
            if (!isAvailable) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Speech recognition not available'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            if (!isListening) {
              // Start recording with haptic feedback
              if (Theme.of(context).platform == TargetPlatform.iOS) {
                // iOS haptic feedback
              }
              await widget.voiceService.startListening(
                onResult: () {
                  // Update recognized text in real-time
                  setState(() {});
                },
                onError: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🎤 Error: ${widget.voiceService.error}',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
              );
            }
          },
          onLongPressUp: () async {
            if (isListening) {
              // Stop recording with haptic feedback
              if (Theme.of(context).platform == TargetPlatform.iOS) {
                // iOS haptic feedback
              }
              await widget.voiceService.stopListening();
              if (!context.mounted) return;

              // If we have recognized text, send it
              if (recognizedText.isNotEmpty) {
                widget.onTextRecognized();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎤 "$recognizedText"'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No speech detected. Try again.'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            }
          },
          onTap: () {
            // Cancel if listening
            if (isListening) {
              widget.voiceService.cancelListening();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recording cancelled'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isListening
                  ? AppColors.accentRed
                  : isAvailable
                      ? AppColors.primaryBlue.withValues(alpha: 0.8)
                      : AppColors.mediumGray,
              shape: BoxShape.circle,
              boxShadow: isListening
                  ? [
                      BoxShadow(
                        color: AppColors.accentRed.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              isListening
                  ? Icons.mic
                  : isAvailable
                      ? Icons.mic_none
                      : Icons.mic_off,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
