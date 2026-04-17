import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import '../../../auth/data/repository/authentication_repository.dart';
import '../../../home/presentation/pages/controller/home_page_controller.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../data/data_sources/group_remote_datasource.dart';
import '../../data/models/group_model.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/get_groups.dart';
import '../../domain/usecases/add_member.dart';
import '../../domain/usecases/delete_group.dart';
import '../../domain/usecases/get_members.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/update_member_status.dart';
import 'dart:io';

/*class GroupsController extends GetxController {
  final SearchUsersUseCase searchUsersUseCase;
  final GetGroups getGroupsUseCase;
  final CreateGroup createGroupUseCase;
  final AddMember addMemberUseCase;
  final ArchiveGroup archiveGroupUseCase;
  final GetMembers getMembersUseCase;
  final GroupRemoteDataSource remoteDataSource;
  final UpdateMemberStatus updateMemberStatusUseCase;

  GroupsController({
    required this.searchUsersUseCase,
    required this.getGroupsUseCase,
    required this.createGroupUseCase,
    required this.addMemberUseCase,
    required this.archiveGroupUseCase,
    required this.getMembersUseCase,
    required this.remoteDataSource,
    required this.updateMemberStatusUseCase,
  });

  var groups = <GroupEntity>[].obs;
  var members = <MemberEntity>[].obs;
  var isLoading = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var isSearching = false.obs;
  var searchError = ''.obs;
  var contacts = <Contact>[].obs;
  var allGroups = <GroupModel>[].obs;

  void filterGroups(String query) {
    if (query.isEmpty) {
      groups.value = allGroups;
    } else {
      groups.value = allGroups
          .where((g) => g.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Timer? _debounce;
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;
    fetchGroups();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;


      final authRepo = Get.find<AuthenticationRepository>();
      final uid = authRepo.firebaseUser.value?.uid;

      if (uid == null) {
        print("❌ User is null");
        return;
      }

      final remoteGroups = await getGroupsUseCase.call(uid);

      print("🔥 fetchGroups called");
      print("🔥 groups from server: $remoteGroups");

      groups.assignAll(remoteGroups);
      allGroups.assignAll(remoteGroups as Iterable<GroupModel>);
    } catch (e) {
      print("Error fetching groups: $e");
      _showErrorSnackbar("Failed to load groups", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createNewGroup(GroupEntity group) async {
    try {
      isLoading.value = true;
      if (group.name.trim().isEmpty) throw Exception("Group name cannot be empty");
      final remoteId = await createGroupUseCase.call(group);
      await fetchGroups();
      _showSuccessSnackbar("Group created successfully");
      return remoteId;
    } catch (e) {
      print("Create Group Error: $e");
      _showErrorSnackbar("Failed to create group", e.toString());
      return null;
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> updateGroupDetails(GroupEntity group) async {
    try {
      isLoading.value = true;
      if (group.id.isEmpty) throw Exception("Invalid group ID");
      await remoteDataSource.updateGroup(GroupModel.fromEntity(group));
      await fetchGroups();
      _showSuccessSnackbar("Group updated successfully");
    } catch (e) {
      print("Update Group Error: $e");
      _showErrorSnackbar("Failed to update group", e.toString());
      rethrow;
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> archiveSelectedGroup(String groupId) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty) throw Exception("Invalid group ID");
      await archiveGroupUseCase.call(groupId);
      groups.removeWhere((g) => g.id == groupId);
      _showSuccessSnackbar("Group archived successfully");
    } catch (e) {
      print("Archive Group Error: $e");
      _showErrorSnackbar("Failed to archive group", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> loadMembers(String groupId) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty) throw Exception("Invalid group ID");
      final remoteMembers = await getMembersUseCase.call(groupId) ?? [];
      final acceptedMembers = remoteMembers.where((m) => m.invitationStatus == 'accepted').toList();
      if (!_isDisposed) members.assignAll(acceptedMembers);
    } catch (e) {
      print("Error loading members: $e");
      _showErrorSnackbar("Failed to load members", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  /// Adds a member to the group, checking for duplicates and user existence.
  Future<void> addMemberToGroup(String groupId, String identifier, String name) async {
    try {
      if (groupId.isEmpty || identifier.isEmpty || name.isEmpty) {
        throw Exception("All fields are required");
      }
      isLoading.value = true;
      final userData = await remoteDataSource.findUserByEmail(identifier.trim().toLowerCase());

      // Check for duplicate user
      if (members.any((m) => m.userId == (userData?['uid'] ?? identifier))) {
        _showErrorSnackbar("Duplicate member", "This user is already added to the group.");
        return;
      }

      final newMember = MemberEntity(
        groupId: groupId,
        userId: userData?['uid'] ?? identifier,
        name: userData?['name'] ?? name,
        role: userData != null ? 'member' : 'guest',
        joinedAt: DateTime.now(),
        invitationStatus: userData != null ? 'accepted' : 'pending',
        invitedBy: null,
        isAppUser: userData != null,
        firestoreId: '',
      );
      await addMemberUseCase.call(groupId, newMember);
      await loadMembers(groupId);
      _showSuccessSnackbar("Member added successfully");
    } catch (e) {
      _showErrorSnackbar("Failed to add member", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty || userId.isEmpty) throw Exception("Invalid group or user ID");
      await remoteDataSource.removeMember(groupId, userId);
      members.removeWhere((m) => m.userId == userId);
      _showSuccessSnackbar("Member removed successfully");
    } catch (e) {
      print("Error removing member: $e");
      _showErrorSnackbar("Failed to remove member", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> updateMemberStatus(String groupId, String userId, String status) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty || userId.isEmpty || status.isEmpty) {
        throw Exception("Invalid parameters");
      }
      final memberIndex = members.indexWhere((m) => m.userId == userId && m.groupId == groupId);
      if (memberIndex == -1) throw Exception("Member not found");
      await updateMemberStatusUseCase.call(groupId, userId, status);
      final member = members[memberIndex];
      final updatedMember = MemberEntity(
         groupId: member.groupId,
        userId: member.userId,
        name: member.name,
        role: member.role,
        joinedAt: member.joinedAt,
        invitationStatus: status,
        invitedBy: member.invitedBy,
        isAppUser: member.isAppUser,
        firestoreId: '',
      );
      members[memberIndex] = updatedMember;
      _showSuccessSnackbar("Status updated to: $status");
    } catch (e) {
      print("Error updating member status: $e");
      _showErrorSnackbar("Failed to update status", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> acceptGroupInvitation({required String groupId, required String userId}) async {
    try {
      await updateMemberStatus(groupId, userId, 'accepted');
    } catch (e) {
      _showErrorSnackbar("Failed to accept invitation", e.toString());
    }
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => searchUsers(query));
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().length < 2) {
      searchResults.clear();
      return;
    }
    try {
      isSearching.value = true;
      searchError.value = '';
      final results = await searchUsersUseCase.call(query.trim());
      if (!_isDisposed) searchResults.assignAll(results);
    } catch (e) {
      print("Search Error: $e");
      searchError.value = "Search failed: ${e.toString()}";
      searchResults.clear();
      if (e.toString().contains("timeout")) {
        _showErrorSnackbar("Search timed out", "Please try again");
      } else if (e.toString().contains("internet")) {
        _showErrorSnackbar("No internet", "Check your connection");
      }
    } finally {
      if (!_isDisposed) isSearching.value = false;
    }
  }

  Future<void> fetchPhoneContacts() async {
    try {
      final status = await FlutterContacts.permissions.request(PermissionType.readWrite);
      if (status != PermissionStatus.granted) {
        _showErrorSnackbar("Permission denied", "Cannot access contacts");
        return;
      }
      final fetchedContacts = await FlutterContacts.getAll();
      if (!_isDisposed) contacts.assignAll(fetchedContacts);
    } catch (e) {
      print("Error fetching contacts: $e");
      _showErrorSnackbar("Failed to load contacts", e.toString());
    }
  }

  void _showSuccessSnackbar(String message) {
    if (_isDisposed) return;
    Get.snackbar('Success', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2));
  }

  void _showErrorSnackbar(String title, String message) {
    if (_isDisposed) return;
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
  }
}

 */




class GroupsController extends GetxController {
  final SearchUsersUseCase searchUsersUseCase;
  final GetGroups getGroupsUseCase;
  final CreateGroup createGroupUseCase;
  final AddMember addMemberUseCase;
  final DeleteGroup deleteGroupUseCase;
  final GetMembers getMembersUseCase;
  final GroupRemoteDataSource remoteDataSource;
  final UpdateMemberStatus updateMemberStatusUseCase;

  GroupsController({
    required this.searchUsersUseCase,
    required this.getGroupsUseCase,
    required this.createGroupUseCase,
    required this.addMemberUseCase,
    required this.deleteGroupUseCase,
    required this.getMembersUseCase,
    required this.remoteDataSource,
    required this.updateMemberStatusUseCase,
  });

  var groups = <GroupEntity>[].obs;
  var members = <MemberEntity>[].obs;
  var isLoading = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var isSearching = false.obs;
  var searchError = ''.obs;
  var contacts = <Contact>[].obs;
  var allGroups = <GroupModel>[].obs;
  var groupId = ''.obs;

  // --- NEW FIELDS FOR GroupDetailScreen ---
  final currentGroup = Rxn<GroupEntity>();
  final groupImageFile = Rxn<File>();
  final isLoadingImage = false.obs;
  final balanceText = '0.0'.obs;

  Timer? _debounce;
  bool _isDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;
    fetchGroups();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.onClose();
  }
  String? get currentUserId {
    final authRepo = Get.find<AuthenticationRepository>();
    return authRepo.firebaseUser.value?.uid;
  }
  bool canRemoveMember(MemberEntity member) {
    final currentUser = members.firstWhereOrNull(
          (m) => m.userId == currentUserId,
    );

    if (currentUser == null) return false;
    final isAdmin = currentUser.role == 'admin';
    final isSelf = member.userId == currentUserId;

    return isAdmin && !isSelf;
  }
  // ------------------------------------------------------------
  // GROUP FETCHING & FILTERING
  // ------------------------------------------------------------
  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;
      final authRepo = Get.find<AuthenticationRepository>();
      final uid = authRepo.firebaseUser.value?.uid;
      if (uid == null) {
        print("❌ User is null");
        isLoading.value = false;
        return;
      }

      final remoteGroups = await getGroupsUseCase.call(uid);
      print("🔥 fetchGroups called - count: ${remoteGroups.length}");

      // Safe type conversion: assume remoteGroups are GroupEntity, map to GroupModel if needed
      final List<GroupModel> models = remoteGroups.map((e) {
        if (e is GroupModel) return e;
        return GroupModel.fromEntity(e);
      }).toList();

      groups.assignAll(models);
      allGroups.assignAll(models);
    } catch (e) {
      print("Error fetching groups: $e");
      _showErrorSnackbar("Failed to load groups", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void filterGroups(String query) {
    if (query.isEmpty) {
      groups.value = allGroups;
    } else {
      groups.value = allGroups
          .where((g) => g.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // ------------------------------------------------------------
  // GROUP CRUD
  // ------------------------------------------------------------
  Future<String?> createNewGroup(GroupEntity group) async {
    try {
      isLoading.value = true;
      if (group.name.trim().isEmpty) throw Exception("Group name cannot be empty");
      final remoteId = await createGroupUseCase.call(group);
      await fetchGroups();
      _showSuccessSnackbar("Group created successfully");
      return remoteId;
    } catch (e) {
      print("Create Group Error: $e");
      _showErrorSnackbar("Failed to create group", e.toString());
      return null;
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> updateGroupDetails(GroupEntity group) async {
    try {
      isLoading.value = true;
      if (group.id.isEmpty) throw Exception("Invalid group ID");
      await remoteDataSource.updateGroup(GroupModel.fromEntity(group));
      await fetchGroups();
      // Update currentGroup if it's the same group
      if (currentGroup.value?.id == group.id) {
        currentGroup.value = group;
      }
      _showSuccessSnackbar("Group updated successfully");
    } catch (e) {
      print("Update Group Error: $e");
      _showErrorSnackbar("Failed to update group", e.toString());
      rethrow;
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> deleteSelectedGroup(String groupId) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty) throw Exception("Invalid group ID");
      await deleteGroupUseCase.call(groupId);
      groups.removeWhere((g) => g.id == groupId);
      allGroups.removeWhere((g) => g.id == groupId);
      currentGroup.value = null;
      _showSuccessSnackbar("Group deleted successfully");
    } catch (e) {
      print("Delete Group Error: $e");
      _showErrorSnackbar("Failed to delete  group", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // MEMBERS MANAGEMENT
  // ------------------------------------------------------------
  Future<void> loadMembers(String groupId) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty) throw Exception("Invalid group ID");
      final remoteMembers = await getMembersUseCase.call(groupId) ?? [];
      members.assignAll(remoteMembers);
      // if (!_isDisposed) members.assignAll(acceptedMembers);
      print("RAW MEMBERS COUNT: ${remoteMembers.length}");
      for (var m in remoteMembers) {
        print("MEMBER: ${m.userId} | ${m.name} | ${m.invitationStatus}");
      }
    } catch (e) {
      print("Error loading members: $e");
      _showErrorSnackbar("Failed to load members", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> addMemberToGroup(String groupId, String identifier, String name) async {
    try {
      if (groupId.isEmpty || identifier.isEmpty || name.isEmpty) {
        throw Exception("All fields are required");
      }
      isLoading.value = true;

      // Ensure members are loaded before checking duplicates
      if (members.isEmpty) {
        await loadMembers(groupId);
      }

      final userData = await remoteDataSource.findUserByEmail(identifier.trim().toLowerCase());

      if (members.any((m) => m.userId == (userData?['uid'] ?? identifier))) {
        _showErrorSnackbar("Duplicate member", "This user is already added to the group.");
        return;
      }

      final newMember = MemberEntity(
        groupId: groupId,
        userId: userData?['uid'] ?? identifier,
        name: userData?['name'] ?? name,
        role: userData != null ? 'member' : 'guest',
        joinedAt: DateTime.now(),
        invitationStatus: userData != null ? 'accepted' : 'pending',
        invitedBy: null,
        isAppUser: userData != null,
        firestoreId: '', // will be set by backend
      );
      await addMemberUseCase.call(groupId, newMember);
      await loadMembers(groupId);
      _showSuccessSnackbar("Member added successfully");
    } catch (e) {
      _showErrorSnackbar("Failed to add member", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty || userId.isEmpty) throw Exception("Invalid group or user ID");
      await remoteDataSource.removeMember(groupId, userId);
      members.removeWhere((m) => m.userId == userId);
      _showSuccessSnackbar("Member removed successfully");
    } catch (e) {
      print("Error removing member: $e");
      _showErrorSnackbar("Failed to remove member", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> updateMemberStatus(String groupId, String userId, String status) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty || userId.isEmpty || status.isEmpty) {
        throw Exception("Invalid parameters");
      }
      final memberIndex = members.indexWhere((m) => m.userId == userId && m.groupId == groupId);
      if (memberIndex == -1) throw Exception("Member not found");

      // Update in remote
      // final updatedDoc = await updateMemberStatusUseCase.call(groupId, userId, status);

      // Refresh member from remote to get correct firestoreId
      final member = members[memberIndex];
      final updatedMember = MemberEntity(
        groupId: member.groupId,
        userId: member.userId,
        name: member.name,
        role: member.role,
        joinedAt: member.joinedAt,
        invitationStatus: status,
        invitedBy: member.invitedBy,
        isAppUser: member.isAppUser,
        firestoreId: member.firestoreId,
      );
      members[memberIndex] = updatedMember;
      _showSuccessSnackbar("Status updated to: $status");
    } catch (e) {
      print("Error updating member status: $e");
      _showErrorSnackbar("Failed to update status", e.toString());
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  Future<void> acceptGroupInvitation({required String groupId, required String userId}) async {
    try {
      await updateMemberStatus(groupId, userId, 'accepted');
    } catch (e) {
      _showErrorSnackbar("Failed to accept invitation", e.toString());
    }
  }

  // ------------------------------------------------------------
  // USER SEARCH
  // ------------------------------------------------------------
  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!_isDisposed) searchUsers(query);
    });
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().length < 2) {
      searchResults.clear();
      return;
    }
    try {
      isSearching.value = true;
      searchError.value = '';
      final results = await searchUsersUseCase.call(query.trim());
      if (!_isDisposed) searchResults.assignAll(results);
    } catch (e) {
      print("Search Error: $e");
      if (!_isDisposed) {
        searchError.value = "Search failed: ${e.toString()}";
        searchResults.clear();
      }
      if (e.toString().contains("timeout")) {
        _showErrorSnackbar("Search timed out", "Please try again");
      } else if (e.toString().contains("internet")) {
        _showErrorSnackbar("No internet", "Check your connection");
      }
    } finally {
      if (!_isDisposed) isSearching.value = false;
    }
  }

  Future<void> fetchPhoneContacts() async {
    try {
      final status = await FlutterContacts.permissions.request(PermissionType.readWrite);
      if (status != PermissionStatus.granted) {
        _showErrorSnackbar("Permission denied", "Cannot access contacts");
        return;
      }
      final fetchedContacts = await FlutterContacts.getAll();
      if (!_isDisposed) contacts.assignAll(fetchedContacts);
    } catch (e) {
      print("Error fetching contacts: $e");
      _showErrorSnackbar("Failed to load contacts", e.toString());
    }
  }

  // ------------------------------------------------------------
  // NEW METHODS FOR GroupDetailScreen
  // ------------------------------------------------------------
  Future<void> loadGroupAndMembers(String groupId) async {
    // Find group from allGroups or fetch
    final group = allGroups.firstWhereOrNull((g) => g.id == groupId);
    if (group != null) {
      currentGroup.value = group;
    } else {
      // Optionally fetch single group if needed
    }
    await loadMembers(groupId);
    balanceText.value = '0.0';
  }

  void showEditGroupNameDialog(BuildContext context, GroupEntity group) {
    // Implement dialog logic (keep UI as per Figma)
    // Example: show dialog with TextField and update on confirm
    final controller = TextEditingController(text: group.name);
    Get.defaultDialog(
      title: "Edit Group Name",
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Enter new name"),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          final newName = controller.text.trim();
          if (newName.isNotEmpty && newName != group.name) {
            final updatedGroup = (group as GroupModel).copyWith(name: newName);
            await updateGroupDetails(updatedGroup);
          }
          Get.back();
        },
        child: const Text("Save"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }

  void showDeleteGroupDialog(BuildContext context, String groupId) {
    Get.defaultDialog(
      title: "Delete Group",
      middleText: "Are you sure you want to delete this group?",
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          await deleteSelectedGroup(groupId);
          Get.back();
          Get.offAll(() => const HomeScreen());
          final homeController = Get.find<HomeController>();
          homeController.changeTab(1);
        },
        child: const Text("Delete"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }

  void showPickerMenu(BuildContext context, GroupEntity group) {
    // Placeholder for image picker logic
    // Implement using ImagePicker and update groupImageFile
  }

  void showRemoveMemberDialog(BuildContext context, String groupId, MemberEntity member) {
    Get.defaultDialog(
      title: "Remove Member",
      middleText: "Remove ${member.name} from the group?",
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          await removeMemberFromGroup(groupId, member.userId);
          Get.back();
        },
        child: const Text("Remove"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }

  void goToAddMembers() {
    // Navigate to add members screen (keep UI unchanged)
    Get.toNamed('/add-members', arguments: currentGroup.value?.id);
  }

  // ------------------------------------------------------------
  // SNACKBAR HELPERS
  // ------------------------------------------------------------
  void _showSuccessSnackbar(String message) {
    if (_isDisposed) return;
    Get.snackbar('Success', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2));
  }

  void _showErrorSnackbar(String title, String message) {
    if (_isDisposed) return;
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
  }
}