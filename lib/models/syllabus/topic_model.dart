// lib/models/syllabus/topic_model.dart
class TopicModel {
  final int? id;
  final int dayId;
  final String title;
  final String? description;
  final bool isCompleted;
  final String? notes;

  TopicModel({
    this.id,
    required this.dayId,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.notes,
  });

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] as int?,
      dayId: map['day_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day_id': dayId,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'notes': notes,
    };
  }

  TopicModel copyWith({
    int? id,
    int? dayId,
    String? title,
    String? description,
    bool? isCompleted,
    String? notes,
  }) {
    return TopicModel(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicModel &&
        other.title == title &&
        other.dayId == dayId;
  }

  @override
  int get hashCode => Object.hash(title, dayId);
}