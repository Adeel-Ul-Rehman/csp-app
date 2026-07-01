import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/providers/chat_provider.dart';
import 'package:css_mastery_app/providers/export_provider.dart';

class ExportDialog extends StatelessWidget {
  const ExportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exportProvider = context.watch<ExportProvider>();

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1F22) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.download_outlined,
            color: AppColors.primaryBlue,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Export Chat History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a format to save or share your conversation with CSS Tutor:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (exportProvider.isExporting)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Generating file...',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _buildFormatOption(
                context,
                title: 'Markdown (.md)',
                subtitle: 'Best for reading with syntax highlighting.',
                icon: Icons.text_snippet_outlined,
                color: Colors.orange,
                onTap: () => _handleExport(context, 'markdown'),
              ),
              const SizedBox(height: 10),
              _buildFormatOption(
                context,
                title: 'Plain Text (.txt)',
                subtitle: 'Simple format readable on any device.',
                icon: Icons.description_outlined,
                color: AppColors.primaryBlue,
                onTap: () => _handleExport(context, 'txt'),
              ),
              const SizedBox(height: 10),
              _buildFormatOption(
                context,
                title: 'JSON (.json)',
                subtitle: 'Best for importing into other systems or backups.',
                icon: Icons.code,
                color: Colors.purple,
                onTap: () => _handleExport(context, 'json'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: exportProvider.isExporting ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? const Color(0xFF2B2D31) : AppColors.lightGray.withValues(alpha: 0.4),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, String format) async {
    final chatProvider = context.read<ChatProvider>();
    final exportProvider = context.read<ExportProvider>();

    if (!chatProvider.hasMessages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No messages to export'),
          backgroundColor: AppColors.warning,
        ),
      );
      Navigator.pop(context);
      return;
    }

    final path = await exportProvider.exportChatHistory(
      messages: chatProvider.messages,
      format: format,
    );

    if (path != null) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📄 Chat history shared successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: ${exportProvider.error ?? "Unknown error"}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
