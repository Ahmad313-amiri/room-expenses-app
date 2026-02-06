import 'dart:ui';
import 'package:flutter/material.dart';
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
    GroupsPage(),
    ActivityScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Show quick action menu with Blur effect
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Stack(
        children: [
          // Blur layer behind the menu
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.15)),
            ),
          ),
          // Quick action menu body
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildQuickActionSheet(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body content to extend behind the bottom bar
      backgroundColor: const Color(0xFFF7F8FA),
      body: _pages[_selectedIndex],

      // Floating central FAB (+)
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor:Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(30)
        ),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom curved navigation bar with notch for FAB
      bottomNavigationBar: BottomAppBar(
        color: Colors.white12,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side navigation items
              Row(
                children: [
                  _buildNavItem(Icons.dashboard_rounded, 'Home', 0),
                  _buildNavItem(Icons.group_rounded, 'Groups', 1),
                ],
              ),
              // Right side navigation items
              Row(
                children: [
                  _buildNavItem(Icons.notifications_rounded, 'Activity', 2),
                  _buildNavItem(Icons.settings_rounded, 'Settings', 3),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build individual bottom nav item
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return MaterialButton(
      minWidth: MediaQuery.of(context).size.width / 5,
      onPressed: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1D5CFF) : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1D5CFF) : Colors.grey.shade400,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Quick action sheet content
  Widget _buildQuickActionSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small top bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Action',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // First row: Expense, Income, Transaction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionIcon(Icons.trending_down, 'Expense', Colors.red, () {}),
              _actionIcon(Icons.trending_up, 'Income', Colors.green, () {}),
              _actionIcon(Icons.account_balance_wallet, 'Transaction', Colors.blue, () {}),
            ],
          ),
          const SizedBox(height: 24),

          // Second row: New Group, Settlement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionIcon(Icons.group_add, 'New Group', Colors.purple, () {}),
              _actionIcon(Icons.handshake, 'Settlement', Colors.orange, () {}),
            ],
          ),
        ],
      ),
    );
  }

  // Build individual quick action icon
  Widget _actionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close the menu first
        onTap(); // Then execute action
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
