import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:roomly/features/auth/presentations/pages/auth_entry_screen.dart';
import 'package:roomly/features/dashboard/presentation/pages/splash_screen.dart';
import 'features/auth/presentations/pages/login_page.dart';
import 'features/auth/presentations/widgets/initial_binding.dart'; // غلط املایی در نام فایل را چک کنید
import 'features/expenses/presentations/pages/new_expense_app.dart';
import 'features/groups/data/models/expense_model.dart';
import 'features/groups/data/models/group_model.dart';
import 'features/groups/data/models/members_model.dart';
import 'features/groups/presentation/pages/create_group.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/groups/provider/group_binding.dart';
import 'features/home/presentation/pages/home_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    GroupModelSchema,
    MemberModelSchema,
    ExpenseModelSchema,
  ], directory: dir.path);
  Get.put<Isar>(isar);

  runApp(const SplitEaseApp());
}

class SplitEaseApp extends StatelessWidget {
  const SplitEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SplitEase',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/onSplash',
      // در لیست getPages فایل main.dart
      getPages: [
        GetPage(name: '/onSplash', page: () => const SplashScreen()),
        GetPage(name: '/authEntry', page: () => const AuthEntryScreen()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(
          name: '/create_group',
          page: () => const CreateGroupScreen(), // نام دقیق کلاس صفحه ساخت گروه را بگذارید
          binding: GroupBinding(), // این خط باعث می‌شود کنترلر در این صفحه شناخته شود
        ),

        GetPage(
          name: '/groups',
          page: () => const GroupsPage(),
          binding: GroupBinding(),
        ),
        GetPage(
          name: '/main',
          page: () => const HomeScreen(),
          binding: GroupBinding(),
        ),
        GetPage(name: '/new_expense', page: () => const NewExpensePage()),
      ],
    );
  }
}
