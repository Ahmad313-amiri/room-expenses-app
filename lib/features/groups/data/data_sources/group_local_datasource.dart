import 'package:isar/isar.dart';
import '../models/group_model.dart';
import '../models/members_model.dart';

class GroupLocalDataSource {
  final Isar isar;
  GroupLocalDataSource(this.isar);

  // --- گروه‌ها ---
  Future<List<GroupModel>> getAllGroups() async => await isar.groupModels.where().findAll();

  Future<GroupModel?> getGroupById(String firestoreId) async {
    return await isar.groupModels.filter().firestoreIdEqualTo(firestoreId).findFirst();
  }

  Future<void> saveGroup(GroupModel group) async {
    await isar.writeTxn(() => isar.groupModels.put(group));
  }

  Future<void> deleteGroup(int id) async {
    await isar.writeTxn(() => isar.groupModels.delete(id));
  }

  // --- اعضا ---
  Future<List<MemberModel>> getMembers(String groupId) async {
    return await isar.memberModels.filter().groupIdEqualTo(groupId).findAll();
  }

  Future<void> saveMember(MemberModel member) async {
    await isar.writeTxn(() => isar.memberModels.put(member));
  }

  Future<void> removeMember(String groupId, String userId) async {
    final member = await isar.memberModels.filter()
        .groupIdEqualTo(groupId)
        .and()
        .userIdEqualTo(userId)
        .findFirst();
    if (member != null) {
      await isar.writeTxn(() => isar.memberModels.delete(member.id));
    }
  }
}