import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/data/models/report_model.dart';

/// Reports state
class ReportsState {
  final List<ReportModel> reports;
  final ReportModel? currentReport;
  final bool isLoading;
  final String? error;

  const ReportsState({
    this.reports = const [],
    this.currentReport,
    this.isLoading = false,
    this.error,
  });

  ReportsState copyWith({
    List<ReportModel>? reports,
    ReportModel? currentReport,
    bool? isLoading,
    String? error,
  }) {
    return ReportsState(
      reports: reports ?? this.reports,
      currentReport: currentReport ?? this.currentReport,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Reports notifier
class ReportsNotifier extends StateNotifier<ReportsState> {
  ReportsNotifier() : super(const ReportsState());

  /// Load all reports
  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Load from API

      await Future.delayed(const Duration(milliseconds: 500));

      // Sample data
      final reports = [
        ReportModel(
          id: '1',
          userId: 'user-123',
          month: 12,
          year: 2024,
          overallCompletionRate: 0.85,
          totalHabitsTracked: 6,
          totalDaysTracked: 28,
          bestStreak: 28,
          aiSummary: 'Great progress on health habits! Your morning exercise routine has become a solid habit.',
          achievements: const [
            'Achieved 28-day streak on Morning Exercise',
            'Completed 100% of health habits for 3 consecutive weeks',
          ],
          areasForImprovement: const [
            'Weekend habit completion needs attention',
            'Evening reading habit consistency',
          ],
          categoryStats: const {
            'health': 0.92,
            'learning': 0.78,
            'productivity': 0.85,
            'personal': 0.80,
          },
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ReportModel(
          id: '2',
          userId: 'user-123',
          month: 11,
          year: 2024,
          overallCompletionRate: 0.72,
          totalHabitsTracked: 5,
          totalDaysTracked: 30,
          bestStreak: 21,
          aiSummary: 'Consistent performance across all categories. Focus on maintaining your evening meditation habit.',
          achievements: const [
            'Started 2 new habits successfully',
            'Maintained productivity habits at 80%',
          ],
          areasForImprovement: const [
            'Health category completion dropped',
            'Need to establish evening routine',
          ],
          categoryStats: const {
            'health': 0.75,
            'learning': 0.70,
            'productivity': 0.80,
            'personal': 0.65,
          },
          createdAt: DateTime.now().subtract(const Duration(days: 31)),
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        reports: reports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load a specific report
  Future<void> loadReport(String reportId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Load from API

      await Future.delayed(const Duration(milliseconds: 300));

      final report = state.reports.firstWhere(
        (r) => r.id == reportId,
        orElse: () => throw Exception('Report not found'),
      );

      state = state.copyWith(
        isLoading: false,
        currentReport: report,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear current report
  void clearCurrentReport() {
    state = state.copyWith(currentReport: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Reports provider
final reportsProvider =
    StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier();
});

/// Single report provider
final reportByIdProvider = Provider.family<ReportModel?, String>((ref, id) {
  final reports = ref.watch(reportsProvider).reports;
  try {
    return reports.firstWhere((r) => r.id == id);
  } catch (_) {
    return null;
  }
});

/// Latest report provider
final latestReportProvider = Provider<ReportModel?>((ref) {
  final reports = ref.watch(reportsProvider).reports;
  if (reports.isEmpty) return null;
  return reports.first;
});

/// Revisions state
class RevisionsState {
  final List<RevisionSuggestionModel> suggestions;
  final bool isLoading;
  final String? error;

  const RevisionsState({
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
  });

  RevisionsState copyWith({
    List<RevisionSuggestionModel>? suggestions,
    bool? isLoading,
    String? error,
  }) {
    return RevisionsState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get pending suggestions
  List<RevisionSuggestionModel> get pendingSuggestions =>
      suggestions.where((s) => s.status == RevisionStatus.pending).toList();

  /// Get accepted suggestions
  List<RevisionSuggestionModel> get acceptedSuggestions =>
      suggestions.where((s) => s.status == RevisionStatus.accepted).toList();
}

/// Revisions notifier
class RevisionsNotifier extends StateNotifier<RevisionsState> {
  RevisionsNotifier() : super(const RevisionsState());

  /// Load revision suggestions
  Future<void> loadSuggestions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Load from API

      await Future.delayed(const Duration(milliseconds: 500));

      // Sample data
      final suggestions = [
        RevisionSuggestionModel(
          id: '1',
          userId: 'user-123',
          habitId: '2',
          habitTitle: 'Evening Reading',
          currentState: 'Scheduled at 9:00 PM daily',
          suggestedChange: 'Move to 7:30 PM',
          reason: 'Your completion rate drops significantly after 8 PM.',
          aiConfidence: 0.85,
          status: RevisionStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RevisionSuggestionModel(
          id: '2',
          userId: 'user-123',
          habitId: '5',
          habitTitle: 'Algorithm Practice',
          currentState: 'Daily frequency',
          suggestedChange: 'Change to 5 days per week',
          reason: 'Data shows consistent weekend struggles.',
          aiConfidence: 0.72,
          status: RevisionStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        RevisionSuggestionModel(
          id: '3',
          userId: 'user-123',
          habitId: '4',
          habitTitle: 'Meditation',
          currentState: 'No reminder set',
          suggestedChange: 'Add reminder at 6:30 AM',
          reason: 'Missed sessions correlate with no reminder.',
          aiConfidence: 0.68,
          status: RevisionStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      state = state.copyWith(
        isLoading: false,
        suggestions: suggestions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Accept a suggestion
  Future<bool> acceptSuggestion(String suggestionId) async {
    try {
      // TODO: Apply changes via API

      final suggestions = state.suggestions.map((s) {
        if (s.id == suggestionId) {
          return s.copyWith(status: RevisionStatus.accepted);
        }
        return s;
      }).toList();

      state = state.copyWith(suggestions: suggestions);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reject a suggestion
  Future<bool> rejectSuggestion(String suggestionId) async {
    try {
      // TODO: Update via API

      final suggestions = state.suggestions.map((s) {
        if (s.id == suggestionId) {
          return s.copyWith(status: RevisionStatus.rejected);
        }
        return s;
      }).toList();

      state = state.copyWith(suggestions: suggestions);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Accept multiple suggestions
  Future<bool> acceptMultipleSuggestions(List<String> suggestionIds) async {
    try {
      // TODO: Apply changes via API

      final suggestions = state.suggestions.map((s) {
        if (suggestionIds.contains(s.id)) {
          return s.copyWith(status: RevisionStatus.accepted);
        }
        return s;
      }).toList();

      state = state.copyWith(suggestions: suggestions);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Revisions provider
final revisionsProvider =
    StateNotifierProvider<RevisionsNotifier, RevisionsState>((ref) {
  return RevisionsNotifier();
});

/// Pending suggestions count provider
final pendingSuggestionsCountProvider = Provider<int>((ref) {
  return ref.watch(revisionsProvider).pendingSuggestions.length;
});

