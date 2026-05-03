import 'package:roomly/features/auth/presentations/widgets/signup_with_email_and_password_failure.dart';
import 'package:get/get.dart';
import '../../data/repository/authentication_repository.dart';
import 'package:flutter/material.dart';

class SignInController extends GetxController {
  static SignInController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();

  // Login with email & password
  Future<bool> loginUserController(String email, String password) async {
    try {
      await AuthenticationRepository.instance.loginWithEmailAndPassword(email, password);
      return true;
    } on SignupWithEmailAndPasswordFailure catch (e) {
      Get.snackbar('Login Failed', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('Login Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  // Google Sign-In
  Future<bool> loginWithGoogle() async {
    try {
      final success = await AuthenticationRepository.instance.signInWithGoogle();
      return success;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }
}