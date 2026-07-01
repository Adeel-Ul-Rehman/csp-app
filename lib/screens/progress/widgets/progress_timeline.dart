import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';

class ProgressTimeline extends StatelessWidget {
  final List<DayModel> days;

  const ProgressTimeline({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentDays = days.length > 14 ? days.sublist(days.length - 14) : days;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentDays.length,
                itemBuilder: (context, index) {
                  final day = recentDays[index];
                  final isCompleted = day.status == DayStatus.completed;
                  final isToday = day.date.day == DateTime.now().day &&
                      day.date.month == DateTime.now().month;
                  final isOffDay = day.status == DayStatus.offDay;

                  return Container(
                    width: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 28,
                          height: isCompleted ? 40 : 20,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.success
                                : isOffDay
                                    ? AppColors.accentRed
                                    : isToday
                                        ? AppColors.primaryBlue
                                        : isDark
                                            ? AppColors.darkGray
                                            : AppColors.lightGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${day.dayNumber}',
                          style: TextStyle(
                            fontSize: 9,
                            color: isToday ? AppColors.primaryBlue : AppColors.mediumGray,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
