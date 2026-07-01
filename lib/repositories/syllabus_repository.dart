// lib/repositories/syllabus_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:css_mastery_app/core/services/database/database_service.dart';
import 'package:css_mastery_app/models/syllabus/day_model.dart';
import 'package:css_mastery_app/models/syllabus/topic_model.dart';
import 'package:css_mastery_app/models/user/progress_model.dart';

class SyllabusRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<Database> get _db async => await _dbService.database;

  // Get all days
  Future<List<DayModel>> getAllDays(String userId) async {
    final db = await _db;
    final result = await db.query(
      'syllabus',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'day_number ASC',
    );
    return result.map((map) => DayModel.fromMap(map)).toList();
  }

  // Get day by number
  Future<DayModel?> getDayByNumber(String userId, int dayNumber) async {
    final db = await _db;
    final result = await db.query(
      'syllabus',
      where: 'user_id = ? AND day_number = ?',
      whereArgs: [userId, dayNumber],
    );
    if (result.isEmpty) return null;
    return DayModel.fromMap(result.first);
  }

  // Get today's day
  Future<DayModel?> getTodayDay(String userId) async {
    final today = DateTime.now();
    final startDate = await getStartDate(userId);
    if (startDate == null) return null;
    
    final days = today.difference(startDate).inDays;
    return getDayByNumber(userId, days + 1);
  }

  // Get start date
  Future<DateTime?> getStartDate(String userId) async {
    final db = await _db;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isEmpty) return null;
    return DateTime.parse(result.first['start_date'] as String);
  }

  // Update day status
  Future<void> updateDayStatus(DayModel day) async {
    final db = await _db;
    await db.update(
      'syllabus',
      day.toMap(),
      where: 'id = ?',
      whereArgs: [day.id],
    );
  }

  // Mark topic as complete
  Future<void> markTopicComplete(int dayId, int topicIndex) async {
    final day = await getDayById(dayId);
    if (day == null) return;

    final updatedTopics = List<TopicModel>.from(day.topics);
    final completedTopics = List<TopicModel>.from(day.completedTopics);
    
    if (topicIndex < updatedTopics.length) {
      completedTopics.add(updatedTopics[topicIndex]);
    }

    final updatedDay = day.copyWith(
      completedTopics: completedTopics,
      status: completedTopics.length == day.topics.length 
          ? DayStatus.completed 
          : DayStatus.inProgress,
      updatedAt: DateTime.now(),
    );

    await updateDayStatus(updatedDay);
    await updateProgress(day.userId);
  }

  // Get day by ID
  Future<DayModel?> getDayById(int id) async {
    final db = await _db;
    final result = await db.query(
      'syllabus',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return DayModel.fromMap(result.first);
  }

  // Update progress
  Future<void> updateProgress(String userId) async {
    final days = await getAllDays(userId);
    final completed = days.where((d) => d.status == DayStatus.completed).length;
    final total = days.length;
    
    // Calculate streak
    int streak = 0;
    for (var i = days.length - 1; i >= 0; i--) {
      if (days[i].status == DayStatus.completed) {
        streak++;
      } else if (days[i].status == DayStatus.offDay) {
        continue;
      } else {
        break;
      }
    }

    final progress = ProgressModel(
      userId: userId,
      date: DateTime.now(),
      topicsCompleted: completed,
      topicsTotal: total,
      streak: streak,
      consistency: total > 0 ? completed / total : 0,
      createdAt: DateTime.now(),
    );

    final db = await _db;
    await db.insert('progress', progress.toMap());
  }

  // Get progress
  Future<ProgressModel?> getLatestProgress(String userId) async {
    final db = await _db;
    final result = await db.query(
      'progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ProgressModel.fromMap(result.first);
  }

  // Reschedule day
  Future<void> rescheduleDay(int dayId, DateTime newDate) async {
    final day = await getDayById(dayId);
    if (day == null) return;

    final updatedDay = day.copyWith(
      date: newDate,
      status: DayStatus.rescheduled,
      updatedAt: DateTime.now(),
    );

    await updateDayStatus(updatedDay);
  }

  // Mark off day
  Future<void> markOffDay(int dayId, String reason) async {
    final day = await getDayById(dayId);
    if (day == null) return;

    final updatedDay = day.copyWith(
      status: DayStatus.offDay,
      reason: reason,
      updatedAt: DateTime.now(),
    );

    await updateDayStatus(updatedDay);
  }

  // Insert sample syllabus for testing
  Future<void> insertSampleSyllabus(String userId) async {
    final db = await _db;
    final now = DateTime.now();
    final startDate = now;

    // Generate 30 days of syllabus
    for (var i = 0; i < 30; i++) {
      final dayDate = startDate.add(Duration(days: i));
      
      // Skip Sundays (weekly off)
      if (dayDate.weekday == DateTime.sunday) {
        continue;
      }

      final topics = [
        'HTML Basics - Day ${i + 1}',
        'CSS Fundamentals - Day ${i + 1}',
        'Practice Exercises - Day ${i + 1}',
      ];

      await db.insert('syllabus', {
        'user_id': userId,
        'day_number': i + 1,
        'date': dayDate.toIso8601String(),
        'topics': topics.join(','),
        'status': DayStatus.pending.toString().split('.').last,
        'completed_topics': '',
        'hours_spent': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
    }
  }
}