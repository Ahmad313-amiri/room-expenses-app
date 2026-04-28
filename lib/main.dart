import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:roomly/firebase_api.dart';

import 'firebase_options.dart';

import 'features/auth/data/repository/auth_gate.dart';
import 'features/auth/presentations/pages/auth_entry_screen.dart';
import 'features/auth/presentations/widgets/initial_binding.dart';

import 'features/home/presentation/pages/home_screen.dart';

import 'features/groups/presentation/pages/create_group.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/groups/presentation/pages/select_member_screen.dart';
import 'features/groups/presentation/pages/split_method.dart';

import 'features/expenses/presentations/pages/new_expense_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseApi().initNotifications();
  await GetStorage.init();

  runApp(const SplitEaseApp());
}

class SplitEaseApp extends StatelessWidget {
  const SplitEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SplitEase',
      debugShowCheckedModeBanner: false,

      // Global dependencies register once
      initialBinding: AppBinding(),

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      home: const AuthGate(),

      getPages: [
        GetPage(
          name: '/auth-entry',
          page: () => const AuthEntryScreen(),
        ),

        GetPage(
          name: '/main',
          page: () => const HomeScreen(),
        ),

        GetPage(
          name: '/groups',
          page: () => const GroupsPage(),
        ),

        GetPage(
          name: '/create-group',
          page: () => const CreateNewGroupScreen(),
        ),

        GetPage(
          name: '/select-members',
          page: () => const SelectMembersScreen(),
        ),

        GetPage(
          name: '/new-expense',
          page: () => const NewExpensePage(),
        ),

        GetPage(
          name: '/group-expense-split',
          page: () {
            final args = Get.arguments as Map<String, dynamic>;

            return GroupExpenseSplitScreen(
              groupId: args['groupId'],
              members: args['members'],
            );
          },
        ),
      ],
    );
  }
}