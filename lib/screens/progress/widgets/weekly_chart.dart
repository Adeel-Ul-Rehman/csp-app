// lib/screens/progress/widgets/weekly_chart.dart
import 'package:flutter/material.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class WeeklyChart extends StatelessWidget {
  final List<DayModel> days;
  final bool expanded;

  const WeeklyChart({
    super.key,
    required this.days,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get last 7 days
    final weekDays = List<DateTime>.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: expanded ? 180 : 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekDays.map((date) {
                  final day = days.firstWhere(
                    (d) => d.date.day == date.day && d.date.month == date.month,
                    orElse: () => DayModel(
                      id: 0,
                      userId: '',
                      dayNumber: 0,
                      date: date,
                      topics: [],
                      status: DayStatus.pending,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
                  final isCompleted = day.status == DayStatus.completed;
                  final isToday = date.day == DateTime.now().day;

                  return _buildDayBar(
                    date,
                    isCompleted,
                    isToday,
                    isDark,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Completed', AppColors.success),
                const SizedBox(width: 16),
                _buildLegendItem('Pending', AppColors.lightGray),
                const SizedBox(width: 16),
                _buildLegendItem('Today', AppColors.primaryBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBar(
      DateTime date, bool isCompleted, bool isToday, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: isCompleted ? (expanded ? 100 : 60) : 20,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : isToday
                    ? AppColors.primaryBlue
                    : isDark
                        ? AppColors.darkGray
                        : AppColors.lightGray,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          date.day.toString(),
          style: TextStyle(
            fontSize: 10,
            color: isToday ? AppColors.primaryBlue : AppColors.mediumGray,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          _getWeekday(date),
          style: const TextStyle(
            fontSize: 8,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return weekdays[date.weekday - 1];
  }
}
