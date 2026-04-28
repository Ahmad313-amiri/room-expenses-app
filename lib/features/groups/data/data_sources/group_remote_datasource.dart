import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';

/// Remote data source for group-related Firebase operations.
/// Handles groups, members, images, and user search.
class GroupRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  GroupRemoteDataSource({required this.firestore, required this.storage});

  // ========== Group Methods ==========

  /// Creates a new group document and returns its ID.
  /// Throws [Exception] on failure.
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

  /// Returns groups created by the given user (not archived).
  Future<List<GroupModel>> getGroups(String userId) async {
    try {
      final snapshot = await firestore
          .collection('groups')
          .where('createdBy', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 15));
      return snapshot.docs.map((doc) => GroupModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw _handleException(e, 'getGroups');
    }
  }

  /// Updates an existing group.
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

  /// Permanently deletes a group document.
  /// Note: Subcollections (members, expenses, settlements) will remain as orphaned.
  /// For V1 this is acceptable. For V2 consider deleting subcollections recursively.
  Future<void> deleteGroup(String groupId) async {
    try {
      await firestore.collection('groups').doc(groupId).delete();
    } catch (e) {
      throw _handleException(e, 'deleteGroup');
    }
  }

  /// Uploads a group cover image to Firebase Storage.
  /// Returns download URL. Throws on failure.
  Future<String> uploadGroupImage(File imageFile, String fileName) async {
    try {
      final ref = storage.ref().child('group_covers/$fileName');
      final uploadTask = await ref.putFile(imageFile);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      throw _handleException(e, 'uploadGroupImage');
    }
  }

  // ========== Member Methods ==========

  /// Adds a member to the group's members subcollection.
  /// Also updates the membersCount field in the group document.
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

  /// Retrieves all members of a group.
  Future<List<MemberModel>> getMembers(String groupId) async {
    try {
      final snapshot = await firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .get()
          .timeout(const Duration(seconds: 15));

      return snapshot.docs.map(
            (doc) => MemberModel.fromMap(doc.data(), doc.id),
      ).toList();
    } catch (e) {
      throw _handleException(e, 'getMembers');
    }
  }

  /// Removes a member from the group.
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

  /// Updates a member's invitation status. V1 only supports 'pending' or 'accepted'.
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

  /// Updates the group's cover image URL.
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

  /// Searches users by email prefix.
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
        final data = doc.data();
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

  /// Finds a user by exact email match.
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
      return {
        'uid': doc.id,
        'name': doc.data()['name'] ?? '',
        'email': doc.data()['email'] ?? '',
      };
    } catch (e) {
      throw _handleException(e, 'findUserByEmail');
    }
  }

  /// Updates the membersCount field in the group document based on actual member count.
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
      // Non-critical operation – log but don't throw.
      debugPrint('Failed to refresh members count for group $groupId: $e');
    }
  }

  // ========== Private Helper ==========

  /// Converts caught errors into user-friendly exceptions.
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