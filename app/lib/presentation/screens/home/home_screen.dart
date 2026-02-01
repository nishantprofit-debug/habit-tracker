import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';
import 'package:habit_tracker/core/router/app_router.dart';
import 'package:habit_tracker/presentation/providers/habit_provider.dart';
import 'package:habit_tracker/presentation/widgets/common/app_button.dart';
import 'package:habit_tracker/presentation/widgets/habit/habit_card.dart';
import 'package:habit_tracker/presentation/widgets/gamification/level_progress.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load habits when screen initializes
    Future.microtask(() => ref.read(habitsProvider.notifier).loadHabits());
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitsProvider);
    final todayHabits = habitsState.todayHabits;
    final learningHabits = habitsState.learningHabits;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    const SizedBox(height: 24),
                    const LevelProgress(
                      level: 1,
                      currentXP: 0,
                      nextLevelXP: 100,
                      progress: 0.0,
                    ),
                    const SizedBox(height: 24),
                    _buildDateHeader(),
                    const SizedBox(height: 20),
                    _buildProgressSummary(todayHabits),
                  ],
                ),
              ),
            ),

            // Today's Habits Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Habits",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    if (todayHabits.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.habits);
                        },
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Habits List or Empty State
            if (todayHabits.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmptyState(context, "No habits yet", 
                  "Start building better habits today!"),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = todayHabits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HabitCard(
                          title: habit.title,
                          category: habit.category.name,
                          streak: habit.currentStreak,
                          isCompleted: habit.todayCompleted,
                          onToggle: () {
                            ref.read(habitsProvider.notifier).toggleCompletion(habit.id);
                          },
                          onTap: () {
                            context.go('${AppRoutes.habits}/${habit.id}');
                          },
                        ),
                      );
                    },
                    childCount: todayHabits.length,
                  ),
                ),
              ),

            // Learning Habits Section
            if (learningHabits.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Learning Habits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                ),
              ),

            // Learning Habits List
            if (learningHabits.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = learningHabits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HabitCard(
                          title: habit.title,
                          category: 'learning',
                          streak: habit.currentStreak,
                          isCompleted: habit.todayCompleted,
                          isLearningHabit: true,
                          onToggle: () {
                            ref.read(habitsProvider.notifier).toggleCompletion(habit.id);
                          },
                          onTap: () {
                            context.go('${AppRoutes.habits}/${habit.id}');
                          },
                        ),
                      );
                    },
                    childCount: learningHabits.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go(AppRoutes.addHabit);
        },
        backgroundColor: AppColors.black,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          'Add Habit',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            child: const Text('Create Your First Habit'),
            onPressed: () {
              context.go(AppRoutes.addHabit);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ready to build habits?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${months[now.month - 1]} ${now.day}, ${now.year}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = now.subtract(Duration(days: now.weekday - 1 - index));
            final isToday = day.day == now.day;
            return _buildDayItem(
              weekdays[index],
              day.day.toString(),
              isToday,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDayItem(String weekday, String day, bool isSelected) {
    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            weekday,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.grey300 : AppColors.grey500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(List habits) {
    final completed = habits.where((h) => h.todayCompleted).length;
    final total = habits.length;
    final percentage = total > 0 ? (completed / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildProgressItem('Completed', '$completed/$total', null),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.grey300,
          ),
          Expanded(
            child: _buildProgressItem('Streak', '0 days', null),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.grey300,
          ),
          Expanded(
            child: _buildProgressItem('This Week', '$percentage%', null),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, double? progress) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}



