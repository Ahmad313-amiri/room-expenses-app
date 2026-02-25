import 'package:get/get.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/get_groups.dart';
import '../../domain/usecases/add_member.dart';
import '../../domain/usecases/archive_group.dart';
import '../../domain/usecases/get_members.dart';

class GroupsController extends GetxController {
  // تعریف یوزکیس‌ها
  final GetGroups getGroupsUseCase;
  final CreateGroup createGroupUseCase;
  final AddMember addMemberUseCase;
  final ArchiveGroup archiveGroupUseCase;
  final GetMembers getMembersUseCase;

  GroupsController({
    required this.getGroupsUseCase,
    required this.createGroupUseCase,
    required this.addMemberUseCase,
    required this.archiveGroupUseCase,
    required this.getMembersUseCase,
  });

  // متغیرهای مشاهده‌گر (Observable)
  var groups = <GroupEntity>[].obs;
  var members = <MemberEntity>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroups(); // فراخوانی خودکار هنگام اجرای برنامه
  }

  // دریfetchGroupsافت لیست گروه‌ها
  Future<void> fetchGroups() async {
    isLoading.value = true;
    try {
      final result = await getGroupsUseCase.call();
      // استفاده از assignAll برای جایگزینی امن لیست
      groups.assignAll(result ?? []);
    } catch (e) {
      print("Error fetching groups: $e");
      // Get.snackbar("Error", "Failed to load groups"); // غیرفعال کردن موقت برای جلوگیری از مزاحمت
    } finally {
      isLoading.value = false;
    }
  }

  // ایجاد گروه جدید
  Future<void> createNewGroup(GroupEntity group) async {
    isLoading.value = true;
    try {
      await createGroupUseCase.call(group);
      await fetchGroups(); // بروزرسانی لیست گروه‌ها پس از ساخت
      Get.back(); // بازگشت به صفحه قبل
    } catch (e) {
      Get.snackbar("Error", "Failed to create group");
    } finally {
      isLoading.value = false;
    }
  }

  // آرشیو کردن گروه
  Future<void> archiveSelectedGroup(String groupId) async {
    try {
      await archiveGroupUseCase.call(groupId);
      await fetchGroups(); // بروزرسانی لیست پس از آرشیو
    } catch (e) {
      Get.snackbar("Error", "Failed to archive group");
    }
  }

  // بارگذاری اعضای یک گروه خاص
  Future<void> loadMembers(String groupId) async {
    try {
      isLoading.value = true;
      final result = await getMembersUseCase.call(groupId);
      members.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Could not load members');
    } finally {
      isLoading.value = false;
    }
  }

  // افزودن عضو جدید به گروه
  Future<void> addMemberToGroup(String groupId, MemberEntity member) async {
    try {
      // فراخوانی یوزکیس برای افزودن به دیتابیس
      await addMemberUseCase.call(groupId, member);

      // بروزرسانی لیست اعضا در صورت نیاز
      await loadMembers(groupId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add member');
      rethrow;
    }
  }
}