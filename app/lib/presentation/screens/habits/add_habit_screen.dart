import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/theme/app_colors.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'health';
  String _selectedFrequency = 'daily';
  bool _isLearningHabit = false;
  TimeOfDay? _reminderTime;
  String _selectedColor = '#000000';
  String _selectedIcon = 'check_circle';

  final List<Map<String, String>> _categories = [
    {'id': 'health', 'label': 'Health', 'icon': 'favorite'},
    {'id': 'learning', 'label': 'Learning', 'icon': 'school'},
    {'id': 'productivity', 'label': 'Productivity', 'icon': 'trending_up'},
    {'id': 'personal', 'label': 'Personal', 'icon': 'person'},
  ];

  final List<String> _colors = [
    '#000000',
    '#374151',
    '#6B7280',
    '#9CA3AF',
    '#1F2937',
    '#4B5563',
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG [AddHabitScreen]: Screen loaded');
  }

  @override
  void dispose() {
    debugPrint('DEBUG [AddHabitScreen]: Screen disposed');
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey900),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'New Habit',
          style: TextStyle(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              AppTextField(
                controller: _titleController,
                label: 'Habit Name',
                hint: 'e.g., Morning Exercise',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                hint: 'Add a description...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Category Selection
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 24),

              // Frequency
              const Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 12),
              _buildFrequencySelector(),
              const SizedBox(height: 24),

              // Learning Habit Toggle
              _buildLearningToggle(),
              const SizedBox(height: 24),

              // Color Selection
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey700,
                ),
              ),
              const SizedBox(height: 12),
              _buildColorSelector(),
              const SizedBox(height: 24),

              // Reminder
              _buildReminderSection(),
              const SizedBox(height: 32),

              // Submit Button
              AppButton(
                child: const Text('Create Habit'),
                onPressed: _createHabit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category['id']!;
              if (category['id'] == 'learning') {
                _isLearningHabit = true;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.black : AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.black : AppColors.grey200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category['icon']!),
                  size: 20,
                  color: isSelected ? AppColors.white : AppColors.grey600,
                ),
                const SizedBox(width: 8),
                Text(
                  category['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'favorite':
        return Icons.favorite_outline;
      case 'school':
        return Icons.school_outlined;
      case 'trending_up':
        return Icons.trending_up;
      case 'person':
        return Icons.person_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildFrequencySelector() {
    return Row(
      children: [
        Expanded(
          child: _buildFrequencyOption('daily', 'Daily'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFrequencyOption('weekly', 'Weekly'),
        ),
      ],
    );
  }

  Widget _buildFrequencyOption(String value, String label) {
    final isSelected = _selectedFrequency == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFrequency = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.grey200,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.white : AppColors.grey700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearningToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.grey700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learning Habit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track this as a learning goal',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isLearningHabit,
            onChanged: (value) {
              setState(() {
                _isLearningHabit = value;
              });
            },
            activeColor: AppColors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return Row(
      children: _colors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.grey400, width: 3)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: AppColors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderSection() {
    return GestureDetector(
      onTap: _selectReminderTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.grey700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reminder',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _reminderTime != null
                        ? _formatTime(_reminderTime!)
                        : 'Set a daily reminder',
                    style: TextStyle(
                      fontSize: 13,
                      color: _reminderTime != null
                          ? AppColors.grey700
                          : AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.black,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.grey900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _reminderTime = time;
      });
    }
  }

  void _createHabit() {
    debugPrint('DEBUG [AddHabitScreen]: Create Habit button tapped');
    debugPrint('DEBUG [AddHabitScreen]: Title = ${_titleController.text}');
    debugPrint('DEBUG [AddHabitScreen]: Category = $_selectedCategory, Frequency = $_selectedFrequency');
    debugPrint('DEBUG [AddHabitScreen]: IsLearning = $_isLearningHabit, Color = $_selectedColor');

    if (_formKey.currentState!.validate()) {
      debugPrint('DEBUG [AddHabitScreen]: Form validation PASSED');
      // TODO: Implement habit creation with provider
      final habit = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'frequency': _selectedFrequency,
        'isLearningHabit': _isLearningHabit,
        'color': _selectedColor,
        'icon': _selectedIcon,
        'reminderTime': _reminderTime?.toString(),
      };
      debugPrint('DEBUG [AddHabitScreen]: Habit data = $habit');

      // Show success and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit created successfully'),
          backgroundColor: AppColors.grey900,
        ),
      );

      debugPrint('DEBUG [AddHabitScreen]: Navigating back');
      context.pop();
    } else {
      debugPrint('DEBUG [AddHabitScreen]: Form validation FAILED');
    }
  }
}

