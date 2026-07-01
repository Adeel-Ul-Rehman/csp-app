import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/providers/syllabus_provider.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/widgets/common/custom_app_bar.dart';
import 'package:css_mastery_app/screens/progress/widgets/stats_overview.dart';
import 'package:css_mastery_app/screens/progress/widgets/weekly_chart.dart';
import 'package:css_mastery_app/screens/progress/widgets/monthly_calendar.dart';
import 'package:css_mastery_app/screens/progress/widgets/topic_mastery_chart.dart';
import 'package:css_mastery_app/screens/progress/widgets/achievement_badges.dart';
import 'package:css_mastery_app/screens/progress/widgets/progress_timeline.dart';
import 'package:share_plus/share_plus.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedView = 'Overview';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyllabusProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = provider.days;
    final progress = provider.progress;

    final totalDays = days.length;
    final completedDays =
        days.where((d) => d.status == DayStatus.completed).length;
    final pendingDays = days
        .where((d) =>
            d.status == DayStatus.pending || d.status == DayStatus.inProgress)
        .length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.nearBlack : AppColors.offWhite,
      appBar: CustomAppBar(
        title: 'Progress',
        actions: [
          // View toggle
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_list_outlined),
            onSelected: (value) {
              setState(() {
                _selectedView = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Overview', child: Text('Overview')),
              const PopupMenuItem(value: 'Weekly', child: Text('Weekly View')),
              const PopupMenuItem(
                  value: 'Monthly', child: Text('Monthly View')),
              const PopupMenuItem(value: 'Topics', child: Text('Topics View')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareProgress(context, provider),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats Overview
                  StatsOverview(
                    progress: progress,
                    totalDays: totalDays,
                    completedDays: completedDays,
                    pendingDays: pendingDays,
                  ),
                  const SizedBox(height: 16),

                  // View based on selection
                  if (_selectedView == 'Overview') ...[
                    // Weekly Chart
                    if (days.isNotEmpty) WeeklyChart(days: days),
                    const SizedBox(height: 16),

                    // Progress Timeline
                    if (days.isNotEmpty) ProgressTimeline(days: days),
                    const SizedBox(height: 16),

                    // Topic Mastery
                    if (days.isNotEmpty) TopicMasteryChart(days: days),
                    const SizedBox(height: 16),

                    // Achievements
                    AchievementBadges(
                      progress: progress,
                      completedDays: completedDays,
                      totalDays: totalDays,
                    ),
                  ],

                  if (_selectedView == 'Weekly') ...[
                    WeeklyChart(days: days, expanded: true),
                    const SizedBox(height: 16),
                    _buildWeeklyStats(days),
                  ],

                  if (_selectedView == 'Monthly') ...[
                    MonthlyCalendar(days: days),
                    const SizedBox(height: 16),
                    _buildMonthlyStats(days),
                  ],

                  if (_selectedView == 'Topics') ...[
                    TopicMasteryChart(days: days),
                    const SizedBox(height: 16),
                    _buildTopicStats(days),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeklyStats(List<DayModel> days) {
    final last7Days = days.length >= 7 ? days.sublist(days.length - 7) : days;
    final completed =
        last7Days.where((d) => d.status == DayStatus.completed).length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildWeekStat(
                    'Completed',
                    '$completed/7',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildWeekStat(
                    'Rate',
                    '${((completed / 7) * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
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
                  fontSize: 11,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(List<DayModel> days) {
    final thisMonth =
        days.where((d) => d.date.month == DateTime.now().month).toList();
    final completed =
        thisMonth.where((d) => d.status == DayStatus.completed).length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMonthStat(
                    'Days Studied',
                    '${thisMonth.length}',
                    Icons.calendar_today,
                    AppColors.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _buildMonthStat(
                    'Completed',
                    '$completed',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildMonthStat(
                    'Rate',
                    '${thisMonth.isNotEmpty ? (completed / thisMonth.length * 100).toStringAsFixed(0) : 0}%',
                    Icons.trending_up,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
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
    );
  }

  Widget _buildTopicStats(List<DayModel> days) {
    final topicStats = <String, int>{};
    for (var day in days) {
      for (var topic in day.topics) {
        topicStats[topic.title] = (topicStats[topic.title] ?? 0) + 1;
      }
    }

    final sortedTopics = topicStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Topics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...sortedTopics.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      '${entry.value}x',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
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

  void _shareProgress(BuildContext context, SyllabusProvider provider) {
    final days = provider.days;
    final completed = days.where((d) => d.status == DayStatus.completed).length;
    final total = days.length;
    final rate = total > 0 ? (completed / total * 100).toStringAsFixed(0) : 0;

    final message = '''
📊 CSS Mastery - My Progress

📈 Completion: $rate%
✅ Days Done: $completed/$total
🔥 Streak: ${provider.progress?.streak ?? 0} Days
💪 Consistency: ${((provider.progress?.consistency ?? 0) * 100).toStringAsFixed(0)}%

Keep learning! 💪
''';

    Share.share(message);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📤 Progress shared!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
