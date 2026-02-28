class SignupWithEmailAndPasswordFailure {
  final String message;
  const SignupWithEmailAndPasswordFailure([
    this.message = "An Unknown error occurred",
  ]);

  factory SignupWithEmailAndPasswordFailure.code(String code) {
    switch (code) {
      case 'weak-password':
        return SignupWithEmailAndPasswordFailure(
          "Please Enter a stronger password.",
        );
      case 'invalid-email':
        return SignupWithEmailAndPasswordFailure(
          "Email is not valid or badly formated.",
        );
      case 'email-already-in-use':
        return SignupWithEmailAndPasswordFailure(
          "An account already exist for that email.",
        );
      case 'operation-not allowed':
        return SignupWithEmailAndPasswordFailure(
          "Operation is not allowed.Please contact support.",
        );
      case 'user-disabled':
        return SignupWithEmailAndPasswordFailure(
          "This user has been disabled.Please contact support for help.",
        );
      default:
        return SignupWithEmailAndPasswordFailure();
    }
  }
}
