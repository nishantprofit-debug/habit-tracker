import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';
import 'package:habit_tracker/presentation/widgets/common/app_text_field.dart';
import 'package:habit_tracker/presentation/widgets/habit/habit_card.dart';
import 'package:habit_tracker/data/models/habit_model.dart';
import 'package:habit_tracker/presentation/providers/habit_provider.dart';

class HabitsListScreen extends ConsumerStatefulWidget {
  const HabitsListScreen({super.key});

  @override
  ConsumerState<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends ConsumerState<HabitsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG [HabitsListScreen]: Screen loaded');
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      debugPrint('DEBUG [HabitsListScreen]: Tab changed to index ${_tabController.index} (${_tabController.index == 0 ? "Active" : "Archived"})');
    });

    // Load habits on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitsProvider.notifier).loadHabits();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'My Habits',
          style: TextStyle(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.black,
          unselectedLabelColor: AppColors.grey500,
          indicatorColor: AppColors.black,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: habitsState.isLoading && habitsState.habits.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.black))
          : Column(
              children: [
                // Search and Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AppSearchField(
                        controller: _searchController,
                        hint: 'Search habits...',
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryFilter(),
                    ],
                  ),
                ),

                // Habits List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHabitsList(
                        habits: habitsState.activeHabits,
                        active: true,
                      ),
                      _buildHabitsList(
                        habits: habitsState.archivedHabits,
                        active: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('DEBUG [HabitsListScreen]: FAB tapped - Opening Add Habit screen');
          context.push('/habits/add');
        },
        backgroundColor: AppColors.black,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'id': 'all', 'label': 'All'},
      {'id': 'health', 'label': 'Health'},
      {'id': 'learning', 'label': 'Learning'},
      {'id': 'productivity', 'label': 'Productivity'},
      {'id': 'personal', 'label': 'Personal'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                debugPrint('DEBUG [HabitsListScreen]: Category filter changed to ${category['label']}');
                setState(() {
                  _selectedCategory = category['id']!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.black : AppColors.grey100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.grey700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHabitsList({
    required List<HabitModel> habits,
    required bool active,
  }) {
    // Filter by search and category
    var filteredHabits = habits.where((h) {
      final matchesSearch = h.title.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == 'all' || h.category.name == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredHabits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? Icons.check_circle_outline : Icons.archive_outlined,
              size: 64,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              active ? 'No habits yet' : 'No archived habits',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.grey500,
              ),
            ),
            if (active) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap + to create your first habit',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey400,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(habitsProvider.notifier).loadHabits(),
      color: AppColors.black,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredHabits.length,
        itemBuilder: (context, index) {
          final habit = filteredHabits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HabitCard(
              title: habit.title,
              category: habit.category.name,
              streak: habit.currentStreak,
              isCompleted: habit.todayCompleted,
              isLearningHabit: habit.isLearningHabit,
              onToggle: () {
                debugPrint('DEBUG [HabitsListScreen]: Habit toggled - ${habit.title}');
                ref.read(habitsProvider.notifier).toggleCompletion(habit.id);
              },
              onTap: () {
                debugPrint('DEBUG [HabitsListScreen]: Habit tapped - ${habit.title} (id: ${habit.id})');
                context.push('/habits/${habit.id}');
              },
            ),
          );
        },
      ),
    );
  }
}


