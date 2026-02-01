import 'package:equatable/equatable.dart';

/// Report Model
class ReportModel extends Equatable {
  final String id;
  final String userId;
  final int month;
  final int year;
  final double overallCompletionRate;
  final int totalHabitsTracked;
  final int totalDaysTracked;
  final int bestStreak;
  final String aiSummary;
  final List<String> achievements;
  final List<String> areasForImprovement;
  final Map<String, double> categoryStats;
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.overallCompletionRate,
    required this.totalHabitsTracked,
    required this.totalDaysTracked,
    required this.bestStreak,
    required this.aiSummary,
    required this.achievements,
    required this.areasForImprovement,
    required this.categoryStats,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      overallCompletionRate: (json['overall_completion_rate'] as num).toDouble(),
      totalHabitsTracked: json['total_habits_tracked'] as int,
      totalDaysTracked: json['total_days_tracked'] as int,
      bestStreak: json['best_streak'] as int,
      aiSummary: json['ai_summary'] as String,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      areasForImprovement: (json['areas_for_improvement'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categoryStats: (json['category_stats'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'month': month,
      'year': year,
      'overall_completion_rate': overallCompletionRate,
      'total_habits_tracked': totalHabitsTracked,
      'total_days_tracked': totalDaysTracked,
      'best_streak': bestStreak,
      'ai_summary': aiSummary,
      'achievements': achievements,
      'areas_for_improvement': areasForImprovement,
      'category_stats': categoryStats,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        month,
        year,
        overallCompletionRate,
        totalHabitsTracked,
        totalDaysTracked,
        bestStreak,
        aiSummary,
        achievements,
        areasForImprovement,
        categoryStats,
        createdAt,
      ];
}

/// Report Content Model
class ReportContent extends Equatable {
  final String summary;
  final List<String> improvements;
  final List<String> skillsLearned;
  final List<String> areasToImprove;
  final List<RevisionSuggestion> revisionSuggestions;
  final String motivationalNote;

  const ReportContent({
    required this.summary,
    required this.improvements,
    required this.skillsLearned,
    required this.areasToImprove,
    required this.revisionSuggestions,
    required this.motivationalNote,
  });

  factory ReportContent.fromJson(Map<String, dynamic> json) {
    return ReportContent(
      summary: json['summary'] as String? ?? '',
      improvements: (json['improvements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      skillsLearned: (json['skills_learned'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      areasToImprove: (json['areas_to_improve'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      revisionSuggestions: (json['revision_suggestions'] as List<dynamic>?)
              ?.map((e) => RevisionSuggestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      motivationalNote: json['motivational_note'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        summary,
        improvements,
        skillsLearned,
        areasToImprove,
        revisionSuggestions,
        motivationalNote,
      ];
}

/// Revision Suggestion Model
class RevisionSuggestion extends Equatable {
  final String skill;
  final String reason;
  final int suggestedDurationDays;
  final int dailyMinutes;

  const RevisionSuggestion({
    required this.skill,
    required this.reason,
    required this.suggestedDurationDays,
    required this.dailyMinutes,
  });

  factory RevisionSuggestion.fromJson(Map<String, dynamic> json) {
    return RevisionSuggestion(
      skill: json['skill'] as String,
      reason: json['reason'] as String? ?? '',
      suggestedDurationDays: json['suggested_duration_days'] as int? ?? 7,
      dailyMinutes: json['daily_minutes'] as int? ?? 30,
    );
  }

  @override
  List<Object?> get props => [
        skill,
        reason,
        suggestedDurationDays,
        dailyMinutes,
      ];
}

/// Revision Habit Model
class RevisionHabitModel extends Equatable {
  final String id;
  final String originalSkill;
  final String sourceMonth;
  final int durationDays;
  final int dailyDurationMinutes;
  final RevisionStatus status;
  final DateTime createdAt;

  const RevisionHabitModel({
    required this.id,
    required this.originalSkill,
    required this.sourceMonth,
    required this.durationDays,
    required this.dailyDurationMinutes,
    required this.status,
    required this.createdAt,
  });

  factory RevisionHabitModel.fromJson(Map<String, dynamic> json) {
    return RevisionHabitModel(
      id: json['id'] as String,
      originalSkill: json['original_skill'] as String,
      sourceMonth: json['source_month'] as String,
      durationDays: json['duration_days'] as int? ?? 7,
      dailyDurationMinutes: json['daily_duration_minutes'] as int? ?? 60,
      status: RevisionStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        originalSkill,
        sourceMonth,
        durationDays,
        dailyDurationMinutes,
        status,
        createdAt,
      ];
}

/// Revision Status Enum
enum RevisionStatus {
  pending,
  accepted,
  rejected,
  declined,
  completed;

  String get displayName {
    switch (this) {
      case RevisionStatus.pending:
        return 'Pending';
      case RevisionStatus.accepted:
        return 'Accepted';
      case RevisionStatus.rejected:
        return 'Rejected';
      case RevisionStatus.declined:
        return 'Declined';
      case RevisionStatus.completed:
        return 'Completed';
    }
  }

  static RevisionStatus fromString(String value) {
    return RevisionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RevisionStatus.pending,
    );
  }
}

/// Revision Suggestion Model (for provider use)
class RevisionSuggestionModel extends Equatable {
  final String id;
  final String userId;
  final String habitId;
  final String habitTitle;
  final String currentState;
  final String suggestedChange;
  final String reason;
  final double aiConfidence;
  final RevisionStatus status;
  final DateTime createdAt;

  const RevisionSuggestionModel({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.habitTitle,
    required this.currentState,
    required this.suggestedChange,
    required this.reason,
    required this.aiConfidence,
    required this.status,
    required this.createdAt,
  });

  factory RevisionSuggestionModel.fromJson(Map<String, dynamic> json) {
    return RevisionSuggestionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      habitTitle: json['habit_title'] as String,
      currentState: json['current_state'] as String,
      suggestedChange: json['suggested_change'] as String,
      reason: json['reason'] as String,
      aiConfidence: (json['ai_confidence'] as num).toDouble(),
      status: RevisionStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'habit_id': habitId,
      'habit_title': habitTitle,
      'current_state': currentState,
      'suggested_change': suggestedChange,
      'reason': reason,
      'ai_confidence': aiConfidence,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RevisionSuggestionModel copyWith({
    String? id,
    String? userId,
    String? habitId,
    String? habitTitle,
    String? currentState,
    String? suggestedChange,
    String? reason,
    double? aiConfidence,
    RevisionStatus? status,
    DateTime? createdAt,
  }) {
    return RevisionSuggestionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitId: habitId ?? this.habitId,
      habitTitle: habitTitle ?? this.habitTitle,
      currentState: currentState ?? this.currentState,
      suggestedChange: suggestedChange ?? this.suggestedChange,
      reason: reason ?? this.reason,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        habitId,
        habitTitle,
        currentState,
        suggestedChange,
        reason,
        aiConfidence,
        status,
        createdAt,
      ];
}
