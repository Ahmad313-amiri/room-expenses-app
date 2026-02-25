import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomly/features/auth/data/repository/authentication_repository.dart';
import 'package:roomly/features/auth/presentations/widgets/signup_with_email_and_password_failure.dart';

class SignUpController extends GetxController{

  static SignUpController get instance =>Get.find();
  //Textfield controllers to get data from text fields

  final email = TextEditingController();
  final password = TextEditingController();
  final userName = TextEditingController();
  final phoneNo = TextEditingController();

//    calling this from the ui

Future<void> registerUser(String email, String password,String? name) async {

    try {
      await AuthenticationRepository.instance
          .createUserWithEmailAndPassword(
        email.trim(),
        password.trim(),
        userName.text.trim(),);

    } on SignupWithEmailAndPasswordFailure catch (e) {
      Get.snackbar(
        'Sign Up Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
}
  @override
  void onClose() {
    email.dispose();
    password.dispose();
    userName.dispose();
    phoneNo.dispose();
    super.onClose();
  }
}