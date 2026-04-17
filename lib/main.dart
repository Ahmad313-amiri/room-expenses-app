import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/data/repository/auth_gate.dart';
import 'features/groups/presentation/binding/expense_binding.dart';
import 'features/groups/presentation/binding/group_binding.dart';
import 'features/groups/presentation/pages/split_method.dart';
import 'firebase_options.dart';
import 'features/auth/presentations/pages/auth_entry_screen.dart';
import 'features/home/presentation/pages/home_screen.dart';
import 'features/groups/presentation/pages/select_member_screen.dart';
import 'features/groups/presentation/pages/create_group.dart';
import 'features/groups/presentation/pages/groups_page.dart';
import 'features/expenses/presentations/pages/new_expense_app.dart';
import 'features/auth/presentations/widgets/initial_binding.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SplitEaseApp());
}

class SplitEaseApp extends StatelessWidget {
  const SplitEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SplitEase',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthGate(),
      getPages: [
        GetPage(name: '/authEntry', page: () => const AuthEntryScreen()),
        GetPage(name: '/select_members', page: () => const SelectMembersScreen()),

        GetPage(
          name: '/create_group',
          page: () => const CreateNewGroupScreen(),
          // binding: GroupBinding(),
          binding: AppBinding(),
        ),

        GetPage(
          name: '/groups',
          page: () => const GroupsPage(),
          binding: AppBinding(),
        ),

        GetPage(
          name: '/main',
          page: () => const HomeScreen(),
          binding: AppBinding(),
        ),

        GetPage(
          name: '/new_expense',
          page: () => const NewExpensePage(),
          binding: AppBinding(),
        ),
        GetPage(
          name: '/group_expense_split',
          page: () {
            final args = Get.arguments as Map;

            return GroupExpenseSplitScreen(
              groupId: args['groupId'],
              members: args['members'],
            );
          },
          binding:AppBinding(),
        ),
      ],
    );
  }
}