import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/providers/syllabus_provider.dart';
import 'package:css_mastery_app/providers/export_provider.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';

class ShareDialog extends StatelessWidget {
  const ShareDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final syllabusProvider = context.watch<SyllabusProvider>();
    final exportProvider = context.watch<ExportProvider>();

    final progress = syllabusProvider.progress ??
        ProgressModel(
          userId: 'CSS Learner',
          date: DateTime.now(),
          topicsCompleted: 0,
          topicsTotal: syllabusProvider.days.length,
          streak: 0,
          consistency: 0.0,
          createdAt: DateTime.now(),
        );

    final completedCount = progress.topicsCompleted;
    final totalCount = progress.topicsTotal;
    final completionPercentage =
        totalCount > 0 ? (completedCount / totalCount * 100).toStringAsFixed(0) : '0';

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1F22) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.share_outlined,
            color: AppColors.primaryBlue,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Share Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Show off your learning achievements with friends and family!',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Beautiful Card containing Stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2D2E30), const Color(0xFF1A1B1C)]
                    : [AppColors.primaryBlueLight, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'MY CSS MASTER STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Streak', '${progress.streak}d', Icons.local_fire_department, Colors.orange),
                    _buildStatColumn('Progress', '$completedCount/$totalCount', Icons.check_circle_outline, AppColors.success),
                    _buildStatColumn('Consistency', '$completionPercentage%', Icons.speed, Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (exportProvider.isExporting)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await exportProvider.shareProgress(
                    progress: progress,
                    days: syllabusProvider.days,
                    userName: 'CSS Learner',
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Progress shared successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.share, size: 20),
                label: const Text('Share Achievement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }
}
