import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';
import 'package:roomly/features/groups/presentation/pages/groups_page.dart';
import 'package:roomly/features/home/presentation/pages/main_dashboard.dart';
// import '../widgets/botton_nav_bar.dart';
import '../widgets/bottom_nav_bar.dart'; // نسخه یکتای نوار پایین

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // صفحات را اینجا تعریف می‌کنیم تا هوم‌سکرین بر آن‌ها مدیریت داشته باشد
  final List<Widget> _pages = [
    const MainDashboard(),
    const GroupsPage(),
    const Center(child: Text('Activity')),
    const Center(child: Text('Settings')),
  ];
  @override

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // برای نمایش بهتر نوار نویگیشن شیشه‌ای
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // استفاده از نوار نویگیشن به عنوان یک ویجت بیرونی
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}