import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';
import 'package:habit_tracker/presentation/widgets/common/app_button.dart';
import 'package:habit_tracker/data/models/habit_model.dart';
import 'package:habit_tracker/presentation/providers/habit_provider.dart';

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
  // Get habit from provider
  HabitModel? get _habit {
    final habits = ref.watch(habitsProvider).habits;
    try {
      return habits.firstWhere((h) => h.id == widget.habitId);
    } catch (_) {
      return null;
    }
  }

  // Helper to format date

  @override
  Widget build(BuildContext context) {
    final habit = _habit;

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.grey900),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Habit not found'),
        ),
      );
    }

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
              // Navigate to edit screen - pass habit object or ID
              // context.push('/habits/edit/${habit.id}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon!')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.grey700),
            onSelected: (value) {
              switch (value) {
                case 'archive':
                  _archiveHabit(habit);
                  break;
                case 'delete':
                  _deleteHabit(habit);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    const Icon(Icons.archive_outlined, color: AppColors.grey600),
                    const SizedBox(width: 12),
                    Text(habit.isActive ? 'Archive' : 'Unarchive'),
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
                        child: Icon(
                          _getIconData(habit.icon),
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
                              habit.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildCategoryChip(habit.category.displayName),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (habit.description != null && habit.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      habit.description!,
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
                      '${habit.currentStreak}',
                      'days',
                      Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Best Streak',
                      '${habit.longestStreak}',
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
                      'Frequency',
                      habit.frequency.displayName,
                      null,
                      Icons.repeat,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Status',
                       habit.isActive ? 'Active' : 'Archived',
                      null,
                      habit.isActive ? Icons.check_circle_outline : Icons.archive_outlined,
                    ),
                  ),
                ],
              ),
            ),

            // This Week - Placeholder for now as we need history data
            // To properly implement this we'd need a separate endpoint for habit history
            
            const SizedBox(height: 32),

            // Action Buttons
            if (habit.isActive)
              Padding(
                padding: const EdgeInsets.all(20),
                child: AppButton(
                  backgroundColor: habit.todayCompleted ? AppColors.grey300 : AppColors.black,
                  textColor: habit.todayCompleted ? AppColors.black : AppColors.white,
                  onPressed: () {
                    _toggleCompletion(habit);
                  },
                  child: Text(habit.todayCompleted ? 'Mark as Incomplete' : 'Mark as Complete Today'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper to map string icon name to IconData (simplified)
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center': return Icons.fitness_center;
      case 'book': return Icons.book;
      case 'work': return Icons.work;
      case 'water_drop': return Icons.water_drop;
      case 'restaurant': return Icons.restaurant;
      case 'school': return Icons.school; 
      case 'code': return Icons.code; 
      case 'spa': return Icons.spa;
      // Add more valid icon checks
      default: return Icons.check;
    }
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
                  fontSize: 20, // Reduced font size slightly to fit
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
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

  Future<void> _toggleCompletion(HabitModel habit) async {
    final success = await ref.read(habitsProvider.notifier).toggleCompletion(habit.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(habit.todayCompleted ? 'Marked as incomplete' : 'Marked as complete!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _archiveHabit(HabitModel habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(habit.isActive ? 'Archive Habit' : 'Unarchive Habit'),
        content: Text(
          habit.isActive 
          ? 'Are you sure you want to archive this habit? It will be moved to the archived tab.'
          : 'Are you sure you want to unarchive this habit?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              bool success = false;
              if (habit.isActive) {
                success = await ref.read(habitsProvider.notifier).deactivateHabit(habit.id);
              } else {
                // We need a restore/activate habit method in provider, simpler to just update habit with isActive=true
                // But for now, let's assume deactivateHabit toggle or create a separate one. 
                // Let's assume we implement a re-activate path. 
                // For now, let's just use updateHabit to set isActive = true
                 final updatedHabit = habit.copyWith(isActive: true);
                 success = await ref.read(habitsProvider.notifier).updateHabit(updatedHabit);
              }

              if (success && mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(habit.isActive ? 'Habit archived' : 'Habit restored')),
                 );
                 context.pop(); // Go back to list
              }
            },
            child: Text(habit.isActive ? 'Archive' : 'Restore'),
          ),
        ],
      ),
    );
  }

  void _deleteHabit(HabitModel habit) {
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
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(habitsProvider.notifier).deleteHabit(habit.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Habit deleted')),
                );
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


