import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/habit/habit_card.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
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
                _buildHabitsList(active: true),
                _buildHabitsList(active: false),
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

  Widget _buildHabitsList({required bool active}) {
    // Sample data - will be replaced with actual data from providers
    final habits = active ? _activeHabits : _archivedHabits;

    if (habits.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: HabitCard(
            title: habit['title']!,
            category: habit['category']!,
            streak: int.parse(habit['streak']!),
            isCompleted: habit['completed'] == 'true',
            isLearningHabit: habit['category'] == 'learning',
            onToggle: () {
              debugPrint('DEBUG [HabitsListScreen]: Habit toggled - ${habit['title']}');
              // Toggle habit completion
            },
            onTap: () {
              debugPrint('DEBUG [HabitsListScreen]: Habit tapped - ${habit['title']} (id: ${habit['id']})');
              context.push('/habits/${habit['id']}');
            },
          ),
        );
      },
    );
  }

  // Sample data
  final List<Map<String, String>> _activeHabits = [
    {'id': '1', 'title': 'Morning Exercise', 'category': 'health', 'streak': '12', 'completed': 'true'},
    {'id': '2', 'title': 'Read for 30 minutes', 'category': 'personal', 'streak': '5', 'completed': 'false'},
    {'id': '3', 'title': 'Study Flutter', 'category': 'learning', 'streak': '15', 'completed': 'true'},
    {'id': '4', 'title': 'Meditate', 'category': 'health', 'streak': '8', 'completed': 'true'},
    {'id': '5', 'title': 'Practice algorithms', 'category': 'learning', 'streak': '7', 'completed': 'false'},
    {'id': '6', 'title': 'Review daily goals', 'category': 'productivity', 'streak': '3', 'completed': 'false'},
  ];

  final List<Map<String, String>> _archivedHabits = [
    {'id': '7', 'title': 'Wake up at 5am', 'category': 'personal', 'streak': '0', 'completed': 'false'},
    {'id': '8', 'title': 'No social media', 'category': 'productivity', 'streak': '0', 'completed': 'false'},
  ];
}

