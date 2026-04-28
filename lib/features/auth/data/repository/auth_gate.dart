import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../presentations/pages/auth_entry_screen.dart';
import 'authentication_repository.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();

    return Obx(() {

      if (authRepo.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (authRepo.firebaseUser.value != null) {
        return const HomeScreen();
      }

      return const AuthEntryScreen();
    });
  }
}