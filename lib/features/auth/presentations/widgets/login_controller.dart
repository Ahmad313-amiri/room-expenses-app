import 'package:roomly/features/auth/presentations/widgets/signup_with_email_and_password_failure.dart';
import 'package:get/get.dart';
import '../../data/repository/authentication_repository.dart';
import 'package:flutter/material.dart';
class SignInController extends GetxController {
  static SignInController get instance => Get.find();
  //Textfield controllers to get data from text fields

  final email = TextEditingController();
  final password = TextEditingController();
  // final phoneNo = TextEditingController();

  //    calling this from the ui
  Future<void> loginUserController(String email, String password) async {
    try {
      await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email,
        password,
      );
    } on SignupWithEmailAndPasswordFailure catch (e) {
      Get.snackbar(
        'Login Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    // userName.dispose();
    // phoneNo.dispose();
    super.onClose();
  }
}
