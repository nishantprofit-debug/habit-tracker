import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';

class ReportsListScreen extends ConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'AI Reports',
          style: TextStyle(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _sampleReports.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _sampleReports.length,
              itemBuilder: (context, index) {
                final report = _sampleReports[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ReportCard(
                    month: report['month']!,
                    year: report['year']!,
                    completionRate: double.parse(report['completionRate']!),
                    summary: report['summary']!,
                    onTap: () => context.push('/reports/${report['id']}'),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Reports Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI-generated reports will appear here at the end of each month based on your habit tracking data.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.grey500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sample data
  static final List<Map<String, String>> _sampleReports = [
    {
      'id': '1',
      'month': 'December',
      'year': '2024',
      'completionRate': '0.85',
      'summary': 'Great progress on health habits! Consider adding more variety to your learning routine.',
    },
    {
      'id': '2',
      'month': 'November',
      'year': '2024',
      'completionRate': '0.72',
      'summary': 'Consistent performance across all categories. Focus on maintaining your evening meditation habit.',
    },
    {
      'id': '3',
      'month': 'October',
      'year': '2024',
      'completionRate': '0.68',
      'summary': 'Strong start with exercise habits. Reading habit needs more attention during weekends.',
    },
  ];
}

class _ReportCard extends StatelessWidget {
  final String month;
  final String year;
  final double completionRate;
  final String summary;
  final VoidCallback? onTap;

  const _ReportCard({
    required this.month,
    required this.year,
    required this.completionRate,
    required this.summary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey200.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                    Icons.auto_awesome,
                    color: AppColors.grey700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$month $year',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Monthly Report',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCompletionBadge(),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.grey200),
            const SizedBox(height: 16),
            Text(
              summary,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Text(
                  'View full report',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColors.grey700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBadge() {
    final percentage = (completionRate * 100).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percentage%',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

