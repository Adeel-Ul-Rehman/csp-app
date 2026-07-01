import 'package:flutter/material.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/models/syllabus/topic_model.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';

// Syllabus Provider
class SyllabusProvider extends ChangeNotifier {
  List<DayModel> _days = [];
  DayModel? _todayDay;
  ProgressModel? _progress;
  bool _isLoading = false;
  String? _error;

  List<DayModel> get days => _days;
  DayModel? get todayDay => _todayDay;
  ProgressModel? get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with user ID
  Future<void> init(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadData(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all data
  Future<void> loadData(String userId) async {
    // Check if we already have data
    if (_days.isEmpty) {
      // Generate sample data
      _generateSampleData(userId);
    }

    // Find today's day
    final today = DateTime.now();
    _todayDay = _days.firstWhere(
      (d) => d.date.day == today.day && d.date.month == today.month,
      orElse: () => _days.first,
    );

    // Calculate progress
    final completed =
        _days.where((d) => d.status == DayStatus.completed).length;
    _progress = ProgressModel(
      userId: userId,
      date: DateTime.now(),
      topicsCompleted: completed,
      topicsTotal: _days.length,
      streak: completed > 0 ? 5 : 0,
      consistency: _days.isNotEmpty ? completed.toDouble() / _days.length : 0.0,
      createdAt: DateTime.now(),
    );

    notifyListeners();
  }

  void _generateSampleData(String userId) {
    final now = DateTime.now();
    _days = [];

    final topics = [
      'HTML Introduction',
      'CSS Selectors',
      'Box Model',
      'Flexbox',
      'CSS Grid',
      'Positioning',
      'Responsive Design',
      'CSS Animations',
      'CSS Variables',
      'CSS Frameworks',
    ];

    for (var i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));

      // Skip Sundays
      if (date.weekday == DateTime.sunday) {
        continue;
      }

      final dayTopics =
          topics.take(3).map((t) => TopicModel(title: t, dayId: i + 1)).toList();

      // Rotate topics
      topics.shuffle();

      _days.add(DayModel(
        id: i + 1,
        userId: userId,
        dayNumber: i + 1,
        date: date,
        topics: dayTopics,
        status: i < 5 ? DayStatus.completed : DayStatus.pending,
        completedTopics: i < 5 ? dayTopics : [],
        createdAt: now,
        updatedAt: now,
      ));
    }
  }

  // Mark topic as complete
  Future<void> markTopicComplete(int dayId, int topicIndex) async {
    final dayIndex = _days.indexWhere((d) => d.id == dayId);
    if (dayIndex == -1) return;

    final day = _days[dayIndex];
    final topic = day.topics[topicIndex];

    // Check if already completed
    if (day.completedTopics.contains(topic)) return;

    final updatedCompleted = List<TopicModel>.from(day.completedTopics)
      ..add(topic);

    final updatedDay = day.copyWith(
      completedTopics: updatedCompleted,
      status: updatedCompleted.length == day.topics.length
          ? DayStatus.completed
          : DayStatus.inProgress,
      updatedAt: DateTime.now(),
    );

    _days[dayIndex] = updatedDay;

    // Update today if it's the same
    if (_todayDay?.id == dayId) {
      _todayDay = updatedDay;
    }

    // Update progress
    final completed =
        _days.where((d) => d.status == DayStatus.completed).length;
    _progress = ProgressModel(
      userId: day.userId,
      date: DateTime.now(),
      topicsCompleted: completed,
      topicsTotal: _days.length,
      streak: completed > 0 ? 5 : 0,
      consistency: _days.isNotEmpty ? completed.toDouble() / _days.length : 0.0,
      createdAt: DateTime.now(),
    );

    notifyListeners();
  }

  // Check and insert sample data
  Future<void> checkAndInsertSampleData(String userId) async {
    if (_days.isEmpty) {
      _generateSampleData(userId);
      await loadData(userId);
    }
  }

  // Insert sample data
  Future<void> insertSampleData(String userId) async {
    _generateSampleData(userId);
    await loadData(userId);
  }

  // Reschedule day
  Future<void> rescheduleDay(int dayId, DateTime newDate) async {
    final dayIndex = _days.indexWhere((d) => d.id == dayId);
    if (dayIndex == -1) return;

    final day = _days[dayIndex];
    _days[dayIndex] = day.copyWith(
      date: newDate,
      status: DayStatus.rescheduled,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // Mark off day
  Future<void> markOffDay(int dayId, String reason) async {
    final dayIndex = _days.indexWhere((d) => d.id == dayId);
    if (dayIndex == -1) return;

    final day = _days[dayIndex];
    _days[dayIndex] = day.copyWith(
      status: DayStatus.offDay,
      reason: reason,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
}
