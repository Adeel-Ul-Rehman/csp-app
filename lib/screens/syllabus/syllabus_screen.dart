// lib/screens/syllabus/syllabus_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:css_mastery_app/providers/syllabus_provider.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';
import 'package:css_mastery_app/widgets/common/custom_app_bar.dart';
import 'package:css_mastery_app/widgets/buttons/primary_button.dart';
import 'package:css_mastery_app/widgets/buttons/secondary_button.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  String _filter = 'All'; // All, Pending, Completed, OffDay
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyllabusProvider>();
    
    // Filter days based on selected filter
    List<DayModel> filteredDays = provider.days;
    switch (_filter) {
      case 'Pending':
        filteredDays = provider.days.where((d) => 
          d.status == DayStatus.pending || d.status == DayStatus.inProgress
        ).toList();
        break;
      case 'Completed':
        filteredDays = provider.days.where((d) => 
          d.status == DayStatus.completed
        ).toList();
        break;
      case 'Off Day':
        filteredDays = provider.days.where((d) => 
          d.status == DayStatus.offDay
        ).toList();
        break;
      default:
        filteredDays = provider.days;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Study Plan',
        actions: [
          // Filter Dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_outlined),
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Days')),
              const PopupMenuItem(value: 'Pending', child: Text('Pending')),
              const PopupMenuItem(value: 'Completed', child: Text('Completed')),
              const PopupMenuItem(value: 'Off Day', child: Text('Off Days')),
            ],
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.days.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: [
                    // Stats Bar
                    _buildStatsBar(context, provider),
                    // Day List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDays.length,
                        itemBuilder: (context, index) {
                          final day = filteredDays[index];
                          return _buildDayCard(context, day);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
            size: 64,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: 16),
          const Text(
            'No syllabus loaded yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate sample data to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Load Sample Data',
            onPressed: () {
              context.read<SyllabusProvider>().insertSampleData('default_user');
            },
            icon: Icons.download,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, SyllabusProvider provider) {
    final total = provider.days.length;
    final completed = provider.days.where((d) => d.status == DayStatus.completed).length;
    final pending = provider.days.where((d) => 
      d.status == DayStatus.pending || d.status == DayStatus.inProgress
    ).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2E30)
            : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF3C3D3F)
                : AppColors.lightGray,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '$total', AppColors.primaryBlue),
          _buildStatItem('Completed', '$completed', AppColors.success),
          _buildStatItem('Pending', '$pending', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, DayModel day) {
    final isCompleted = day.status == DayStatus.completed;
    final isToday = day.date.day == DateTime.now().day &&
        day.date.month == DateTime.now().month;
    final isOffDay = day.status == DayStatus.offDay;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showDayDetails(context, day);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Day Number
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : isOffDay
                          ? AppColors.accentRed.withValues(alpha: 0.1)
                          : isToday
                              ? AppColors.primaryBlue.withValues(alpha: 0.1)
                              : AppColors.lightGray.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.dayNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? AppColors.success
                          : isOffDay
                              ? AppColors.accentRed
                              : isToday
                                  ? AppColors.primaryBlue
                                  : AppColors.mediumGray,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Day Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${day.dayNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOffDay
                          ? 'Off Day - ${day.reason ?? "No reason"}'
                          : '${day.topics.length} topics • ${(day.progress * 100).toStringAsFixed(0)}% complete',
                      style: TextStyle(
                        fontSize: 13,
                        color: isOffDay ? AppColors.accentRed : AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Badge
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
              if (isOffDay)
                const Icon(
                  Icons.beach_access,
                  color: AppColors.accentRed,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetails(BuildContext context, DayModel day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mediumGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Row(
                  children: [
                    Text(
                      'Day ${day.dayNumber}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: day.status == DayStatus.completed
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        day.status.toString().split('.').last,
                        style: TextStyle(
                          fontSize: 12,
                          color: day.status == DayStatus.completed
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  day.date.toString().split(' ').first,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Topics List
                const Text(
                  'Topics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: day.topics.length,
                    itemBuilder: (context, index) {
                      final topic = day.topics[index];
                      final isCompleted = day.completedTopics.any((t) => t.title == topic.title);
                      return ListTile(
                        leading: Checkbox(
                          value: isCompleted,
                          onChanged: day.status == DayStatus.completed
                              ? null
                              : (value) {
                                  if (value == true) {
                                    context.read<SyllabusProvider>().markTopicComplete(day.id!, index);
                                  }
                                },
                          activeColor: AppColors.primaryBlue,
                        ),
                        title: Text(
                          topic.title,
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? AppColors.mediumGray : null,
                          ),
                        ),
                        trailing: isCompleted
                            ? const Icon(Icons.check, color: AppColors.success)
                            : null,
                      );
                    },
                  ),
                ),
                
                // Action Buttons
                if (day.status != DayStatus.completed && day.status != DayStatus.offDay)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            text: 'Reschedule',
                            onPressed: () {
                              Navigator.pop(context);
                              _showRescheduleDialog(context, day);
                            },
                            isDanger: false,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SecondaryButton(
                            text: 'Off Day',
                            onPressed: () {
                              Navigator.pop(context);
                              _showOffDayDialog(context, day);
                            },
                            isDanger: true,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
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
              'Move this day to another day number:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Day Number',
                border: OutlineInputBorder(),
                hintText: 'e.g., 15',
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
                context.read<SyllabusProvider>().rescheduleDay(day.id!, newDate);
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
              'Mark this day as off. Topics will be moved to next available day.',
              style: TextStyle(fontSize: 14),
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
              final reason = controller.text.isEmpty ? 'Off Day' : controller.text;
              context.read<SyllabusProvider>().markOffDay(day.id!, reason);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Day marked as off day'),
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