import 'dart:io';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../data_sources/group_remote_datasource.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';


class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remote;

  GroupRepositoryImpl({required this.remote});

  @override
  Future<List<GroupEntity>> getGroups({String? userId}) async {
    if (userId == null) return [];
    try {
      final models = await remote.getGroups(userId);
      AppLogger.i('Fetched ${models.length} groups for user $userId');
      return models;
    } catch (e, stack) {
      AppLogger.e('Error in getGroups', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<GroupEntity?> getGroupById(String id) async {
    try {
      final doc = await remote.firestore.collection('groups').doc(id).get();
      if (!doc.exists) return null;
      AppLogger.i('Fetched group by id: $id');
      return GroupModel.fromMap(doc.data()!);
    } catch (e, stack) {
      AppLogger.e('Error in getGroupById', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<String> createGroup(GroupEntity group, {File? imageFile}) async {
    try {
      var model = GroupModel.fromEntity(group);
      String? imageUrl;
      if (imageFile != null) {
        final fileName = "${group.createdBy}_${DateTime.now().millisecondsSinceEpoch}";
        imageUrl = await remote.uploadGroupImage(imageFile, fileName);
        model = model.copyWith(coverImageUrl: imageUrl);
      }
      final remoteId = await remote.addGroup(model);

      // Add creator as admin member
      final adminMember = MemberModel(
        groupId: remoteId,
        userId: group.createdBy,
        name: 'You',
        role: 'admin',
        joinedAt: DateTime.now(),
        invitationStatus: 'accepted',
        isAppUser: true,
        firestoreId: '',
      );
      await remote.addMemberToFirestore(remoteId, adminMember);

      AppLogger.i('Group created with id: $remoteId');
      return remoteId;
    } catch (e, stack) {
      AppLogger.e('Error creating group', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<void> updateGroup(GroupEntity group) async {
    try {
      final model = GroupModel.fromEntity(group);
      await remote.updateGroup(model);
      AppLogger.i('Group updated: ${group.id}');
    } catch (e, stack) {
      AppLogger.e('Error updating group', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await remote.deleteGroup(groupId); // now uses hard delete, no archive
      AppLogger.i('Group permanently deleted: $groupId');
    } catch (e, stack) {
      AppLogger.e('Error deleting group', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<void> addMember(String groupId, MemberEntity member) async {
    try {
      final model = MemberModel.fromEntity(member);
      await remote.addMemberToFirestore(groupId, model);
      AppLogger.i('Member added to group $groupId: ${member.userId}');
    } catch (e, stack) {
      AppLogger.e('Error adding member', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<List<MemberEntity>> getMembers(String groupId) async {
    try {
      final models = await remote.getMembers(groupId);
      AppLogger.i('Fetched ${models.length} members for group $groupId');
      return models.map((e) => e.toEntity()).toList();
    } catch (e, stack) {
      AppLogger.e('Error getting members', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    try {
      await remote.removeMember(groupId, userId);
      AppLogger.i('Member $userId removed from group $groupId');
    } catch (e, stack) {
      AppLogger.e('Error removing member', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<void> updateMemberStatus(String groupId, String userId, String status) async {
    try {
      // V1 only accepts 'pending' or 'accepted'
      if (status != 'pending' && status != 'accepted') {
        throw Exception('Invalid status for V1: $status');
      }
      await remote.updateMemberStatus(groupId, userId, status);
      AppLogger.i('Member $userId status updated to $status in group $groupId');
    } catch (e, stack) {
      AppLogger.e('Error updating member status', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }
}