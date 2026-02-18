// import '../entities/group.dart';
// import '../entities/member_entity.dart';
// import 'group_repository.dart';
//
// class LocalGroupRepository implements GroupRepository {
//
//   final List<GroupEntity> _groups = [];
//   final Map<String, List<GroupMemberEntity>> _members = {};
//
//   @override
//   Future<void> createGroup(GroupEntity group) async {
//     _groups.add(group);
//     _members[group.id] = [];
//   }
//
//   @override
//   Future<List<GroupEntity>> getGroups() async {
//     return _groups;
//   }
//
//   @override
//   @override
//   Future<GroupEntity?> getGroupById(String id) async {
//     try {
//       return _groups.firstWhere((g) => g.id == id);
//     } catch (e) {
//       return null;
//     }
//   }
//
//
//   @override
//   Future<void> archiveGroup(String groupId) async {
//     final index = _groups.indexWhere((g) => g.id == groupId);
//     if (index != -1) {
//       final g = _groups[index];
//       _groups[index] = GroupEntity(
//         id: g.id,
//         name: g.name,
//         description: g.description,
//         coverImageUrl: g.coverImageUrl,
//         currency: g.currency,
//         createdBy: g.createdBy,
//         isArchived: true,
//         createdAt: g.createdAt,
//         updatedAt: DateTime.now(),
//         settings: g.settings,
//       );
//     }
//   }
//
//   @override
//   Future<void> addMember(
//       String groupId,
//       GroupMemberEntity member,
//       ) async {
//     _members[groupId]?.add(member);
//   }
//
//   @override
//   Future<List<GroupMemberEntity>> getMembers(
//       String groupId,
//       ) async {
//     return _members[groupId] ?? [];
//   }
// }



import '../entities/group.dart';
import '../entities/member_entity.dart';
import 'group_repository.dart';

class LocalGroupRepository implements GroupRepository {
  final List<GroupEntity> _groups = [];
  final Map<String, List<GroupMemberEntity>> _members = {};

  @override
  Future<void> createGroup(GroupEntity group) async {
    _groups.add(group);
    _members[group.id] = [];
  }

  @override
  Future<List<GroupEntity>> getGroups({String? userId}) async {
    return _groups;
  }

  @override
  Future<GroupEntity?> getGroupById(String id) async {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> archiveGroup(String groupId) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final g = _groups[index];
      _groups[index] = GroupEntity(
        id: g.id,
        name: g.name,
        description: g.description,
        coverImageUrl: g.coverImageUrl,
        currency: g.currency,
        createdBy: g.createdBy,
        isArchived: true,
        createdAt: g.createdAt,
        updatedAt: DateTime.now(),
        settings: g.settings,
      );
    }
  }

  @override
  Future<void> addMember(String groupId, GroupMemberEntity member) async {
    _members[groupId]?.add(member);
  }

  @override
  Future<List<GroupMemberEntity>> getMembers(String groupId) async {
    return _members[groupId] ?? [];
  }

  @override
  Future<void> addGroupModel(dynamic groupModel) async {
    // اینجا کار خاصی نیاز نیست، فقط برای همخوانی با Controller
  }
}
