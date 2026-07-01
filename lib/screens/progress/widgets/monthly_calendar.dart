import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';

class MonthlyCalendar extends StatelessWidget {
  final List<DayModel> days;

  const MonthlyCalendar({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = firstDay.weekday;

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
                  '${_getMonthName(now.month)} ${now.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Weekday headers
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.mediumGray : AppColors.darkGray,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: firstWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday) {
                  return const SizedBox.shrink();
                }
                final dayNumber = index - firstWeekday + 1;
                final date = DateTime(now.year, now.month, dayNumber);
                final day = days.firstWhere(
                  (d) => d.date.day == dayNumber && d.date.month == now.month,
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
                final isToday = dayNumber == now.day;
                final isCompleted = day.status == DayStatus.completed;
                final isOffDay = day.status == DayStatus.offDay;

                return Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primaryBlue.withValues(alpha: 0.2)
                        : isCompleted
                            ? AppColors.success.withValues(alpha: 0.2)
                            : isOffDay
                                ? AppColors.accentRed.withValues(alpha: 0.1)
                                : null,
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(color: AppColors.primaryBlue, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted
                            ? AppColors.success
                            : isOffDay
                                ? AppColors.accentRed
                                : isToday
                                    ? AppColors.primaryBlue
                                    : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}
