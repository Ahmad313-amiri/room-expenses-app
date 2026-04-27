import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';

class GroupRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  GroupRemoteDataSource({required this.firestore, required this.storage});

  // ========== Group Methods ==========
  Future<String> addGroup(GroupModel group) async {
    final docRef = firestore.collection('groups').doc();
    final groupWithId = group.copyWith(id: docRef.id);
    await docRef.set(groupWithId.toMap());
    return docRef.id;
  }

  Future<List<GroupModel>> getGroups(String userId) async {
    final snapshot = await firestore
        .collection('groups')
        .where('createdBy', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
  }

  Future<void> updateGroup(GroupModel group) async {
    await firestore.collection('groups').doc(group.id).update(group.toMap());
  }

  Future<void> archiveGroup(String groupId) async {
    await firestore.collection('groups').doc(groupId).update({'isArchived': true});
  }

  Future<String> uploadGroupImage(File imageFile, String fileName) async {
    final ref = storage.ref().child('group_covers/$fileName');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  // ========== Member Methods ==========
  Future<void> addMemberToFirestore(String groupId, MemberModel member) async {
    final docRef = firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(member.userId);
    final memberWithId = member.copyWith(
      firestoreId: docRef.id,
    );
    await docRef.set(memberWithId.toMap());
    await refreshMembersCount(groupId);
  }

  Future<List<MemberModel>> getMembers(String groupId) async {
    final snapshot = await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .get();

    print("🔥 FIREBASE MEMBERS COUNT: ${snapshot.docs.length}");

    for (var doc in snapshot.docs) {
      print("🔥 MEMBER DATA: ${doc.data()}");
    }

    return snapshot.docs.map(
          (doc) => MemberModel.fromMap(doc.data(), doc.id),
    ).toList();
  }

  Future<void> removeMember(String groupId, String memberId) async {
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(memberId)
        .delete();
    await refreshMembersCount(groupId);

  }

  Future<void> updateMemberStatus(String groupId, String memberId, String status) async {
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(memberId)
        .update({'invitationStatus': status});
  }


  Future<void> updateGroupCover(String groupId, String imageUrl) async {
    await firestore.collection('groups').doc(groupId).update({
      'coverImageUrl': imageUrl,
    });
  }


  // ========== User Search Methods ==========
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final snapshot = await firestore
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'photoUrl': data['photoUrl'] ?? '',
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final snapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();


    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return {
      'uid': doc.id,
      'name': doc.data()['name'] ?? '',
      'email': doc.data()['email'] ?? '',
    };
  }
  Future<void> refreshMembersCount(String groupId) async {
    final snapshot = await firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .get();

    print("🔥 REAL MEMBERS COUNT: ${snapshot.docs.length}");

    await firestore.collection('groups').doc(groupId).update({
      'membersCount': snapshot.docs.length,
    });
  }
}
