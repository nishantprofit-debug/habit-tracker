import 'package:habit_tracker/data/remote/api_client.dart';
import 'package:habit_tracker/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';

import 'package:habit_tracker/data/models/habit_model.dart';

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
  final ApiClient _apiClient = ApiClient.instance;

  HabitsNotifier() : super(const HabitsState());

  /// Load all habits
  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.get(ApiEndpoints.habits);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final habits = data.map((json) => HabitModel.fromJson(json)).toList();

        state = state.copyWith(
          isLoading: false,
          habits: habits,
        );
      } else {
        throw Exception('Failed to load habits: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Load habits error: $e');
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
      final response = await _apiClient.post(
        ApiEndpoints.habits,
        data: {
          'title': habit.title,
          'description': habit.description,
          'category': habit.category.name,
          'frequency': habit.frequency.name,
          'is_learning_habit': habit.isLearningHabit,
          'color': habit.color,
          'icon': habit.icon,
          'reminder_time': habit.reminderTime,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newHabit = HabitModel.fromJson(response.data);

        state = state.copyWith(
          isLoading: false,
          habits: [...state.habits, newHabit],
        );

        return true;
      } else {
        throw Exception('Failed to create habit: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Create habit error: $e');
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
      final response = await _apiClient.put(
        ApiEndpoints.habit(habit.id),
        data: habit.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedHabit = HabitModel.fromJson(response.data);

        final habits = state.habits.map((h) {
          return h.id == updatedHabit.id ? updatedHabit : h;
        }).toList();

        state = state.copyWith(
          isLoading: false,
          habits: habits,
        );

        return true;
      } else {
        throw Exception('Failed to update habit: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Update habit error: $e');
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
      final response = await _apiClient.post(ApiEndpoints.quickComplete(habitId));

      if (response.statusCode == 200) {
        // Update local state
        final habits = state.habits.map((h) {
          if (h.id == habitId) {
            // Backend returns updated user habit log or something similar? 
            // For now, toggle locally based on previous state
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
      } else {
        throw Exception('Failed to toggle completion: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Toggle completion error: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Archive/Deactivate a habit
  Future<bool> deactivateHabit(String habitId) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.habit(habitId),
        data: {'is_active': false},
      );

      if (response.statusCode == 200) {
        final habits = state.habits.map((h) {
          if (h.id == habitId) {
            return h.copyWith(isActive: false, updatedAt: DateTime.now());
          }
          return h;
        }).toList();

        state = state.copyWith(habits: habits);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Delete a habit permanently
  Future<bool> deleteHabit(String habitId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.delete(ApiEndpoints.habit(habitId));

      if (response.statusCode == 200 || response.statusCode == 204) {
        final habits = state.habits.where((h) => h.id != habitId).toList();
        state = state.copyWith(
          isLoading: false,
          habits: habits,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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

