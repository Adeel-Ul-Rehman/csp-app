import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class SessionIndicator extends StatelessWidget {
  final String? lastSessionInfo;
  final int messageCount;

  const SessionIndicator({
    super.key,
    this.lastSessionInfo,
    required this.messageCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2E30) : AppColors.lightGray,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF3C3D3F) : AppColors.lightGray,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history,
              size: 14,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            messageCount > 0
                ? '$messageCount messages saved'
                : 'No saved messages',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.mediumGray : AppColors.darkGray,
            ),
          ),
          if (lastSessionInfo != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.mediumGray,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Last: $lastSessionInfo',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.mediumGray : AppColors.darkGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
