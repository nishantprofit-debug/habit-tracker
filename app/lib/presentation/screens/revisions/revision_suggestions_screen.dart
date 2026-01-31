import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/common/app_button.dart';

class RevisionSuggestionsScreen extends ConsumerStatefulWidget {
  const RevisionSuggestionsScreen({super.key});

  @override
  ConsumerState<RevisionSuggestionsScreen> createState() =>
      _RevisionSuggestionsScreenState();
}

class _RevisionSuggestionsScreenState
    extends ConsumerState<RevisionSuggestionsScreen> {
  final Set<String> _selectedSuggestions = {};

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
        title: const Text(
          'AI Suggestions',
          style: TextStyle(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.grey50,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.grey900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Habit Revision Suggestions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Based on your performance data, our AI suggests these adjustments to optimize your habits.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Suggestions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                final isSelected = _selectedSuggestions.contains(suggestion['id']);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _SuggestionCard(
                    suggestion: suggestion,
                    isSelected: isSelected,
                    onToggle: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSuggestions.remove(suggestion['id']);
                        } else {
                          _selectedSuggestions.add(suggestion['id']!);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom Action Bar
          if (_selectedSuggestions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey200.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: AppButton(
                  child: Text('Apply ${_selectedSuggestions.length} Suggestion${_selectedSuggestions.length > 1 ? 's' : ''}'),
                  onPressed: _applySuggestions,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _applySuggestions() {
    // TODO: Implement applying suggestions
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Changes'),
        content: Text(
          'Are you sure you want to apply ${_selectedSuggestions.length} suggestion${_selectedSuggestions.length > 1 ? 's' : ''} to your habits?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${_selectedSuggestions.length} suggestion${_selectedSuggestions.length > 1 ? 's' : ''} applied successfully',
                  ),
                  backgroundColor: AppColors.grey900,
                ),
              );
              context.pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // Sample data
  final List<Map<String, String>> _suggestions = [
    {
      'id': '1',
      'habitTitle': 'Evening Reading',
      'currentState': 'Scheduled at 9:00 PM daily',
      'suggestion': 'Move to 7:30 PM',
      'reason': 'Your completion rate drops significantly after 8 PM. Moving this earlier aligns with your natural wind-down time.',
      'type': 'time_change',
      'impact': 'high',
    },
    {
      'id': '2',
      'habitTitle': 'Algorithm Practice',
      'currentState': 'Daily frequency',
      'suggestion': 'Change to 5 days per week',
      'reason': 'Data shows consistent weekend struggles. A 5-day schedule may be more sustainable.',
      'type': 'frequency_change',
      'impact': 'medium',
    },
    {
      'id': '3',
      'habitTitle': 'Morning Exercise',
      'currentState': '30 minutes',
      'suggestion': 'Add a 15-minute stretching warm-up',
      'reason': 'Your streak is strong. Enhancing with stretching could improve overall health benefits.',
      'type': 'enhancement',
      'impact': 'low',
    },
    {
      'id': '4',
      'habitTitle': 'Meditation',
      'currentState': 'No reminder set',
      'suggestion': 'Add reminder at 6:30 AM',
      'reason': 'Missed sessions correlate with no reminder. A morning prompt could improve consistency.',
      'type': 'reminder',
      'impact': 'medium',
    },
    {
      'id': '5',
      'habitTitle': 'Weekend Reading',
      'currentState': 'None',
      'suggestion': 'Create separate weekend reading habit',
      'reason': 'Your weekday reading is consistent, but weekends show gaps. A dedicated weekend habit with different timing may help.',
      'type': 'new_habit',
      'impact': 'medium',
    },
  ];
}

class _SuggestionCard extends StatelessWidget {
  final Map<String, String> suggestion;
  final bool isSelected;
  final VoidCallback onToggle;

  const _SuggestionCard({
    required this.suggestion,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.grey100 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.grey900 : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion['habitTitle']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        suggestion['currentState']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildImpactBadge(),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white : AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion['suggestion']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              suggestion['reason']!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.grey900 : AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppColors.grey900 : AppColors.grey400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: AppColors.white, size: 16)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    switch (suggestion['type']) {
      case 'time_change':
        icon = Icons.schedule;
        break;
      case 'frequency_change':
        icon = Icons.repeat;
        break;
      case 'enhancement':
        icon = Icons.upgrade;
        break;
      case 'reminder':
        icon = Icons.notifications_outlined;
        break;
      case 'new_habit':
        icon = Icons.add_circle_outline;
        break;
      default:
        icon = Icons.lightbulb_outline;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.grey700, size: 22),
    );
  }

  Widget _buildImpactBadge() {
    Color color;
    String label;

    switch (suggestion['impact']) {
      case 'high':
        color = AppColors.grey900;
        label = 'High Impact';
        break;
      case 'medium':
        color = AppColors.grey600;
        label = 'Medium';
        break;
      default:
        color = AppColors.grey400;
        label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }
}
