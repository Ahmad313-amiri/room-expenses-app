import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomly/features/auth/data/repository/authentication_repository.dart';
import 'package:roomly/features/auth/presentations/widgets/signup_with_email_and_password_failure.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();
  final userName = TextEditingController();
  final phoneNo = TextEditingController();

  Future<bool> registerUser(String email, String password, String? name) async {
    try {
      await AuthenticationRepository.instance
          .createUserWithEmailAndPassword(email.trim(), password.trim(), name?.trim());
      return true;
    } on SignupWithEmailAndPasswordFailure catch (e) {
      Get.snackbar('Sign Up Failed', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('Sign Up Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

// حذف onClose
// @override
// void onClose() {
//   email.dispose();
//   password.dispose();
//   userName.dispose();
//   phoneNo.dispose();
//   super.onClose();
// }
}