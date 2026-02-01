import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';
import '../../widgets/common/app_button.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample data - will be replaced with actual data from providers
    final report = _sampleReport;

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
            icon: const Icon(Icons.share_outlined, color: AppColors.grey700),
            onPressed: () {
              // Share report
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(report),
            const SizedBox(height: 32),

            // Overview Stats
            _buildOverviewStats(report),
            const SizedBox(height: 32),

            // AI Summary
            _buildSection(
              'AI Summary',
              Icons.auto_awesome,
              child: Text(
                report['aiSummary']!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.grey700,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Achievements
            _buildSection(
              'Achievements',
              Icons.emoji_events_outlined,
              child: Column(
                children: (report['achievements'] as List<String>).map((achievement) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.grey900,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            achievement,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.grey700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Areas for Improvement
            _buildSection(
              'Areas for Improvement',
              Icons.trending_up,
              child: Column(
                children: (report['improvements'] as List<String>).map((improvement) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.grey400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            improvement,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.grey700,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Category Breakdown
            _buildSection(
              'Category Performance',
              Icons.pie_chart_outline,
              child: Column(
                children: (report['categoryStats'] as List<Map<String, dynamic>>).map((stat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCategoryProgressBar(
                      stat['category'] as String,
                      stat['completion'] as double,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Revision Suggestions
            if ((report['revisionSuggestions'] as List).isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.grey900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'AI Suggestions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Based on your performance, here are some habit adjustments to consider:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...((report['revisionSuggestions'] as List<Map<String, String>>).map((suggestion) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion['title']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    suggestion['reason']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                suggestion['action']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
                    const SizedBox(height: 8),
                    AppButton.outlined(
                      child: const Text('View All Suggestions'),
                      onPressed: () => context.push('/revisions'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> report) {
    return Column(
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
                Icons.auto_awesome,
                color: AppColors.grey700,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${report['month']} ${report['year']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monthly Performance Report',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewStats(Map<String, dynamic> report) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            'Completion',
            '${((report['completionRate'] as double) * 100).toInt()}%',
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            'Best Streak',
            '${report['bestStreak']} days',
            Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            'Active Habits',
            '${report['activeHabits']}',
            Icons.list_alt,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.grey600, size: 24),
          const SizedBox(height: 8),
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
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.grey600, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildCategoryProgressBar(String category, double completion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
              ),
            ),
            Text(
              '${(completion * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: completion,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.grey900),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // Sample data
  static final Map<String, dynamic> _sampleReport = {
    'month': 'December',
    'year': '2024',
    'completionRate': 0.85,
    'bestStreak': 28,
    'activeHabits': 6,
    'aiSummary': '''
This month showed excellent progress in your health and learning categories. Your morning exercise routine has become a solid habit with a 28-day streak.

Your reading habit maintained consistency during weekdays but showed a slight dip during weekends. Consider setting specific reading times for Saturday and Sunday to maintain momentum.

Overall, you've demonstrated strong commitment to personal growth. Keep up the great work!
    ''',
    'achievements': [
      'Achieved 28-day streak on Morning Exercise',
      'Completed 100% of health habits for 3 consecutive weeks',
      'Added 2 new learning habits and maintained them successfully',
      'Improved meditation consistency by 40% compared to last month',
    ],
    'improvements': [
      'Weekend habit completion dropped to 65%',
      'Evening reading habit was missed 8 times this month',
      'Algorithm practice consistency needs attention',
    ],
    'categoryStats': [
      {'category': 'Health', 'completion': 0.92},
      {'category': 'Learning', 'completion': 0.78},
      {'category': 'Productivity', 'completion': 0.85},
      {'category': 'Personal', 'completion': 0.80},
    ],
    'revisionSuggestions': [
      {
        'title': 'Evening Reading',
        'reason': 'Low completion rate suggests timing conflict',
        'action': 'Change time',
      },
      {
        'title': 'Algorithm Practice',
        'reason': 'Inconsistent completion pattern',
        'action': 'Add reminder',
      },
    ],
  };
}

