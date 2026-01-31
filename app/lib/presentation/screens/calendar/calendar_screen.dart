import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/habit/habit_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Calendar
          _buildCalendar(),

          // Divider
          Container(
            height: 1,
            color: AppColors.grey200,
          ),

          // Selected Day Habits
          Expanded(
            child: _buildDayHabits(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left, color: AppColors.grey700),
              ),
              Text(
                '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right, color: AppColors.grey700),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => SizedBox(
                      width: 40,
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

              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final completionData = _getCompletionData(date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.grey400, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday || isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? AppColors.white : AppColors.grey900,
                        ),
                      ),
                      if (completionData != null) ...[
                        const SizedBox(height: 2),
                        _buildCompletionIndicator(
                          completionData,
                          isSelected: isSelected,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator(double completion, {bool isSelected = false}) {
    Color color;
    if (completion >= 1.0) {
      color = isSelected ? AppColors.white : AppColors.grey900;
    } else if (completion >= 0.5) {
      color = isSelected ? AppColors.grey300 : AppColors.grey500;
    } else if (completion > 0) {
      color = isSelected ? AppColors.grey400 : AppColors.grey300;
    } else {
      return const SizedBox();
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDayHabits() {
    final habits = _getHabitsForDate(_selectedDate);
    final dateStr = _formatDate(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              const Spacer(),
              Text(
                '${habits.where((h) => h['completed'] == 'true').length}/${habits.length} completed',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),

        // Habits List
        Expanded(
          child: habits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: AppColors.grey300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No habits for this day',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HabitCardCompact(
                        title: habit['title']!,
                        isCompleted: habit['completed'] == 'true',
                        onToggle: _isSameDay(_selectedDate, DateTime.now())
                            ? () {
                                // Toggle completion
                              }
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    final isToday = _isSameDay(date, DateTime.now());
    final isYesterday = _isSameDay(
      date,
      DateTime.now().subtract(const Duration(days: 1)),
    );

    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  double? _getCompletionData(DateTime date) {
    // Sample data - will be replaced with actual data
    final completions = {
      1: 1.0,
      2: 1.0,
      3: 0.5,
      4: 0.0,
      5: 1.0,
      6: 0.75,
      7: 1.0,
      8: 1.0,
      9: 0.5,
      10: 1.0,
      12: 1.0,
      15: 0.75,
      16: 1.0,
      17: 1.0,
      19: 0.5,
      20: 1.0,
      22: 1.0,
      23: 1.0,
      24: 0.75,
      26: 1.0,
      27: 1.0,
    };

    if (date.month == _focusedMonth.month && date.year == _focusedMonth.year) {
      return completions[date.day];
    }
    return null;
  }

  List<Map<String, String>> _getHabitsForDate(DateTime date) {
    // Sample data - will be replaced with actual data from providers
    if (_isSameDay(date, DateTime.now())) {
      return [
        {'title': 'Morning Exercise', 'completed': 'true'},
        {'title': 'Read for 30 minutes', 'completed': 'false'},
        {'title': 'Study Flutter', 'completed': 'true'},
        {'title': 'Meditate', 'completed': 'true'},
        {'title': 'Practice algorithms', 'completed': 'false'},
        {'title': 'Review daily goals', 'completed': 'false'},
      ];
    }

    // Sample past data
    return [
      {'title': 'Morning Exercise', 'completed': 'true'},
      {'title': 'Read for 30 minutes', 'completed': 'true'},
      {'title': 'Study Flutter', 'completed': 'true'},
      {'title': 'Meditate', 'completed': 'false'},
    ];
  }
}
