import '../data_sources/group_local_datasource.dart';
import '../data_sources/remote/group_remote_datasource.dart';
import '../models/group_model.dart';

class GroupRepositoryImpl {
  final GroupLocalDataSource local;
  final GroupRemoteDataSource remote;

  GroupRepositoryImpl(this.local, this.remote);

  /// دریافت داده‌ها (Local-first + Remote sync)
  Future<List<GroupModel>> getGroups({String? userId}) async {
    // 1️⃣ ابتدا داده‌ها از لوکال
    final localGroups = await local.getAllGroups();

    // 2️⃣ اگر userId مشخص است، داده‌های ریموت را هم بگیر
    if (userId != null) {
      final remoteGroups = await remote.getGroups(userId);

      // 3️⃣ سینک لوکال با ریموت
      await syncLocalWithRemote(remoteGroups);

      // 4️⃣ دوباره داده‌های لوکال را بارگذاری کن
      return await local.getAllGroups();
    }

    return localGroups;
  }

  /// اضافه کردن گروه جدید
  Future<GroupModel> addGroup(GroupModel group) async {
    final localGroup = await local.addGroup(group);
    await remote.addGroup(group); // async sync
    return localGroup;
  }

  /// همگام‌سازی لوکال با ریموت
  Future<void> syncLocalWithRemote(List<GroupModel> remoteGroups) async {
    for (var remoteGroup in remoteGroups) {
      final exists = await local.getAllGroups();
      final match = exists.any((g) => g.firestoreId == remoteGroup.firestoreId);
      if (!match) {
        await local.addGroup(remoteGroup);
      }
    }
  }

  /// متدهای کمکی برای GetGroupsController
  Future<List<GroupModel>> getLocalGroups() async => await local.getAllGroups();
  Future<List<GroupModel>> getRemoteGroups(String userId) async => await remote.getGroups(userId);
}
