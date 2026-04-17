import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomly/features/auth/presentations/widgets/signup_with_email_and_password_failure.dart';
import 'package:roomly/features/dashboard/presentation/pages/splash_screen.dart';
import 'package:roomly/features/home/presentation/pages/home_screen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Firebase Instances
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = true.obs;



  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _auth.currentUser;

    firebaseUser.bindStream(_auth.authStateChanges());

    ever(firebaseUser, (_) {
      isLoading.value = false;
    });
  }


  // --- REGISTRATION ---
  Future<void> createUserWithEmailAndPassword(
      String email, String password, String? name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // Create user profile in Firestore
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'displayName': name ?? '',
          'phoneNumber': user.phoneNumber ?? '',
          'photoURL': user.photoURL ?? '',
          'baseCurrency': 'USD',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      final ex = SignupWithEmailAndPasswordFailure.code(e.code);
      throw ex.message;
    } catch (_) {
      throw "An unknown error occurred. Please try again.";
    }
  }

  // --- LOGIN WITH EMAIL ---
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // You can create a LoginFailure class similar to SignupFailure if needed
      throw "Login failed: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred.";
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Return null if the user canceled the sign-in
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);

      // Save user to Firestore if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName ?? '',
          'photoURL': userCredential.user!.photoURL ?? '',
          'baseCurrency': 'USD',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw "Google Auth Failed: ${e.message}";
    } catch (e) {
      print("System Error during Google Sign-In: $e");
      return null;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}