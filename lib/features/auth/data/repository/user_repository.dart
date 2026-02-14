import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomly/features/auth/domain/entities/user_entity.dart';
class UserRepository extends GetxController{
  static UserRepository get instance=> Get.find();
  final _firestore = FirebaseFirestore.instance;

  final Rx<UserEntity?> _user = Rx<UserEntity?>(null);
  UserEntity? get user => _user.value;

  Future<void> getCurrentUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user.value = UserEntity(
          id: doc['uid'],
          email: doc['email'],
          name: doc['displayName'],
        );
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

}
