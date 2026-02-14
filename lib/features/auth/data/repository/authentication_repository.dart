import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomly/features/auth/presentations/widgets/signup_with_email_and_password_failure.dart';
import 'package:roomly/features/dashboard/presentation/pages/splash_screen.dart';
import 'package:roomly/features/home/presentation/pages/botton_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();
  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    user == null
        ? Get.offAll(() =>  SplashScreen())
        : Get.offAll(() =>  BottomNavBar());
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String? name
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if(user !=null){
           await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
               {
                 'uid':user.uid ,
                 'email':email,
                 'displayName': name,
                 'phoneNumber': user.phoneNumber ?? '',
                 'photoURL': user.photoURL ?? '',
                 'baseCurrency': 'USD',
                 'createdAt': FieldValue.serverTimestamp(),
                 'updatedAt': FieldValue.serverTimestamp(),

               });


    

      }

    } on FirebaseAuthException catch (e) {
      final ex = SignupWithEmailAndPasswordFailure.code(e.code);
      print("Firebase Auth Exception - ${ex.message}");
      throw ex;
    } catch (_) {
      const ex = SignupWithEmailAndPasswordFailure();
      print("Exception - ${ex.message}");
      throw ex;
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
    } catch (_) {}
  }

  Future<void> logout() async => await _auth.signOut();
}
