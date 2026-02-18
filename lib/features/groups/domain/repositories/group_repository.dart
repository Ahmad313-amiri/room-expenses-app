// import '../entities/group.dart';
// import '../entities/member_entity.dart';
//
// abstract class GroupRepository {
//
//   Future<void> createGroup(GroupEntity group);
//
//   Future<List<GroupEntity>> getGroups();
//
//   Future<GroupEntity?> getGroupById(String id);
//
//   Future<void> archiveGroup(String groupId);
//
//   Future<void> addMember(
//       String groupId,
//       GroupMemberEntity member,
//       );
//
//   Future<List<GroupMemberEntity>> getMembers(String groupId);
// }
import '../entities/group.dart';
import '../entities/member_entity.dart';

abstract class GroupRepository {
  Future<void> createGroup(GroupEntity group);
  Future<List<GroupEntity>> getGroups({String? userId});
  Future<GroupEntity?> getGroupById(String id);
  Future<void> archiveGroup(String groupId);
  Future<void> addMember(String groupId, GroupMemberEntity member);
  Future<List<GroupMemberEntity>> getMembers(String groupId);
  Future<void> addGroupModel(dynamic groupModel);
}
