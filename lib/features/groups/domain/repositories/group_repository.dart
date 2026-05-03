import '../entities/group.dart';
import '../entities/member_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class GroupRepository {
  // Group operations
  Future<String> createGroup(GroupEntity group);
  Future<List<GroupEntity>> getGroups({String? userId});
  Future<GroupEntity?> getGroupById(String id);
  Future<void> updateGroup(GroupEntity group);
  Future<void> deleteGroup(String groupId);

  // Member operations
  Future<void> addMember(String groupId, MemberEntity member);
  Future<void> removeMember(String groupId, String userId);
  Future<List<MemberEntity>> getMembers(String groupId);
  Future<void> updateMemberStatus(String groupId, String userId, String status);

  Future<(List<MemberEntity>, DocumentSnapshot?, bool)> getMembersPaginated(
      String groupId, {
        required int limit,
        DocumentSnapshot? startAfter,
      });
}