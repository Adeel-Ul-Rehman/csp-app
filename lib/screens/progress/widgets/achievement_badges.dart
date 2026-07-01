import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';

class AchievementBadges extends StatelessWidget {
  final ProgressModel? progress;
  final int completedDays;
  final int totalDays;

  const AchievementBadges({
    super.key,
    required this.progress,
    required this.completedDays,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final achievements = _getAchievements();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: achievements.map((achievement) {
                final isUnlocked = achievement['unlocked'] as bool;
                return Container(
                  width: 80,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? (achievement['color'] as Color?)?.withValues(alpha: 0.1)
                        : isDark
                            ? AppColors.darkGray.withValues(alpha: 0.1)
                            : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUnlocked
                          ? achievement['color'] ?? AppColors.primaryBlue
                          : AppColors.mediumGray.withValues(alpha: 0.3),
                      width: isUnlocked ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        achievement['icon'] as IconData,
                        color: isUnlocked
                            ? achievement['color'] ?? AppColors.primaryBlue
                            : AppColors.mediumGray,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isUnlocked ? FontWeight.w600 : FontWeight.normal,
                          color: isUnlocked
                              ? achievement['color'] ?? AppColors.primaryBlue
                              : AppColors.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isUnlocked)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 12,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievements() {
    final streak = progress?.streak ?? 0;
    final consistency = (progress?.consistency ?? 0) * 100;
    final completionRate =
        totalDays > 0 ? (completedDays / totalDays) * 100 : 0;

    return [
      {
        'label': 'First Day',
        'icon': Icons.emoji_events,
        'color': Colors.grey,
        'unlocked': completedDays >= 1,
      },
      {
        'label': 'Week Streak',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'unlocked': streak >= 7,
      },
      {
        'label': 'Month Streak',
        'icon': Icons.whatshot,
        'color': Colors.red,
        'unlocked': streak >= 30,
      },
      {
        'label': 'Consistent',
        'icon': Icons.trending_up,
        'color': Colors.blue,
        'unlocked': consistency >= 70,
      },
      {
        'label': 'Halfway',
        'icon': Icons.flag,
        'color': Colors.purple,
        'unlocked': completionRate >= 50,
      },
      {
        'label': 'Almost There',
        'icon': Icons.rocket,
        'color': Colors.teal,
        'unlocked': completionRate >= 75,
      },
      {
        'label': 'Master',
        'icon': Icons.star,
        'color': Colors.amber,
        'unlocked': completionRate >= 90,
      },
      {
        'label': 'Complete',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFFFD700),
        'unlocked': completionRate >= 100,
      },
    ];
  }
}
