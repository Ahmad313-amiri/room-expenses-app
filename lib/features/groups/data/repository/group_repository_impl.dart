import '../../domain/entities/group.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../data_sources/group_local_datasource.dart';
import '../data_sources/group_remote_datasource.dart';
import '../models/group_model.dart';
import '../models/members_model.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupLocalDataSource local;
  final GroupRemoteDataSource remote;

  GroupRepositoryImpl({required this.local, required this.remote});

  // --- عملیات‌های مربوط به گروه‌ها ---

  @override
  Future<List<GroupEntity>> getGroups({String? userId}) async {
    // 1. اول لیست را از لوکال (Isar) می‌گیریم تا سرعت بالا باشد
    final localModels = await local.getAllGroups();

    // 2. در پس‌زمینه (بدون معطل کردن کاربر) با سرور سینک می‌کنیم
    if (userId != null) {
      _syncGroupsWithRemote(userId);
    }

    return localModels.map((m) => m.toEntity()).toList();
  }

  @override
  Future<GroupEntity?> getGroupById(String id) async {
    final model = await local.getGroupById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createGroup(GroupEntity group) async {
    // تبدیل Entity به Model برای ذخیره در Isar
    final model = GroupModel.fromEntity(group)..isSynced = false;

    // ذخیره در لوکال (تا کاربر سریع نتیجه را ببیند)
    await local.saveGroup(model);

    try {
      // تلاش برای ذخیره در فایربیس
      final firestoreId = await remote.addGroup(model);

      // اگر موفق بود، ID فایربیس را می‌گیریم و وضعیت را به synced تغییر می‌دهیم
      model.firestoreId = firestoreId;
      model.isSynced = true;
      await local.saveGroup(model);
    } catch (e) {
      // اگر اینترنت نبود، در Isar باقی می‌ماند و بعداً سینک می‌شود
      print("Offline mode: Group saved locally and will sync later.");
    }
  }

  @override
  Future<void> updateGroup(GroupEntity group) async {
    final model = GroupModel.fromEntity(group);
    await local.saveGroup(model);
    // اینجا می‌توانید متد آپدیت ریموت را هم صدا بزنید
  }

  @override
  Future<void> archiveGroup(String groupId) async {
    final group = await local.getGroupById(groupId);
    if (group != null) {
      group.isArchived = true;
      await local.saveGroup(group);
      // ارسال دستور آرشیو به ریموت (در صورت داشتن متد در RemoteDataSource)
    }
  }

  @override
  Future<void> deleteGroupLocal(int isarId) async {
    await local.deleteGroup(isarId);
  }

  // --- عملیات‌های مربوط به اعضا (Members) ---

  @override
  Future<List<MemberEntity>> getMembers(String groupId) async {
    final models = await local.getMembers(groupId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addMember(String groupId, MemberEntity member) async {
    final model = MemberModel.fromEntity(member);
    await local.saveMember(model);
    // منطق سینک ریموت برای عضو جدید را اینجا اضافه کنید
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    await local.removeMember(groupId, userId);
    // حذف از ریموت
  }

  // --- منطق همگام‌سازی (Private Sync Logic) ---

  Future<void> _syncGroupsWithRemote(String userId) async {
    try {
      final remoteGroups = await remote.getGroups(userId);
      for (var rModel in remoteGroups) {
        final lModel = await local.getGroupById(rModel.firestoreId);

        if (lModel == null) {
          // اگر گروه در گوشی نیست، آن را ذخیره کن
          rModel.isSynced = true;
          await local.saveGroup(rModel);
        } else {
          // اگر هست، می‌توانید چک کنید اگر updatedAt ریموت جدیدتر است، آپدیت کنید
        }
      }
    } catch (e) {
      print("Sync Background Error: $e");
    }
  }
}