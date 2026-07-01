import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/providers/syllabus_provider.dart';
import 'package:css_mastery_app/widgets/common/custom_app_bar.dart';
import 'package:css_mastery_app/widgets/common/progress_card.dart';
import 'package:css_mastery_app/widgets/buttons/primary_button.dart';
import 'package:css_mastery_app/widgets/buttons/secondary_button.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';
import 'package:css_mastery_app/core/services/background/notification_service.dart';
import 'package:css_mastery_app/widgets/home/datetime_display.dart';

// Screens
import 'package:css_mastery_app/screens/syllabus/syllabus_screen.dart';
import 'package:css_mastery_app/screens/tutor/tutor_screen.dart';
import 'package:css_mastery_app/screens/progress/progress_screen.dart';
import 'package:css_mastery_app/screens/settings/settings_screen.dart';

class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.label,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<NavigationItem> _navItems = const [
    NavigationItem(icon: Icons.home_outlined, label: 'Home'),
    NavigationItem(icon: Icons.book_outlined, label: 'Syllabus'),
    NavigationItem(icon: Icons.chat_outlined, label: 'Tutor'),
    NavigationItem(icon: Icons.trending_up_outlined, label: 'Progress'),
    NavigationItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SyllabusProvider>();
      provider.init('default_user');

      // Check if syllabus exists, if not insert sample data
      provider.checkAndInsertSampleData('default_user');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyllabusProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = provider.todayDay;
    final progress = provider.progress;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'CSS Mastery',
// lib/screens/home/home_screen.dart - Add test notification button

// In the app bar actions:
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () async {
              // Show test notification
              await NotificationService.showDailyReminder();

              // Schedule daily reminder at 8 AM
              await NotificationService.scheduleDailyReminder(
                const TimeOfDay(hour: 8, minute: 0),
              );

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Notification scheduled!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading your learning journey...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            )
          : IndexedStack(
              index: _selectedIndex,
              children: [
                HomeContent(
                  today: today,
                  progress: progress,
                  days: provider.days,
                ),
                const SyllabusScreen(),
                const TutorScreen(),
                const ProgressScreen(),
                const SettingsScreen(),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF3C3D3F) : AppColors.lightGray,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.mediumGray,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: _navItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============ HOME CONTENT ============
class HomeContent extends StatelessWidget {
  final DayModel? today;
  final ProgressModel? progress;
  final List<DayModel> days;

  const HomeContent({
    super.key,
    this.today,
    this.progress,
    this.days = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<SyllabusProvider>();
    final completedCount =
        days.where((d) => d.status == DayStatus.completed).length;
    final totalDays = days.length;

    // Get today's topics
    final todayTopics = today?.topics ?? [];
    final completedTopics = today?.completedTopics ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? AppColors.mediumGray : AppColors.darkGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Start Your Learning Journey',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Day ${today?.dayNumber ?? 1} of $totalDays',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Date & Time Display
          const DateTimeDisplay(),

          const SizedBox(height: 24),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Day Progress',
                  '${today?.dayNumber ?? 0} / $totalDays',
                  Icons.calendar_today_outlined,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Streak',
                  '${progress?.streak ?? 0} Days',
                  Icons.local_fire_department_outlined,
                  AppColors.accentRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Completed',
                  '$completedCount / $totalDays',
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Consistency',
                  '${((progress?.consistency ?? 0) * 100).toStringAsFixed(0)}%',
                  Icons.trending_up_outlined,
                  AppColors.primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Today's Mission Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.task_alt,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Today's Mission",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: today?.status == DayStatus.completed
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.accentRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          today?.status == DayStatus.completed
                              ? 'Completed ✓'
                              : '${todayTopics.length} Topics',
                          style: TextStyle(
                            fontSize: 12,
                            color: today?.status == DayStatus.completed
                                ? AppColors.success
                                : AppColors.accentRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Show today's topics
                  if (todayTopics.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No topics for today. Enjoy your day off! 🎉',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ),
                    )
                  else
                    ...todayTopics.asMap().entries.map((entry) {
                      final index = entry.key;
                      final topic = entry.value;
                      final isCompleted = completedTopics.contains(topic);
                      return _buildTopicItem(
                        context,
                        topic.title,
                        isCompleted,
                        () {
                          if (!isCompleted) {
                            provider.markTopicComplete(today!.id!, index);
                          }
                        },
                      );
                    }),

                  const SizedBox(height: 20),

                  if (todayTopics.isNotEmpty &&
                      today?.status != DayStatus.completed)
                    PrimaryButton(
                      text: 'Mark All Complete',
                      onPressed: () {
                        // Mark all topics as complete
                        for (var i = 0; i < todayTopics.length; i++) {
                          if (!completedTopics.contains(todayTopics[i])) {
                            provider.markTopicComplete(today!.id!, i);
                          }
                        }
                      },
                      icon: Icons.check,
                    ),

                  if (today?.status == DayStatus.completed)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.celebration, color: AppColors.success),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🎉 Amazing! You completed today\'s mission!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Action Buttons for Today
                  if (today != null && today?.status != DayStatus.completed)
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            text: 'Reschedule',
                            onPressed: () =>
                                _showRescheduleDialog(context, today!),
                            isDanger: false,
                            isFullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SecondaryButton(
                            text: 'Mark Off Day',
                            onPressed: () => _showOffDayDialog(context, today!),
                            isDanger: true,
                            isFullWidth: true,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Progress Section
          ProgressCard(
            label: 'Overall Progress',
            value: totalDays > 0 ? completedCount / totalDays : 0,
            subtitle: '$completedCount of $totalDays days completed',
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  context,
                  'Study Timer',
                  Icons.timer_outlined,
                  AppColors.primaryBlue,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Timer feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  context,
                  'Practice Quiz',
                  Icons.quiz_outlined,
                  AppColors.accentRed,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quiz feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Motivational Quote
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Motivation',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '"Success is the sum of small efforts repeated day in and day out."',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '— Robert Collier',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Study Plan Card
          SecondaryButton(
            text: 'View Full Study Plan',
            onPressed: () {
              // Navigate to syllabus screen
              final scaffold = Scaffold.of(context);
              if (scaffold.mounted) {
                // This will trigger bottom nav to switch to syllabus tab
                // We need to access parent state
                final homeState =
                    context.findAncestorStateOfType<_HomeScreenState>();
                if (homeState != null) {
                  homeState.setSelectedIndex(1); // Syllabus tab index
                }
              }
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.mediumGray : AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(
    BuildContext context,
    String topic,
    bool isCompleted,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success
                    : isDark
                        ? AppColors.darkGray
                        : AppColors.lightGray,
                borderRadius: BorderRadius.circular(4),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                topic,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted
                      ? (isDark ? AppColors.mediumGray : AppColors.darkGray)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, DayModel day) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Move today\'s topics to another day. Enter the new day number:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Day Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final dayNumber = int.tryParse(controller.text);
              if (dayNumber != null && dayNumber > 0) {
                final newDate = DateTime.now().add(Duration(days: dayNumber));
                context
                    .read<SyllabusProvider>()
                    .rescheduleDay(day.id!, newDate);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Day rescheduled to day $dayNumber'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid day number'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }

  void _showOffDayDialog(BuildContext context, DayModel day) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Off Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Mark today as an off day. Topics will be moved to the next available day.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g., Sick, Vacation, Holiday',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason =
                  controller.text.isEmpty ? 'Off Day' : controller.text;
              context.read<SyllabusProvider>().markOffDay(day.id!, reason);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Day marked as off day. Topics rescheduled.'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
            ),
            child: const Text('Mark Off Day'),
          ),
        ],
      ),
    );
  }
}
