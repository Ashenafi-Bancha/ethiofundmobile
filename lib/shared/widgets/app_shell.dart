import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final useRail = width >= 800;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.primary,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.75)),
              selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              unselectedLabelTextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined, color: Colors.white), selectedIcon: Icon(Icons.home, color: Colors.white), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.explore_outlined, color: Colors.white), selectedIcon: Icon(Icons.explore, color: Colors.white), label: Text('Browse')),
                NavigationRailDestination(icon: Icon(Icons.volunteer_activism_outlined, color: Colors.white), selectedIcon: Icon(Icons.volunteer_activism, color: Colors.white), label: Text('Donations')),
                NavigationRailDestination(icon: Icon(Icons.person_outline, color: Colors.white), selectedIcon: Icon(Icons.person, color: Colors.white), label: Text('Profile')),
              ],
            ),
            const VerticalDivider(width: 1),
            // Expanded content area
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: AppColors.primary,
        indicatorColor: Colors.white24,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.white), selectedIcon: Icon(Icons.home, color: Colors.white), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore_outlined, color: Colors.white), selectedIcon: Icon(Icons.explore, color: Colors.white), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined, color: Colors.white), selectedIcon: Icon(Icons.volunteer_activism, color: Colors.white), label: 'Donations'),
          NavigationDestination(icon: Icon(Icons.person_outline, color: Colors.white), selectedIcon: Icon(Icons.person, color: Colors.white), label: 'Profile'),
        ],
      ),
    );
  }
}