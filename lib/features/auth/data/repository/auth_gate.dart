import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../dashboard/presentation/pages/splash_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../presentations/pages/auth_entry_screen.dart';
import '../../presentations/pages/verify_email_screen.dart';
import 'authentication_repository.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();

    return Obx(() {
      if (authRepo.isLoading.value) {
        return const SplashScreen();
      }

      final user = authRepo.firebaseUser.value;
      if (user != null) {
        // User is logged in – check verification status
        if (authRepo.isEmailVerified.value) {
          return const HomeScreen();
        } else {
          return const VerifyEmailScreen();
        }
      }

      return const AuthEntryScreen();
    });
  }
}