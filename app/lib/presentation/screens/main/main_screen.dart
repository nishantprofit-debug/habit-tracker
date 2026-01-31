import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';

/// Main Screen with Bottom Navigation
class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    debugPrint('DEBUG [MainScreen]: Current location = $location');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.grey200, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Today',
                isActive: location == AppRoutes.home,
                onTap: () {
                  debugPrint('DEBUG [BottomNav]: Today tab tapped');
                  context.go(AppRoutes.home);
                },
              ),
              _NavItem(
                icon: Icons.check_circle_outline,
                activeIcon: Icons.check_circle,
                label: 'Habits',
                isActive: location == AppRoutes.habits,
                onTap: () {
                  debugPrint('DEBUG [BottomNav]: Habits tab tapped');
                  context.go(AppRoutes.habits);
                },
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Calendar',
                isActive: location == AppRoutes.calendar,
                onTap: () {
                  debugPrint('DEBUG [BottomNav]: Calendar tab tapped');
                  context.go(AppRoutes.calendar);
                },
              ),
              _NavItem(
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: 'Reports',
                isActive: location == AppRoutes.reports,
                onTap: () {
                  debugPrint('DEBUG [BottomNav]: Reports tab tapped');
                  context.go(AppRoutes.reports);
                },
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                isActive: location == AppRoutes.settings,
                onTap: () {
                  debugPrint('DEBUG [BottomNav]: Settings tab tapped');
                  context.go(AppRoutes.settings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.black : AppColors.grey500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.black : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
