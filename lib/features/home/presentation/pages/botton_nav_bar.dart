import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:roomly/features/groups/presentation/pages/groups_page.dart';
import 'package:roomly/features/home/presentation/pages/activity_page.dart';
import 'package:roomly/features/home/presentation/pages/main_dashboard.dart';
import 'package:roomly/features/home/presentation/pages/setting_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MainDashboard(),
    ActivityPage(),
    GroupsPage(),
    SettingPage(),
  ];

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
    BottomNavItem(icon: Icons.notifications, label: 'Activity'),
    BottomNavItem(icon: Icons.group, label: 'Groups'),
    BottomNavItem(icon: Icons.settings, label: 'Settings'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return CurvedNavigationBar(
      index: _selectedIndex,
      onTap: _onItemTapped,
      color: Colors.blue,
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: Colors.orange.withValues(alpha: 0.8),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      height: 60,
      items: _navItems.map((item) {
        final isSelected = _navItems.indexOf(item) == _selectedIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 2),
            if (isSelected)
              Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  const BottomNavItem({required this.icon, required this.label});
}
