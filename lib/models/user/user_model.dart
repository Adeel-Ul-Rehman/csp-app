// lib/models/user/user_model.dart
class UserModel {
  final String id;
  final String? name;
  final String? email;
  final DateTime startDate;
  final int totalDays;
  final int bufferDays;
  final int dailyGoalHours;
  final String weeklyOff;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.name,
    this.email,
    required this.startDate,
    this.totalDays = 390,
    this.bufferDays = 30,
    this.dailyGoalHours = 4,
    this.weeklyOff = 'Sunday',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String?,
      email: map['email'] as String?,
      startDate: DateTime.parse(map['start_date'] as String),
      totalDays: map['total_days'] as int,
      bufferDays: map['buffer_days'] as int,
      dailyGoalHours: map['daily_goal_hours'] as int,
      weeklyOff: map['weekly_off'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'start_date': startDate.toIso8601String(),
      'total_days': totalDays,
      'buffer_days': bufferDays,
      'daily_goal_hours': dailyGoalHours,
      'weekly_off': weeklyOff,
      'created_at': createdAt.toIso8601String(),
    };
  }
}