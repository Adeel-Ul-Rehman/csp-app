import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';

class StatsOverview extends StatelessWidget {
  final ProgressModel? progress;
  final int totalDays;
  final int completedDays;
  final int pendingDays;

  const StatsOverview({
    super.key,
    required this.progress,
    required this.totalDays,
    required this.completedDays,
    required this.pendingDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completionRate = totalDays > 0 ? completedDays / totalDays : 0.0;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Circular Progress
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: completionRate,
                          strokeWidth: 12,
                          backgroundColor:
                              isDark ? AppColors.darkGray : AppColors.lightGray,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(completionRate * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              Text(
                                '$completedDays / $totalDays Days',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.mediumGray
                                      : AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Stats List
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildStatItem(
                        'Days Completed',
                        '$completedDays',
                        AppColors.success,
                      ),
                      const SizedBox(height: 10),
                      _buildStatItem(
                        'In Progress',
                        '$pendingDays',
                        AppColors.warning,
                      ),
                      const SizedBox(height: 10),
                      _buildStatItem(
                        'Streak',
                        '${progress?.streak ?? 0} Days',
                        AppColors.accentRed,
                      ),
                      const SizedBox(height: 10),
                      _buildStatItem(
                        'Consistency',
                        '${((progress?.consistency ?? 0) * 100).toStringAsFixed(0)}%',
                        AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.mediumGray,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
