import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';
import 'package:habit_tracker/presentation/widgets/common/app_button.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  // Sample data - will be replaced with actual data from providers
  final Map<String, dynamic> _habit = {
    'id': '1',
    'title': 'Morning Exercise',
    'description': 'Start the day with 30 minutes of exercise',
    'category': 'health',
    'frequency': 'daily',
    'isLearningHabit': false,
    'currentStreak': 12,
    'longestStreak': 28,
    'completionRate': 0.85,
    'totalCompletions': 156,
    'createdAt': '2024-01-15',
  };

  final List<Map<String, dynamic>> _weeklyData = [
    {'day': 'Mon', 'completed': true},
    {'day': 'Tue', 'completed': true},
    {'day': 'Wed', 'completed': false},
    {'day': 'Thu', 'completed': true},
    {'day': 'Fri', 'completed': true},
    {'day': 'Sat', 'completed': true},
    {'day': 'Sun', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.grey700),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.grey700),
            onSelected: (value) {
              switch (value) {
                case 'archive':
                  _archiveHabit();
                  break;
                case 'delete':
                  _deleteHabit();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, color: AppColors.grey600),
                    SizedBox(width: 12),
                    Text('Archive'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.grey600),
                    SizedBox(width: 12),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 28,
                          color: AppColors.grey900,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _habit['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildCategoryChip(_habit['category']),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_habit['description'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _habit['description'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.grey600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Current Streak',
                      '${_habit['currentStreak']}',
                      'days',
                      Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Best Streak',
                      '${_habit['longestStreak']}',
                      'days',
                      Icons.emoji_events_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Completion Rate',
                      '${(_habit['completionRate'] * 100).toInt()}%',
                      null,
                      Icons.pie_chart_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Completions',
                      '${_habit['totalCompletions']}',
                      'times',
                      Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
            ),

            // This Week
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyProgress(),
                ],
              ),
            ),

            // Monthly Calendar
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMonthlyCalendar(),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppButton(
                child: const Text('Mark as Complete Today'),
                onPressed: () {
                  // Mark habit as complete
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grey600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String? unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.grey600),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _weeklyData.map((day) {
        return Column(
          children: [
            Text(
              day['day'],
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: day['completed'] ? AppColors.black : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
                border: day['completed']
                    ? null
                    : Border.all(color: AppColors.grey300),
              ),
              child: day['completed']
                  ? const Icon(Icons.check, color: AppColors.white, size: 20)
                  : null,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyCalendar() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    // Sample completion data
    final completedDays = {1, 2, 3, 5, 6, 8, 9, 10, 12, 15, 16, 17, 19, 20, 22, 23, 24, 26, 27};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - startingWeekday + 2;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox();
              }

              final isCompleted = completedDays.contains(dayNumber);
              final isToday = dayNumber == now.day;

              return Container(
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.grey900 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isCompleted
                      ? Border.all(color: AppColors.grey400, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                      color: isCompleted ? AppColors.white : AppColors.grey700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _archiveHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Habit'),
        content: const Text(
          'Are you sure you want to archive this habit? You can restore it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Archive habit
              context.pop();
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _deleteHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text(
          'Are you sure you want to delete this habit? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete habit
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


