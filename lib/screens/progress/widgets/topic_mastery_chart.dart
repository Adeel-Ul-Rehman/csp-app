import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';

class TopicMasteryChart extends StatelessWidget {
  final List<DayModel> days;

  const TopicMasteryChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topicStats = _getTopicStats(days);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Topic Mastery',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...topicStats.entries.map((entry) {
              final total = entry.value['total'] ?? 0;
              final completed = entry.value['completed'] ?? 0;
              final percentage = total > 0 ? completed / total : 0.0;
              final color = _getColorForTopic(entry.key);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$completed/$total (${(percentage * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.mediumGray
                                : AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 6,
                        backgroundColor:
                            isDark ? AppColors.darkGray : AppColors.lightGray,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, int>> _getTopicStats(List<DayModel> days) {
    final stats = <String, Map<String, int>>{};

    for (var day in days) {
      for (var topic in day.topics) {
        if (!stats.containsKey(topic.title)) {
          stats[topic.title] = {
            'total': 0,
            'completed': 0,
          };
        }
        stats[topic.title]!['total'] = (stats[topic.title]!['total'] ?? 0) + 1;
        if (day.completedTopics.any((t) => t.title == topic.title)) {
          stats[topic.title]!['completed'] =
              (stats[topic.title]!['completed'] ?? 0) + 1;
        }
      }
    }

    return stats;
  }

  Color _getColorForTopic(String topic) {
    final colors = [
      AppColors.primaryBlue,
      AppColors.success,
      AppColors.accentRed,
      AppColors.warning,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.orange,
      Colors.cyan,
    ];

    final index = topic.hashCode.abs() % colors.length;
    return colors[index];
  }
}
