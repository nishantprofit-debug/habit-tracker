import 'package:equatable/equatable.dart';

/// Habit Category Enum
enum HabitCategory {
  learning,
  health,
  productivity,
  personal;

  String get displayName {
    switch (this) {
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.personal:
        return 'Personal';
    }
  }

  static HabitCategory fromString(String value) {
    return HabitCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitCategory.personal,
    );
  }
}

/// Habit Frequency Enum
enum HabitFrequency {
  daily,
  weekly;

  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
    }
  }

  static HabitFrequency fromString(String value) {
    return HabitFrequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitFrequency.daily,
    );
  }
}

/// Habit Model
class HabitModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final HabitCategory category;
  final HabitFrequency frequency;
  final bool isActive;
  final bool isLearningHabit;
  final String color;
  final String icon;
  final String? reminderTime;
  final int currentStreak;
  final int longestStreak;
  final bool todayCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool synced;

  const HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category = HabitCategory.personal,
    this.frequency = HabitFrequency.daily,
    this.isActive = true,
    this.isLearningHabit = false,
    this.color = '#424242',
    this.icon = 'check',
    this.reminderTime,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.todayCompleted = false,
    required this.createdAt,
    this.updatedAt,
    this.synced = false,
  });

  /// Create from JSON
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String?,
      category: HabitCategory.fromString(json['category'] as String? ?? 'personal'),
      frequency: HabitFrequency.fromString(json['frequency'] as String? ?? 'daily'),
      isActive: json['is_active'] as bool? ?? true,
      isLearningHabit: json['is_learning_habit'] as bool? ?? false,
      color: json['color'] as String? ?? '#424242',
      icon: json['icon'] as String? ?? 'check',
      reminderTime: json['reminder_time'] as String?,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      todayCompleted: json['today_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      synced: json['synced'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'frequency': frequency.name,
      'is_active': isActive,
      'is_learning_habit': isLearningHabit,
      'color': color,
      'icon': icon,
      'reminder_time': reminderTime,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'today_completed': todayCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced': synced,
    };
  }

  /// Create from database map
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: HabitCategory.fromString(map['category'] as String? ?? 'personal'),
      frequency: HabitFrequency.fromString(map['frequency'] as String? ?? 'daily'),
      isActive: (map['is_active'] as int?) == 1,
      isLearningHabit: (map['is_learning_habit'] as int?) == 1,
      color: map['color'] as String? ?? '#424242',
      icon: map['icon'] as String? ?? 'check',
      reminderTime: map['reminder_time'] as String?,
      currentStreak: map['current_streak'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      todayCompleted: false,
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
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'frequency': frequency.name,
      'is_active': isActive ? 1 : 0,
      'is_learning_habit': isLearningHabit ? 1 : 0,
      'color': color,
      'icon': icon,
      'reminder_time': reminderTime,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  /// Copy with
  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    HabitCategory? category,
    HabitFrequency? frequency,
    bool? isActive,
    bool? isLearningHabit,
    String? color,
    String? icon,
    String? reminderTime,
    int? currentStreak,
    int? longestStreak,
    bool? todayCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      isLearningHabit: isLearningHabit ?? this.isLearningHabit,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      reminderTime: reminderTime ?? this.reminderTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      todayCompleted: todayCompleted ?? this.todayCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        category,
        frequency,
        isActive,
        isLearningHabit,
        color,
        icon,
        reminderTime,
        currentStreak,
        longestStreak,
        todayCompleted,
        createdAt,
        updatedAt,
        synced,
      ];
}
