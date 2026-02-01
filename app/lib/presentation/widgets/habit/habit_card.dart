import 'package:flutter/material.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';

/// Habit card widget with minimalist design
class HabitCard extends StatelessWidget {
  final String title;
  final String category;
  final int streak;
  final bool isCompleted;
  final bool isLearningHabit;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.title,
    required this.category,
    required this.streak,
    this.isCompleted = false,
    this.isLearningHabit = false,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.grey100 : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? AppColors.grey300 : AppColors.grey200,
          ),
        ),
        child: Row(
          children: [
            // Completion checkbox
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted ? AppColors.black : AppColors.grey400,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 18,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // Habit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isCompleted ? AppColors.grey500 : AppColors.grey900,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildCategoryChip(),
                      if (isLearningHabit) ...[
                        const SizedBox(width: 8),
                        _buildLearningBadge(),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Streak indicator
            _buildStreakBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.grey600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLearningBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school_outlined,
            size: 12,
            color: AppColors.white,
          ),
          SizedBox(width: 4),
          Text(
            'Learning',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: streak > 0 ? AppColors.grey900 : AppColors.grey200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: streak > 0 ? AppColors.white : AppColors.grey500,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: streak > 0 ? AppColors.white : AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact habit card for lists
class HabitCardCompact extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback? onToggle;

  const HabitCardCompact({
    super.key,
    required this.title,
    this.isCompleted = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.grey100 : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.black : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCompleted ? AppColors.black : AppColors.grey400,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted ? AppColors.grey500 : AppColors.grey900,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

