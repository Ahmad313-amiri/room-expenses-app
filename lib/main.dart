import 'package:flutter/material.dart';
import 'package:roomly/features/auth/data/repository/authentication_repository.dart';
import 'package:roomly/features/auth/presentations/pages/auth_entry_screen.dart';
import 'package:roomly/features/dashboard/presentation/pages/onboarding_screen.dart';
import 'package:roomly/features/dashboard/presentation/pages/splash_screen.dart';
import 'features/auth/presentations/pages/login_page.dart';
import 'features/auth/presentations/widgets/initial_bindng.dart';
import 'features/expenses/presentations/pages/new_expense_app.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/home/presentation/pages/main_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => Get.put(AuthenticationRepository()),);
  initialBinding:InitialBinding();
  runApp(const SplitEaseApp());
}

class SplitEaseApp extends StatelessWidget {
  const SplitEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SplitEase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/onSplash',
      routes: {
        '/onSplash': (context) => const SplashScreen(),
        '/authEntry': (context) => const AuthEntryScreen(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainDashboard(),
        '/groups': (context) => const GroupsPage(),
       '/new_expense': (context) => const NewExpensePage(),
      },
    );
  }
}
