import 'package:flutter/material.dart';
import 'features/auth/presentations/pages/login_page.dart';
import 'features/expenses/presentations/pages/new_expense_app.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/home/presentation/pages/main_dashboard.dart';



void main() {
  runApp(const SplitEaseApp());
}

class SplitEaseApp extends StatelessWidget {
  const SplitEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitEase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainDashboard(),
        '/groups': (context) => const GroupsPage(),
       '/new_expense': (context) => const NewExpensePage(),
      },
    );
  }
}
