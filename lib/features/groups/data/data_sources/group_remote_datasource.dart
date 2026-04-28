import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/entities/member_entity.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';

/// Remote data source for group-related Firebase operations.
class GroupRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  GroupRemoteDataSource({required this.firestore, required this.storage});

  // ========== Group Methods ==========

  Future<String> addGroup(GroupModel group) async {
    try {
      final docRef = firestore.collection('groups').doc();
      final groupWithId = group.copyWith(id: docRef.id);
      await docRef.set(groupWithId.toMap()).timeout(const Duration(seconds: 15));
      return docRef.id;
    } catch (e) {
      throw _handleException(e, 'addGroup');
    }
  }

  Future<List<GroupModel>> getGroups(String userId) async {
    try {
      final snapshot = await firestore
          .collection('groups')
          .where('createdBy', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));
      return snapshot.docs.map((doc) {
        // FIXED: explicitly cast to Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        return GroupModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw _handleException(e, 'getGroups');
    }
  }

  Future<void> updateGroup(GroupModel group) async {
    try {
      await firestore
          .collection('groups')
          .doc(group.id)
          .update(group.toMap())
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw _handleException(e, 'updateGroup');
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await firestore.collection('groups').doc(groupId).delete();
    } catch (e) {
      throw _handleException(e, 'deleteGroup');
    }
  }

  // ========== Member Methods ==========

  Future<void> addMemberToFirestore(String groupId, MemberModel member) async {
    try {
      final docRef = firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(member.userId);
      final memberWithId = member.copyWith(firestoreId: docRef.id);
      await docRef.set(memberWithId.toMap()).timeout(const Duration(seconds: 15));
      await refreshMembersCount(groupId);
    } catch (e) {
      throw _handleException(e, 'addMemberToFirestore');
    }
  }

  Future<List<MemberModel>> getMembers(String groupId) async {
    try {
      final snapshot = await firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .get()
          .timeout(const Duration(seconds: 15));

      return snapshot.docs.map((doc) {
        // FIXED: explicit cast
        final data = doc.data() as Map<String, dynamic>;
        return MemberModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw _handleException(e, 'getMembers');
    }
  }

  Future<void> removeMember(String groupId, String memberId) async {
    try {
      await firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .delete();
      await refreshMembersCount(groupId);
    } catch (e) {
      throw _handleException(e, 'removeMember');
    }
  }

  Future<void> updateMemberStatus(String groupId, String memberId, String status) async {
    try {
      await firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .update({'invitationStatus': status});
    } catch (e) {
      throw _handleException(e, 'updateMemberStatus');
    }
  }

  Future<void> updateGroupCover(String groupId, String imageUrl) async {
    try {
      await firestore.collection('groups').doc(groupId).update({
        'coverImageUrl': imageUrl,
      });
    } catch (e) {
      throw _handleException(e, 'updateGroupCover');
    }
  }

  // ========== User Search Methods ==========

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    try {
      final snapshot = await firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs.map((doc) {
        // FIXED: explicit cast
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'] ?? '',
        };
      }).toList();
    } catch (e) {
      throw _handleException(e, 'searchUsers');
    }
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      // FIXED: explicit cast
      final data = doc.data() as Map<String, dynamic>;
      return {
        'uid': doc.id,
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
      };
    } catch (e) {
      throw _handleException(e, 'findUserByEmail');
    }
  }

  Future<void> refreshMembersCount(String groupId) async {
    try {
      final snapshot = await firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .get()
          .timeout(const Duration(seconds: 10));

      await firestore.collection('groups').doc(groupId).update({
        'membersCount': snapshot.docs.length,
      });
    } catch (e) {
      debugPrint('Failed to refresh members count for group $groupId: $e');
    }
  }

  // ========== Pagination ==========

  Future<(List<MemberEntity>, DocumentSnapshot?, bool)> getMembersPaginated(
      String groupId, {
        required int limit,
        DocumentSnapshot? startAfter,
      }) async {
    Query query = firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .orderBy('joinedAt', descending: true)
        .orderBy('userId')
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final List<MemberEntity> members = snapshot.docs.map((doc) {
      // FIXED: explicit cast
      final data = doc.data() as Map<String, dynamic>;
      return MemberEntity(
        firestoreId: doc.id,
        groupId: groupId,
        userId: data['userId'] ?? '',
        name: data['name'] ?? '',
        role: data['role'] ?? 'member',
        joinedAt: (data['joinedAt'] as Timestamp).toDate(),
        invitationStatus: data['invitationStatus'] ?? 'pending',
        invitedBy: data['invitedBy'],
        photoUrl: data['photoUrl'],
      );
    }).toList();

    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    final hasMore = snapshot.docs.length == limit;
    return (members, lastDoc, hasMore);
  }

  // ========== Private Helper ==========

  Exception _handleException(dynamic error, String methodName) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('You do not have permission to perform this action.');
        case 'unavailable':
          return Exception('Service is temporarily unavailable. Please try again.');
        case 'not-found':
          return Exception('The requested data was not found.');
        default:
          return Exception('Firebase error: ${error.message}');
      }
    }
    if (error is TimeoutException) {
      return Exception('Request timed out. Check your internet connection.');
    }
    if (error is SocketException) {
      return Exception('No internet connection. Please connect and try again.');
    }
    return Exception('$methodName failed: $error');
  }
}