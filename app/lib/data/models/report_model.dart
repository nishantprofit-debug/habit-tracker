import 'package:equatable/equatable.dart';

/// Report Model
class ReportModel extends Equatable {
  final String id;
  final String reportMonth;
  final ReportContent content;
  final List<String> skillsLearned;
  final DateTime generatedAt;

  const ReportModel({
    required this.id,
    required this.reportMonth,
    required this.content,
    required this.skillsLearned,
    required this.generatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      reportMonth: json['report_month'] as String,
      content: ReportContent.fromJson(json['content'] as Map<String, dynamic>),
      skillsLearned: (json['skills_learned'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        reportMonth,
        content,
        skillsLearned,
        generatedAt,
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
  declined,
  completed;

  String get displayName {
    switch (this) {
      case RevisionStatus.pending:
        return 'Pending';
      case RevisionStatus.accepted:
        return 'Accepted';
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
