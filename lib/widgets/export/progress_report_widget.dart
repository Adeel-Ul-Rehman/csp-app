import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/providers/export_provider.dart';
import 'package:css_mastery_app/providers/syllabus_provider.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';

class ProgressReportWidget extends StatelessWidget {
  const ProgressReportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exportProvider = context.watch<ExportProvider>();
    final syllabusProvider = context.watch<SyllabusProvider>();

    final progress = syllabusProvider.progress;
    final days = syllabusProvider.days;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Generate Progress Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Export a detailed report of your learning progress',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.mediumGray : AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Stats summary
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2D2E30)
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${days.length} Days',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Total Journey',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2D2E30)
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${days.where((d) => d.status == DayStatus.completed).length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2D2E30)
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${progress?.streak ?? 0}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentRed,
                          ),
                        ),
                        const Text(
                          'Streak',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: exportProvider.isExporting
                    ? null
                    : () {
                        if (days.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No data to generate report'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                          return;
                        }
                        _generateReport(context, exportProvider);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: exportProvider.isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, size: 18),
                          SizedBox(width: 8),
                          Text('Generate & Share Report'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateReport(BuildContext context, ExportProvider exportProvider) {
    final syllabusProvider = context.read<SyllabusProvider>();

    exportProvider.generateProgressReport(
      progress: syllabusProvider.progress ??
          ProgressModel(
            userId: 'CSS Learner',
            date: DateTime.now(),
            topicsCompleted: 0,
            topicsTotal: syllabusProvider.days.length,
            streak: 0,
            consistency: 0.0,
            createdAt: DateTime.now(),
          ),
      days: syllabusProvider.days,
      userName: 'CSS Learner',
      onSuccess: (path) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📄 Progress report generated!'),
            duration: Duration(seconds: 3),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }
}
