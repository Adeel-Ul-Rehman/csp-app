// lib/widgets/common/progress_card.dart
import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class ProgressCard extends StatelessWidget {
  final String label;
  final double value;
  final String? subtitle;

  const ProgressCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.lightGray : AppColors.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.darkGray : AppColors.lightGray,
                color: value >= 0.7 
                    ? AppColors.success 
                    : value >= 0.4 
                        ? AppColors.warning 
                        : AppColors.accentRed,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.mediumGray : AppColors.darkGray,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}