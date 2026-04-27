import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';

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

  // --- GroupDetailScreen ---
  final currentGroup = Rxn<GroupEntity>();
  final groupImageFile = Rxn<File>();
  final isLoadingImage = false.obs;
  final balanceText = '0.0'.obs;

  Timer? _debounce;
  bool _isDisposed = false;
  StreamSubscription<QuerySnapshot>? _expenseSubscription;

  final Connectivity _connectivity = Connectivity();
  final RxBool _isOnline = true.obs;
  bool get isOnline => _isOnline.value;

  @override
  void onInit() {
    super.onInit();
    _isDisposed = false;
    _monitorConnectivity();
    fetchGroups();
  }

  @override
  void onClose() {
    _isDisposed = true;
    _debounce?.cancel();
    _expenseSubscription?.cancel();
    super.onClose();
  }

  void _monitorConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) {
      _isOnline.value = result != ConnectivityResult.none;
      if (_isOnline.value) {
        fetchGroups();
        if (currentGroup.value != null)
          loadGroupAndMembers(currentGroup.value!.id);
      }
    });
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

  Future<void> fetchGroups({
    bool forceRefresh = false,
    bool initialLoad = false,
  }) async {
    try {
      isLoading.value = true;
      final authRepo = Get.find<AuthenticationRepository>();
      final uid = authRepo.firebaseUser.value?.uid;
      if (uid == null) {
        print("User not logged in");
        isLoading.value = false;
        return;
      }
      if (!_isOnline.value && !forceRefresh) {
        if (!initialLoad) {
          _showErrorSnackbar(
            "Offline",
            "You are offline. Showing cached data.",
          );
        }
        return;
      }
      final remoteGroups = await getGroupsUseCase
          .call(uid)
          .timeout(Duration(seconds: 15));
      final models = remoteGroups
          .map((e) => e is GroupModel ? e : GroupModel.fromEntity(e))
          .toList();
      groups.assignAll(models);
      allGroups.assignAll(models);
    } catch (e) {
      print("Fetch groups error: $e");
      if (!initialLoad) {
        if (e is TimeoutException) {
          _showErrorSnackbar(
            "Timeout",
            "Network took too long. Please try again.",
          );
        } else {
          _showErrorSnackbar(
            "Network Error",
            "Failed to load groups. Check your internet.",
          );
        }
      }
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

  Future<String?> createNewGroup(GroupEntity group, {File? imageFile}) async {
    try {
      isLoading.value = true;
      if (group.name.trim().isEmpty) throw Exception("Group name required");
      if (!_isOnline.value) throw Exception("No internet connection");
      final remoteId = await createGroupUseCase.call(group);
      if (imageFile != null) {
        final imageUrl = await uploadGroupImage(imageFile, remoteId);
        if (imageUrl != null) {
          final updatedGroup = (group as GroupModel).copyWith(
            coverImageUrl: imageUrl,
          );
          await updateGroupDetails(updatedGroup);
        }
      }
      await fetchGroups();
      _showSuccessSnackbar("Group created successfully");
      return remoteId;
    } catch (e) {
      print(e);
      _showErrorSnackbar("Creation Failed", e.toString());
      return null;
    } finally {
      isLoading.value = false;
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
      if (!_isOnline.value) throw Exception("No internet connection");
      await deleteGroupUseCase.call(groupId);
      groups.removeWhere((g) => g.id == groupId);
      allGroups.removeWhere((g) => g.id == groupId);
      if (currentGroup.value?.id == groupId) currentGroup.value = null;
      _showSuccessSnackbar("Group deleted");
      Get.offAll(() => const HomeScreen());
      final homeController = Get.find<HomeController>();
      homeController.changeTab(1);
    } catch (e) {
      _showErrorSnackbar("Delete Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshGroups() async {
    await fetchGroups(forceRefresh: true, initialLoad: false);
  }

  Future<void> refreshGroupDetail(String groupId) async {
    await loadGroupAndMembers(groupId, forceRefresh: true);
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

  Future<void> addMemberToGroup(
    String groupId,
    String identifier,
    String name,
  ) async {
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("➕ ADD MEMBER FLOW START");
    debugPrint("groupId: $groupId");
    debugPrint("identifier: $identifier");
    debugPrint("name: $name");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━");

    try {
      isLoading.value = true;
      if (groupId.isEmpty || identifier.isEmpty || name.isEmpty) {
        throw Exception("All fields are required");
      }
      if (members.isEmpty) {
        await loadMembers(groupId);
      }
      final value = identifier.trim().toLowerCase();
      final userData = await remoteDataSource.findUserByEmail(value);
      final resolvedUserId = userData?['uid'] ?? value;
      final existingMember = members.firstWhereOrNull(
        (m) => m.userId == resolvedUserId,
      );
      if (existingMember != null) {
        if (existingMember.invitationStatus == 'pending') {
          _showErrorSnackbar("Already invited", "Invitation is still pending");
        } else {
          _showErrorSnackbar(
            "Already member",
            "User already exists in this group",
          );
        }
        return;
      }
      final newMember = MemberEntity(
        groupId: groupId,
        userId: resolvedUserId,
        name: userData?['name'] ?? name,
        role: userData != null ? 'member' : 'guest',
        invitationStatus: 'pending',
        joinedAt: DateTime.now(),
        invitedBy: currentUserId,
        isAppUser: userData != null,
        firestoreId: '',
      );
      debugPrint("📨 Creating PENDING invitation...");
      await addMemberUseCase.call(groupId, newMember);
      await loadMembers(groupId);
      _showSuccessSnackbar("Invitation sent successfully");
    } catch (e, stack) {
      debugPrint(" ERROR: $e");
      debugPrint("STACK: $stack");
      _showErrorSnackbar("Failed to add member", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty || userId.isEmpty)
        throw Exception("Invalid group or user ID");
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

  Future<void> addSelectedMembers(
    List<Map<String, dynamic>> selectedUsers,
  ) async {
    try {
      final currentGroupId = groupId.value;
      if (currentGroupId.isEmpty) {
        _showErrorSnackbar("Error", "Group not found");
        return;
      }
      isLoading.value = true;
      await loadMembers(currentGroupId);
      int addedCount = 0;
      int skippedCount = 0;
      for (final user in selectedUsers) {
        final uid = user['uid']?.toString().trim() ?? '';
        final name = user['name']?.toString().trim() ?? 'Unknown';
        final phone = _normalizePhone(user['phone']?.toString() ?? '');
        final email = user['email']?.toString().trim().toLowerCase() ?? '';
        final alreadyExists = members.any((m) {
          final memberId = m.userId.toString().trim();
          final memberName = m.name.toString().trim();
          final memberPhone = _normalizePhone(m.userId);
          final memberEmail = m.userId.toString().trim().toLowerCase();
          return (uid.isNotEmpty && memberId == uid) ||
              (phone.isNotEmpty && memberPhone == phone) ||
              (email.isNotEmpty && memberEmail == email) ||
              memberName == name;
        });
        if (alreadyExists) {
          skippedCount++;
          continue;
        }
        final newMember = MemberEntity(
          groupId: currentGroupId,
          userId: uid.isNotEmpty ? uid : phone,
          name: name,
          role: 'member',
          invitationStatus: 'accepted',
          joinedAt: DateTime.now(),
          invitedBy: currentUserId,
          isAppUser: user['isAppUser'] ?? false,
          firestoreId: '',
        );
        await addMemberUseCase.call(currentGroupId, newMember);
        addedCount++;
      }
      await loadMembers(currentGroupId);
      Get.back();
      _showSuccessSnackbar(
        "$addedCount added, $skippedCount duplicate skipped",
      );
    } catch (e) {
      _showErrorSnackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String _normalizePhone(dynamic value) {
    String phone = value.toString();
    phone = phone.replaceAll(" ", "");
    phone = phone.replaceAll("-", "");
    phone = phone.replaceAll("(", "");
    phone = phone.replaceAll(")", "");
    if (phone.startsWith("+93")) {
      phone = "0${phone.substring(3)}";
    }
    return phone.trim();
  }

  Future<void> updateMemberStatus(
    String groupId,
    String userId,
    String status,
  ) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty || userId.isEmpty || status.isEmpty) {
        throw Exception("Invalid parameters");
      }
      final memberIndex = members.indexWhere(
        (m) => m.userId == userId && m.groupId == groupId,
      );
      if (memberIndex == -1) throw Exception("Member not found");
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

  Future<void> acceptGroupInvitation({
    required String groupId,
    required String userId,
  }) async {
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
      final status = await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );
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

  Future<void> loadGroupAndMembers(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    if (!_isOnline.value && !forceRefresh) {
      _showErrorSnackbar("Offline", "Cannot refresh. Connect to internet.");
      return;
    }
    final group = allGroups.firstWhereOrNull((g) => g.id == groupId);
    if (group != null) currentGroup.value = group;
    await loadMembers(groupId);
    watchGroupBalance(groupId);
  }

  void showEditGroupNameDialog(BuildContext context, GroupEntity group) {
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

  // ------------------------------------------------------------
  // DELETE GROUP DIALOG - FULLY FIXED
  // ------------------------------------------------------------
  void showDeleteGroupDialog(BuildContext context, String groupId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Group"),
        content: const Text(
          "Are you sure you want to delete this group? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Future.delayed(
                Duration.zero,
              ); // یا await WidgetsBinding.instance.endOfFrame
              await deleteSelectedGroup(groupId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // REMOVE MEMBER DIALOG - FULLY FIXED
  // ------------------------------------------------------------
  void showRemoveMemberDialog(
    BuildContext context,
    String groupId,
    MemberEntity member,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Member"),
        content: Text("Remove ${member.name} from the group?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await Future.delayed(Duration.zero);
              await removeMemberFromGroup(groupId, member.userId);
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  void watchGroupBalance(String groupId) {
    _expenseSubscription?.cancel();
    _expenseSubscription = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .snapshots()
        .listen((snapshot) {
          double total = 0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            total += (data['amount'] ?? 0).toDouble();
          }
          balanceText.value = total.toStringAsFixed(0);
        });
  }

  void goToAddMembers() {
    final groupId = currentGroup.value?.id;
    if (groupId == null || groupId.isEmpty) {
      _showErrorSnackbar("Error", "Group ID is null");
      return;
    }
    debugPrint("🚀 Navigating to SelectMembersScreen with groupId: $groupId");
    Get.toNamed('/select-members', arguments: {'groupId': groupId});
  }

  // FIXED: Upload image and update currentGroup & allGroups
  Future<String?> uploadGroupImage(File imageFile, String groupId) async {
    try {
      if (!_isOnline.value) throw Exception("No internet connection");
      final ref = FirebaseStorage.instance.ref().child(
        'group_images/$groupId.jpg',
      );
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      await remoteDataSource.updateGroupCover(groupId, url);

      // Update currentGroup if it belongs to this group
      if (currentGroup.value?.id == groupId) {
        final updatedGroup = (currentGroup.value as GroupModel).copyWith(
          coverImageUrl: url,
        );
        currentGroup.value = updatedGroup;
        // Also update in allGroups
        final index = allGroups.indexWhere((g) => g.id == groupId);
        if (index != -1) {
          allGroups[index] = updatedGroup as GroupModel;
        }
        final groupIndex = groups.indexWhere((g) => g.id == groupId);
        if (groupIndex != -1) {
          groups[groupIndex] = updatedGroup;
        }
      }
      return url;
    } catch (e) {
      print("Upload error: $e");
      _showErrorSnackbar("Upload Failed", e.toString());
      return null;
    }
  }

  void showPickerMenu(BuildContext context, GroupEntity group) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Take Photo"),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (picked != null) {
                  groupImageFile.value = File(picked.path);
                  await uploadGroupImage(File(picked.path), group.id);
                  groupImageFile.value = null; // clear temporary file
                  await loadGroupAndMembers(group.id, forceRefresh: true);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  groupImageFile.value = File(picked.path);
                  await uploadGroupImage(File(picked.path), group.id);
                  groupImageFile.value = null;
                  await loadGroupAndMembers(group.id, forceRefresh: true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SNACKBAR HELPERS
  // ------------------------------------------------------------
  void _showSuccessSnackbar(String message) {
    if (_isDisposed) return;
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    if (_isDisposed) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
