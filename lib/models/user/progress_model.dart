// lib/models/user/progress_model.dart
class ProgressModel {
  final int? id;
  final String userId;
  final DateTime date;
  final int topicsCompleted;
  final int topicsTotal;
  final int streak;
  final double consistency;
  final DateTime createdAt;

  ProgressModel({
    this.id,
    required this.userId,
    required this.date,
    required this.topicsCompleted,
    required this.topicsTotal,
    required this.streak,
    required this.consistency,
    required this.createdAt,
  });

  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      topicsCompleted: map['topics_completed'] as int,
      topicsTotal: map['topics_total'] as int,
      streak: map['streak'] as int,
      consistency: map['consistency'] as double,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'topics_completed': topicsCompleted,
      'topics_total': topicsTotal,
      'streak': streak,
      'consistency': consistency,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get completionRate {
    if (topicsTotal == 0) return 0.0;
    return topicsCompleted / topicsTotal;
  }
}