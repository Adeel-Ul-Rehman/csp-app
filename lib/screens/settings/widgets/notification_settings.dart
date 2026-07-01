// lib/screens/settings/widgets/notification_settings.dart
import 'package:flutter/material.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _allNotifications = true;
  bool _dailyReminder = true;
  bool _progressUpdates = true;
  bool _motivationQuotes = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              'All Notifications',
              'Enable or disable all notifications',
              _allNotifications,
              (value) {
                setState(() {
                  _allNotifications = value;
                  _dailyReminder = value;
                  _progressUpdates = value;
                  _motivationQuotes = value;
                });
              },
            ),
            const Divider(),
            _buildNotificationItem(
              'Daily Reminder',
              'Get reminded to study every day',
              _dailyReminder,
              (value) {
                setState(() {
                  _dailyReminder = value;
                });
              },
              enabled: _allNotifications,
            ),
            _buildNotificationItem(
              'Progress Updates',
              'Weekly progress reports',
              _progressUpdates,
              (value) {
                setState(() {
                  _progressUpdates = value;
                });
              },
              enabled: _allNotifications,
            ),
            _buildNotificationItem(
              'Motivation Quotes',
              'Daily motivational quotes',
              _motivationQuotes,
              (value) {
                setState(() {
                  _motivationQuotes = value;
                });
              },
              enabled: _allNotifications,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: enabled ? null : AppColors.mediumGray,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.mediumGray,
        ),
      ),
      trailing: Switch(
        value: value && enabled,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: AppColors.primaryBlue,
      ),
    );
  }
}