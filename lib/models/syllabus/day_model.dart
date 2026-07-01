// lib/models/syllabus/day_model.dart
import 'topic_model.dart';

enum DayStatus {
  pending,
  inProgress,
  completed,
  offDay,
  rescheduled,
  merged,
  buffered,
}

class DayModel {
  final int? id;
  final String userId;
  final int dayNumber;
  final DateTime date;
  final List<TopicModel> topics;
  final DayStatus status;
  final List<TopicModel> completedTopics;
  final int hoursSpent;
  final String? reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  DayModel({
    this.id,
    required this.userId,
    required this.dayNumber,
    required this.date,
    required this.topics,
    this.status = DayStatus.pending,
    this.completedTopics = const [],
    this.hoursSpent = 0,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DayModel.fromMap(Map<String, dynamic> map) {
    return DayModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      dayNumber: map['day_number'] as int,
      date: DateTime.parse(map['date'] as String),
      topics: (map['topics'] as String).split(',').map((t) => TopicModel(
        title: t.trim(),
        dayId: map['id'] as int,
      )).toList(),
      status: DayStatus.values.firstWhere(
        (e) => e.toString() == 'DayStatus.${map['status']}',
        orElse: () => DayStatus.pending,
      ),
      hoursSpent: map['hours_spent'] as int,
      reason: map['reason'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'day_number': dayNumber,
      'date': date.toIso8601String(),
      'topics': topics.map((t) => t.title).join(','),
      'status': status.toString().split('.').last,
      'completed_topics': completedTopics.map((t) => t.title).join(','),
      'hours_spent': hoursSpent,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DayModel copyWith({
    int? id,
    String? userId,
    int? dayNumber,
    DateTime? date,
    List<TopicModel>? topics,
    DayStatus? status,
    List<TopicModel>? completedTopics,
    int? hoursSpent,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DayModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      topics: topics ?? this.topics,
      status: status ?? this.status,
      completedTopics: completedTopics ?? this.completedTopics,
      hoursSpent: hoursSpent ?? this.hoursSpent,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progress {
    if (topics.isEmpty) return 0.0;
    return completedTopics.length / topics.length;
  }

  bool get isComplete => progress >= 1.0;
}