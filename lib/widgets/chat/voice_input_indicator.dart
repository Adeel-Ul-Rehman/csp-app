// lib/widgets/chat/voice_input_indicator.dart

import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class VoiceInputIndicator extends StatelessWidget {
  final double soundLevel;

  const VoiceInputIndicator({super.key, required this.soundLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mic, color: AppColors.accentRed),
          const SizedBox(width: 8),
          const Text(
            'Listening...',
            style: TextStyle(
              color: AppColors.accentRed,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          _buildSoundBars(),
        ],
      ),
    );
  }

  Widget _buildSoundBars() {
    return Row(
      children: List.generate(8, (index) {
        final height = 10 + (soundLevel * 20 * (index + 1) / 8);
        return Container(
          width: 3,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: AppColors.accentRed.withValues(alpha: 0.5 + (soundLevel * 0.5)),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
