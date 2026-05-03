import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomly/features/groups/presentation/pages/groups_page.dart';
import 'package:roomly/features/home/presentation/pages/activity_page.dart';
import 'package:roomly/features/home/presentation/pages/main_dashboard.dart';
import 'package:roomly/settings/setting_page.dart';
import 'botton_nav_bar.dart';
import 'controller/home_page_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;

  final List<Widget> _pages = const [
    MainDashboard(),
    GroupsPage(),
    ActivityScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
    final args = Get.arguments as Map<String, dynamic>?;
    final initialTab = args?['initialTab'] as int? ?? 0;
    if (initialTab != controller.selectedIndex.value) {
      controller.changeTab(initialTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: _pages,
      )),
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
        currentIndex: controller.selectedIndex.value,
        onTap: (index) {
          controller.changeTab(index);
        },
      )),
    );
  }
}