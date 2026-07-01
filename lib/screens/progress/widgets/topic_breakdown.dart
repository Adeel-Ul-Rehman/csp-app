// lib/screens/progress/widgets/topic_breakdown.dart
import 'package:flutter/material.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class TopicBreakdown extends StatelessWidget {
  final List<DayModel> days;

  const TopicBreakdown({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Count total topics and completed
    int totalTopics = 0;
    int completedTopics = 0;
    
    for (var day in days) {
      totalTopics += day.topics.length;
      completedTopics += day.completedTopics.length;
    }

    final completionRate = totalTopics > 0 ? completedTopics / totalTopics : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Topic Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Topic Stats
            Row(
              children: [
                Expanded(
                  child: _buildTopicStat(
                    'Total Topics',
                    '$totalTopics',
                    Icons.list_alt,
                    AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTopicStat(
                    'Completed',
                    '$completedTopics',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completion Rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.mediumGray : AppColors.darkGray,
                      ),
                    ),
                    Text(
                      '${(completionRate * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: completionRate,
                  backgroundColor: isDark ? AppColors.darkGray : AppColors.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  minHeight: 6,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}