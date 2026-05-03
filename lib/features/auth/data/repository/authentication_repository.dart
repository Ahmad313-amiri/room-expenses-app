import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/util/net_work.dart';
import '../../presentations/widgets/signup_with_email_and_password_failure.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _networkService = Get.find<NetworkService>();

  final Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = true.obs;
  RxBool isSubmitting = false.obs;
  RxBool isEmailVerified = false.obs;

  late final StreamSubscription<User?> _authSub;

  @override
  void onReady() {
    super.onReady();

    _authSub = _auth.authStateChanges().listen((user) async {
      firebaseUser.value = user;
      if (user != null) {
        await _refreshUserStatus(user);
      } else {
        isEmailVerified.value = false;
      }
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _authSub.cancel();
    super.onClose();
  }

  Future<void> _refreshUserStatus(User user) async {
    await user.reload();
    isEmailVerified.value = user.emailVerified;
    if (user.emailVerified) {
      await _db.collection('users').doc(user.uid).update({
        'emailVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> refreshUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _refreshUserStatus(user);
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password, String? name) async {
    if (!_networkService.isOnline) throw 'No internet connection.';
    isSubmitting.value = true;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception("Failed to create user");

      if (name != null && name.trim().isNotEmpty) {
        await user.updateDisplayName(name.trim());
        await user.reload();
      }

      await user.sendEmailVerification();
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email.trim(),
        'displayName': name?.trim() ?? '',
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _refreshUserStatus(user);
      return true;
    } on FirebaseAuthException catch (e) {
      final ex = SignupWithEmailAndPasswordFailure.code(e.code);
      throw ex.message;
    } catch (e) {
      throw "An unknown error occurred. Please try again.";
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    if (!_networkService.isOnline) throw 'No internet connection.';
    isSubmitting.value = true;
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await user.reload();
        await _refreshUserStatus(user);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw "No user found with this email.";
        case 'wrong-password':
          throw "Incorrect password.";
        case 'invalid-email':
          throw "Invalid email address.";
        default:
          throw "Login failed: ${e.message}";
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // resent email
  DateTime _lastResendTime = DateTime(1970);
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw "No user logged in.";
    if (!_networkService.isOnline) throw 'No internet connection.';

    final now = DateTime.now();
    if (now.difference(_lastResendTime).inSeconds < 60) {
      final remaining = 60 - now.difference(_lastResendTime).inSeconds;
      throw "Please wait $remaining seconds before resending.";
    }

    try {
      await user.sendEmailVerification();
      _lastResendTime = now;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw "Too many requests. Please try again in a few minutes.";
      }
      throw "Failed to send verification email: ${e.message}";
    } catch (e) {
      throw "Failed to send verification email. Please try again later.";
    }
  }

  Future<bool> signInWithGoogle() async {
    if (!_networkService.isOnline) throw 'No internet connection.';
    isSubmitting.value = true;
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        if (user != null && user.displayName == null && googleUser.displayName != null) {
          await user.updateDisplayName(googleUser.displayName);
          await user.reload();
        }
        await _db.collection('users').doc(user!.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'emailVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await _refreshUserStatus(user!);
      return true;
    } on FirebaseAuthException catch (e) {
      throw "Google sign-in failed: ${e.message}";
    } catch (e) {
      throw "Connection error with Google. Please try again.";
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (!_networkService.isOnline) throw 'No internet connection.';
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw "Too many requests. Please wait a few minutes.";
      }
      throw "Password reset failed: ${e.message}";
    } catch (e) {
      throw "An error occurred. Please try again.";
    }
  }

  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}