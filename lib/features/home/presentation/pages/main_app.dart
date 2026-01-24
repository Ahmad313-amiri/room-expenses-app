import 'package:flutter/material.dart';
import 'package:roomly/features/home/presentation/pages/setting_page.dart';
import '../../../groups/presentation/pages/groups_page.dart';
import '../widgets/bottom_nav_bar.dart';
import 'activity_page.dart';
import 'home_page.dart';


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    GroupsPage(),
    ActivityPage(),
    SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
