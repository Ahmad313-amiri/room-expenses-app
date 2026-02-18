import 'package:get/get.dart';
import '../../data/models/group_model.dart';
import '../../data/repository/group_repository_impl.dart';

class GroupsController extends GetxController {
  final GroupRepositoryImpl repository;

  GroupsController(this.repository);

  var groups = <GroupModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    isLoading.value = true;

    // 1️⃣ ابتدا از لوکال دیتا لود کن
    final localGroups = await repository.getLocalGroups();
    groups.value = localGroups;

    // 2️⃣ سپس از ریموت دیتا بگیر
    final remoteGroups = await repository.getRemoteGroups('currentUserId');

    // 3️⃣ سینک لوکال با ریموت
    await repository.syncLocalWithRemote(remoteGroups);

    // 4️⃣ دوباره داده‌های لوکال را بارگذاری کن
    groups.value = await repository.getLocalGroups();

    isLoading.value = false;
  }

  Future<void> addGroup(GroupModel group) async {
    await repository.addGroup(group);
    await fetchGroups();
  }
}
