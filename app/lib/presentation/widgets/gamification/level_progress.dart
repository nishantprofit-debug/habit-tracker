import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LevelProgress extends StatelessWidget {
  final int level;
  final int currentXP;
  final int nextLevelXP;
  final double progress;

  const LevelProgress({
    super.key,
    required this.level,
    required this.currentXP,
    required this.nextLevelXP,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lvl $level',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Novice Tracker',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '$currentXP / $nextLevelXP XP',
                style: const TextStyle(
                  color: AppColors.grey700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.xpBarBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xpBarProgress),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
