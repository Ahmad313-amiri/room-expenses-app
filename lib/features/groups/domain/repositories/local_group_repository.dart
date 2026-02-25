import '../../data/data_sources/group_local_datasource.dart';
import '../../data/data_sources/group_remote_datasource.dart';
import '../../data/models/group_model.dart';
import '../../data/models/members_model.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/group_repository.dart';


class GroupRepositoryImpl implements GroupRepository {
  final GroupLocalDataSource local;
  final GroupRemoteDataSource remote;

  GroupRepositoryImpl({required this.local, required this.remote});

  @override
  Future<List<GroupEntity>> getGroups({String? userId}) async {
    final locals = await local.getAllGroups();
    if (userId != null) _syncGroupsWithRemote(userId); // سینک در پس‌زمینه
    return locals.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createGroup(GroupEntity group) async {
    final model = GroupModel.fromEntity(group)..isSynced = false;
    await local.saveGroup(model); // اول ذخیره لوکال

    try {
      final remoteId = await remote.addGroup(model);
      model.firestoreId = remoteId;
      model.isSynced = true;
      await local.saveGroup(model); // آپدیت با ID فایربیس
    } catch (e) {
      print("Offline: Group saved locally.");
    }
  }

  @override
  Future<void> updateGroup(GroupEntity group) async {
    final model = GroupModel.fromEntity(group);
    await local.saveGroup(model);
    // منطق آپدیت ریموت هم اینجا اضافه شود
  }

  @override
  Future<void> archiveGroup(String groupId) async {
    final group = await local.getGroupById(groupId);
    if (group != null) {
      group.isArchived = true;
      await local.saveGroup(group);
      // فراخوانی ریموت برای آرشیو
    }
  }

  @override
  Future<void> deleteGroupLocal(int isarId) async => await local.deleteGroup(isarId);

  // --- مدیریت اعضا ---
  @override
  Future<List<MemberEntity>> getMembers(String groupId) async {
    final models = await local.getMembers(groupId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addMember(String groupId, MemberEntity member) async {
    final model = MemberModel.fromEntity(member);
    await local.saveMember(model);
  }

  @override
  Future<void> updateMember(MemberEntity member) async {
    await local.saveMember(MemberModel.fromEntity(member));
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    await local.removeMember(groupId, userId);
  }

  // تابع کمکی برای همگام‌سازی
  Future<void> _syncGroupsWithRemote(String userId) async {
    try {
      final remotes = await remote.getGroups(userId);
      for (var rModel in remotes) {
        final lModel = await local.getGroupById(rModel.firestoreId);
        if (lModel == null) await local.saveGroup(rModel..isSynced = true);
      }
    } catch (e) {
      print("Sync error: $e");
    }
  }

  @override
  Future<GroupEntity?> getGroupById(String id) async {
    final model = await local.getGroupById(id);
    return model?.toEntity();
  }
}