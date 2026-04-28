import 'dart:io';
import '../entities/group.dart';
import '../entities/member_entity.dart';

abstract class GroupRepository {
  // Group operations
  Future<String> createGroup(GroupEntity group, {File? imageFile});
  Future<List<GroupEntity>> getGroups({String? userId});
  Future<GroupEntity?> getGroupById(String id);
  Future<void> updateGroup(GroupEntity group);
  Future<void> deleteGroup(String groupId); // changed from archive to delete

  // Member operations
  Future<void> addMember(String groupId, MemberEntity member);
  Future<void> removeMember(String groupId, String userId);
  Future<List<MemberEntity>> getMembers(String groupId);
  Future<void> updateMemberStatus(String groupId, String userId, String status);
}