import 'package:equatable/equatable.dart';

/// Daily Log Model
class DailyLogModel extends Equatable {
  final String id;
  final String habitId;
  final String userId;
  final DateTime logDate;
  final bool completed;
  final String? learningNote;
  final String? habitTitle;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool synced;

  const DailyLogModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.logDate,
    this.completed = false,
    this.learningNote,
    this.habitTitle,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    this.synced = false,
  });

  /// Create from JSON
  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String? ?? '',
      logDate: DateTime.parse(json['log_date'] as String),
      completed: json['completed'] as bool? ?? false,
      learningNote: json['learning_note'] as String?,
      habitTitle: json['habit_title'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      synced: true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'log_date': _formatDate(logDate),
      'completed': completed,
      'learning_note': learningNote,
      'habit_title': habitTitle,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from database map
  factory DailyLogModel.fromMap(Map<String, dynamic> map) {
    return DailyLogModel(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      userId: map['user_id'] as String,
      logDate: DateTime.parse(map['log_date'] as String),
      completed: (map['completed'] as int?) == 1,
      learningNote: map['learning_note'] as String?,
      habitTitle: map['habit_title'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      synced: (map['synced'] as int?) == 1,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'log_date': _formatDate(logDate),
      'completed': completed ? 1 : 0,
      'learning_note': learningNote,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  /// Format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Copy with
  DailyLogModel copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? logDate,
    bool? completed,
    String? learningNote,
    String? habitTitle,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return DailyLogModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      completed: completed ?? this.completed,
      learningNote: learningNote ?? this.learningNote,
      habitTitle: habitTitle ?? this.habitTitle,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        habitId,
        userId,
        logDate,
        completed,
        learningNote,
        habitTitle,
        completedAt,
        createdAt,
        updatedAt,
        synced,
      ];
}

/// Today Habit Status Model
class TodayHabitStatus extends Equatable {
  final String habitId;
  final String habitTitle;
  final String category;
  final bool isLearning;
  final bool completed;
  final String? learningNote;
  final int currentStreak;

  const TodayHabitStatus({
    required this.habitId,
    required this.habitTitle,
    required this.category,
    this.isLearning = false,
    this.completed = false,
    this.learningNote,
    this.currentStreak = 0,
  });

  factory TodayHabitStatus.fromJson(Map<String, dynamic> json) {
    return TodayHabitStatus(
      habitId: json['habit_id'] as String,
      habitTitle: json['habit_title'] as String,
      category: json['category'] as String? ?? 'personal',
      isLearning: json['is_learning'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      learningNote: json['learning_note'] as String?,
      currentStreak: json['current_streak'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        habitId,
        habitTitle,
        category,
        isLearning,
        completed,
        learningNote,
        currentStreak,
      ];
}

/// Calendar Day Data Model
class CalendarDayData extends Equatable {
  final DateTime date;
  final int totalHabits;
  final int completedCount;
  final int percentage;

  const CalendarDayData({
    required this.date,
    required this.totalHabits,
    required this.completedCount,
    required this.percentage,
  });

  factory CalendarDayData.fromJson(Map<String, dynamic> json) {
    return CalendarDayData(
      date: DateTime.parse(json['date'] as String),
      totalHabits: json['total_habits'] as int? ?? 0,
      completedCount: json['completed_count'] as int? ?? 0,
      percentage: json['percentage'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [date, totalHabits, completedCount, percentage];
}
