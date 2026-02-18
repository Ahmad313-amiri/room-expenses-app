import 'package:isar/isar.dart';
import '../models/group_model.dart';


class GroupLocalDataSource {
  final Isar isar;

  GroupLocalDataSource(this.isar);

  Future<List<GroupModel>> getAllGroups() async {
    return await isar.groupModels.where().findAll();
  }

  Future<GroupModel> addGroup(GroupModel group) async {
    await isar.writeTxn(() async {
      await isar.groupModels.put(group);
    });
    return group;
  }

  Future<void> updateGroup(GroupModel group) async {
    await isar.writeTxn(() async {
      await isar.groupModels.put(group);
    });
  }

  Future<void> deleteGroup(int id) async {
    await isar.writeTxn(() async {
      await isar.groupModels.delete(id);
    });
  }
}
