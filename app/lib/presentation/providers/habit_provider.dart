import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/habit_model.dart';

/// Habits state
class HabitsState {
  final List<HabitModel> habits;
  final bool isLoading;
  final String? error;
  final HabitCategory? filterCategory;
  final bool showArchived;

  const HabitsState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
    this.filterCategory,
    this.showArchived = false,
  });

  HabitsState copyWith({
    List<HabitModel>? habits,
    bool? isLoading,
    String? error,
    HabitCategory? filterCategory,
    bool? showArchived,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterCategory: filterCategory ?? this.filterCategory,
      showArchived: showArchived ?? this.showArchived,
    );
  }

  /// Get active habits
  List<HabitModel> get activeHabits =>
      habits.where((h) => h.isActive).toList();

  /// Get archived habits
  List<HabitModel> get archivedHabits =>
      habits.where((h) => !h.isActive).toList();

  /// Get learning habits
  List<HabitModel> get learningHabits =>
      habits.where((h) => h.isLearningHabit && h.isActive).toList();

  /// Get habits by category
  List<HabitModel> habitsByCategory(HabitCategory category) =>
      habits.where((h) => h.category == category && h.isActive).toList();

  /// Get today's habits
  List<HabitModel> get todayHabits =>
      habits.where((h) => h.isActive && h.frequency == HabitFrequency.daily).toList();
}

/// Habits notifier
class HabitsNotifier extends StateNotifier<HabitsState> {
  HabitsNotifier() : super(const HabitsState());

  /// Load all habits
  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Load from API and local database
      // For now, start with an empty list - users will create their own habits
      await Future.delayed(const Duration(milliseconds: 500));

      final habits = <HabitModel>[];

      state = state.copyWith(
        isLoading: false,
        habits: habits,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create a new habit
  Future<bool> createHabit(HabitModel habit) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Save to API and local database

      await Future.delayed(const Duration(milliseconds: 500));

      final newHabit = habit.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        habits: [...state.habits, newHabit],
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update a habit
  Future<bool> updateHabit(HabitModel habit) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Update via API and local database

      await Future.delayed(const Duration(milliseconds: 500));

      final updatedHabit = habit.copyWith(updatedAt: DateTime.now());

      final habits = state.habits.map((h) {
        return h.id == habit.id ? updatedHabit : h;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        habits: habits,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Toggle habit completion for today
  Future<bool> toggleCompletion(String habitId) async {
    try {
      // TODO: Save to API and local database

      final habits = state.habits.map((h) {
        if (h.id == habitId) {
          return h.copyWith(
            todayCompleted: !h.todayCompleted,
            currentStreak: h.todayCompleted ? h.currentStreak - 1 : h.currentStreak + 1,
            updatedAt: DateTime.now(),
          );
        }
        return h;
      }).toList();

      state = state.copyWith(habits: habits);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Archive a habit
  Future<bool> archiveHabit(String habitId) async {
    try {
      // TODO: Update via API and local database

      final habits = state.habits.map((h) {
        if (h.id == habitId) {
          return h.copyWith(isActive: false, updatedAt: DateTime.now());
        }
        return h;
      }).toList();

      state = state.copyWith(habits: habits);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Restore an archived habit
  Future<bool> restoreHabit(String habitId) async {
    try {
      // TODO: Update via API and local database

      final habits = state.habits.map((h) {
        if (h.id == habitId) {
          return h.copyWith(isActive: true, updatedAt: DateTime.now());
        }
        return h;
      }).toList();

      state = state.copyWith(habits: habits);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete a habit permanently
  Future<bool> deleteHabit(String habitId) async {
    try {
      // TODO: Delete via API and local database

      final habits = state.habits.where((h) => h.id != habitId).toList();
      state = state.copyWith(habits: habits);

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Set category filter
  void setFilterCategory(HabitCategory? category) {
    state = state.copyWith(filterCategory: category);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Habits provider
final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier();
});

/// Today's habits provider
final todayHabitsProvider = Provider<List<HabitModel>>((ref) {
  return ref.watch(habitsProvider).todayHabits;
});

/// Learning habits provider
final learningHabitsProvider = Provider<List<HabitModel>>((ref) {
  return ref.watch(habitsProvider).learningHabits;
});

/// Active habits provider
final activeHabitsProvider = Provider<List<HabitModel>>((ref) {
  return ref.watch(habitsProvider).activeHabits;
});

/// Archived habits provider
final archivedHabitsProvider = Provider<List<HabitModel>>((ref) {
  return ref.watch(habitsProvider).archivedHabits;
});

/// Single habit provider
final habitByIdProvider = Provider.family<HabitModel?, String>((ref, id) {
  final habits = ref.watch(habitsProvider).habits;
  try {
    return habits.firstWhere((h) => h.id == id);
  } catch (_) {
    return null;
  }
});

/// Completion stats provider
final completionStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final habits = ref.watch(habitsProvider).todayHabits;
  final completed = habits.where((h) => h.todayCompleted).length;
  final total = habits.length;

  return {
    'completed': completed,
    'total': total,
    'percentage': total > 0 ? completed / total : 0.0,
  };
});
