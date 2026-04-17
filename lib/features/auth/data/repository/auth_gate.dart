import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomly/features/auth/presentations/pages/auth_entry_screen.dart';

import '../../../dashboard/presentation/pages/splash_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';
import 'authentication_repository.dart';



class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();

    return Obx(() {
      if (authRepo.firebaseUser.value == null && authRepo.isLoading.value) {
        return const SplashScreen();
      }
      if (authRepo.firebaseUser.value != null) {
        return const HomeScreen();
      }
      return const AuthEntryScreen();
    });
  }
}






















//
// class AuthGate extends StatelessWidget {
//   final controller = Get.put(AuthController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       // loading
//       if (controller.isLoading.value) {
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }
//
//       // error
//       if (controller.error.value.isNotEmpty) {
//         return Scaffold(
//           body: Center(
//             child: Text("Error: ${controller.error.value}"),
//           ),
//         );
//       }
//
//       // logged in
//       if (controller.user.value != null) {
//         return HomeScreen();
//       }
//
//       // logged out
//       return AuthEntryScreen();
//     });
//   }
// }