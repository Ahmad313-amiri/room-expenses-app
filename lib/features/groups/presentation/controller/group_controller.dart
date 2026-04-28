import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../../core/util/net_work.dart';
import '../../../auth/data/repository/authentication_repository.dart';
import '../../data/data_sources/group_remote_datasource.dart';
import '../../data/models/group_model.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/usecases/add_member.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/delete_group.dart';
import '../../domain/usecases/get_groups.dart';
import '../../domain/usecases/get_members.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/update_member_status.dart';
import '../widgets/contact_model.dart' hide Contact;

class GroupsController extends GetxController {
  // Dependencies
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

  // Reactive state
  var groups = <GroupEntity>[].obs;
  var allGroups = <GroupModel>[].obs;
  var members = <MemberEntity>[].obs;
  var isLoading = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var isSearching = false.obs;
  var searchError = ''.obs;
  var contacts = <Contact>[].obs;

  // Group detail screen state
  final currentGroup = Rxn<GroupEntity>();
  final groupImageFile = Rxn<File>();
  final isLoadingImage = false.obs;
  final balanceText = '0.0'.obs;

  // Misc
  Timer? _debounce;
  StreamSubscription<QuerySnapshot>? _expenseSubscription;
  final NetworkService _networkService = Get.find<NetworkService>();

  String? get currentUserId {
    final authRepo = Get.find<AuthenticationRepository>();
    return authRepo.firebaseUser.value?.uid;
  }

  // ============================================================
  // Lifecycle
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _expenseSubscription?.cancel();
    super.onClose();
  }


  // ==========  getter groupId ==========
  String get groupId => currentGroup.value?.id ?? '';



  // ============================================================
  // Group fetching
  // ============================================================
  Future<void> fetchGroups({bool forceRefresh = false, bool initialLoad = false}) async {
    if (!_networkService.isOnline && !forceRefresh) {
      if (!initialLoad) {
        ErrorHandler.showInfo('Offline', 'Showing cached data. Connect to refresh.');
      }
      return;
    }
    try {
      isLoading.value = true;
      final uid = currentUserId;
      if (uid == null) {
        AppLogger.w('fetchGroups: User not logged in');
        return;
      }
      final remoteGroups = await getGroupsUseCase(uid).timeout(const Duration(seconds: 15));
      final models = remoteGroups.map((e) => e is GroupModel ? e : GroupModel.fromEntity(e)).toList();
      groups.assignAll(models);
      allGroups.assignAll(models);
      AppLogger.i('Fetched ${models.length} groups');
    } catch (e, stack) {
      AppLogger.e('fetchGroups error', e, stack);
      if (!initialLoad) {
        ErrorHandler.handleError('Network Error', ErrorHandler.getUserFriendlyException(e));
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterGroups(String query) {
    if (query.isEmpty) {
      groups.value = allGroups;
    } else {
      groups.value = allGroups.where((g) => g.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  // ============================================================
  // Group CRUD
  // ============================================================
  Future<String?> createNewGroup(GroupEntity group, {File? imageFile}) async {
    try {
      isLoading.value = true;
      if (group.name.trim().isEmpty) throw Exception('Group name required');
      if (!_networkService.isOnline) throw Exception('No internet connection');

      final remoteId = await createGroupUseCase(group, imageFile: imageFile);
      // If image was uploaded separately? The use case already handles image upload.
      // But in our implementation, createGroupUseCase calls repository which handles upload.
      await fetchGroups();
      ErrorHandler.showSuccess('Success', 'Group created successfully');
      return remoteId;
    } catch (e, stack) {
      AppLogger.e('createNewGroup error', e, stack);
      ErrorHandler.handleError('Creation Failed', ErrorHandler.getUserFriendlyException(e));
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGroupDetails(GroupEntity group) async {
    try {
      isLoading.value = true;
      await remoteDataSource.updateGroup(GroupModel.fromEntity(group));
      await fetchGroups();
      if (currentGroup.value?.id == group.id) {
        currentGroup.value = group;
      }
      ErrorHandler.showSuccess('Success', 'Group updated');
    } catch (e, stack) {
      AppLogger.e('updateGroupDetails error', e, stack);
      ErrorHandler.handleError('Update Failed', ErrorHandler.getUserFriendlyException(e));
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== refreshGroups  ==========
  Future<void> refreshGroups() async {
    await fetchGroups(forceRefresh: true, initialLoad: false);
  }

// ==========refreshGroupDetail ==========
  Future<void> refreshGroupDetail(String groupId) async {
    await loadGroupAndMembers(groupId, forceRefresh: true);
  }

  Future<void> deleteSelectedGroup(String groupId) async {
    try {
      isLoading.value = true;
      if (!_networkService.isOnline) throw Exception('No internet connection');
      await deleteGroupUseCase(groupId);
      groups.removeWhere((g) => g.id == groupId);
      allGroups.removeWhere((g) => g.id == groupId);
      if (currentGroup.value?.id == groupId) currentGroup.value = null;
      ErrorHandler.showSuccess('Deleted', 'Group permanently deleted');
      Get.offAllNamed('/groups'); // Navigate to groups list
    } catch (e, stack) {
      AppLogger.e('deleteSelectedGroup error', e, stack);
      ErrorHandler.handleError('Delete Failed', ErrorHandler.getUserFriendlyException(e));
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // Members management
  // ============================================================
  Future<void> loadMembers(String groupId) async {
    try {
      isLoading.value = true;
      final remoteMembers = await getMembersUseCase(groupId);
      members.assignAll(remoteMembers);
      AppLogger.i('Loaded ${remoteMembers.length} members');
    } catch (e, stack) {
      AppLogger.e('loadMembers error', e, stack);
      ErrorHandler.handleError('Failed to load members', ErrorHandler.getUserFriendlyException(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMemberToGroup(String groupId, String identifier, String name) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty || identifier.isEmpty || name.isEmpty) {
        throw Exception('All fields required');
      }
      // Check existing members (refresh if empty)
      if (members.isEmpty) await loadMembers(groupId);

      final userData = await remoteDataSource.findUserByEmail(identifier.trim().toLowerCase());
      final resolvedUserId = userData?['uid'] ?? identifier;
      final existing = members.firstWhereOrNull((m) => m.userId == resolvedUserId);
      if (existing != null) {
        throw Exception(existing.invitationStatus == 'pending'
            ? 'Invitation already pending'
            : 'User already in group');
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
      await addMemberUseCase(groupId, newMember);
      await loadMembers(groupId);
      ErrorHandler.showSuccess('Invitation Sent', 'Invitation sent successfully');
    } catch (e, stack) {
      AppLogger.e('addMemberToGroup error', e, stack);
      ErrorHandler.handleError('Failed to add member', ErrorHandler.getUserFriendlyException(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      isLoading.value = true;
      await remoteDataSource.removeMember(groupId, userId);
      members.removeWhere((m) => m.userId == userId);
      ErrorHandler.showSuccess('Removed', 'Member removed successfully');
    } catch (e, stack) {
      AppLogger.e('removeMemberFromGroup error', e, stack);
      ErrorHandler.handleError('Failed to remove member', ErrorHandler.getUserFriendlyException(e));
    } finally {
      isLoading.value = false;
    }
  }

  // Fixed: Actually updates status in backend
  Future<void> updateMemberStatusLocally(String groupId, String userId, String status) async {
    try {
      isLoading.value = true;
      await updateMemberStatusUseCase(groupId, userId, status);
      // Refresh members to get updated status
      await loadMembers(groupId);
      ErrorHandler.showSuccess('Status Updated', 'Member status changed to $status');
    } catch (e, stack) {
      AppLogger.e('updateMemberStatus error', e, stack);
      ErrorHandler.handleError('Update Failed', ErrorHandler.getUserFriendlyException(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptGroupInvitation({required String groupId, required String userId}) async {
    await updateMemberStatusLocally(groupId, userId, 'accepted');
  }

  Future<void> addSelectedMembers(List<Map<String, dynamic>> selectedUsers) async {
    final currentGroupId = currentGroup.value?.id;
    if (currentGroupId == null || currentGroupId.isEmpty) {
      ErrorHandler.handleError('Error', 'Group not found');
      return;
    }
    try {
      isLoading.value = true;
      await loadMembers(currentGroupId);
      int added = 0;
      for (final user in selectedUsers) {
        final uid = user['uid']?.toString().trim() ?? '';
        final name = user['name']?.toString().trim() ?? 'Unknown';
        final alreadyExists = members.any((m) => m.userId == uid || m.name == name);
        if (alreadyExists) continue;
        final newMember = MemberEntity(
          groupId: currentGroupId,
          userId: uid.isNotEmpty ? uid : name, // fallback
          name: name,
          role: 'member',
          invitationStatus: 'accepted', // V1: add as accepted directly
          joinedAt: DateTime.now(),
          invitedBy: currentUserId,
          isAppUser: user['isAppUser'] ?? false,
          firestoreId: '',
        );
        await addMemberUseCase(currentGroupId, newMember);
        added++;
      }
      await loadMembers(currentGroupId);
      Get.back(); // pop select members screen
      ErrorHandler.showSuccess('Members Added', '$added member(s) added');
    } catch (e, stack) {
      AppLogger.e('addSelectedMembers error', e, stack);
      ErrorHandler.handleError('Error', ErrorHandler.getUserFriendlyException(e));
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // User search
  // ============================================================
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
      final results = await searchUsersUseCase(query.trim());
      searchResults.assignAll(results);
    } catch (e, stack) {
      AppLogger.e('searchUsers error', e, stack);
      searchError.value = ErrorHandler.getUserFriendlyException(e);
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> fetchPhoneContacts() async {
    if (!_networkService.isOnline) {
      ErrorHandler.showInfo('Offline', 'Cannot load contacts without internet.');
      return;
    }

    try {
      final status = await fc.FlutterContacts.permissions.request(
        fc.PermissionType.readWrite,
      );
      if (status != fc.PermissionStatus.granted) {
        ErrorHandler.handlePermissionError('contacts');
        return;
      }

      // دریافت مخاطبین با شماره تلفن (برای V1 کافی است)
      final fetchedContacts = await fc.FlutterContacts.getAll(
        properties: {fc.ContactProperty.phone},
      );
      contacts.assignAll(fetchedContacts);
      AppLogger.i('Loaded ${fetchedContacts.length} contacts with phone numbers');
    } catch (e, stack) {
      AppLogger.e('Failed to fetch phone contacts', e, stack);
      ErrorHandler.handleError(
        'Contacts Error',
        ErrorHandler.getUserFriendlyException(e),
      );
    }
  }

  // ============================================================
  // Group detail screen helpers
  // ============================================================
  Future<void> loadGroupAndMembers(String groupId, {bool forceRefresh = false}) async {
    if (!_networkService.isOnline && !forceRefresh) {
      ErrorHandler.showInfo('Offline', 'Cannot refresh. Connect to internet.');
      return;
    }
    final group = allGroups.firstWhereOrNull((g) => g.id == groupId);
    if (group != null) currentGroup.value = group;
    await loadMembers(groupId);
    _watchGroupBalance(groupId);
  }

  void _watchGroupBalance(String groupId) {
    _expenseSubscription?.cancel();
    _expenseSubscription = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }
      balanceText.value = total.toStringAsFixed(0);
    }, onError: (e) {
      AppLogger.e('Balance stream error', e);
    });
  }

  void goToAddMembers() {
    final groupId = currentGroup.value?.id;
    if (groupId == null || groupId.isEmpty) {
      ErrorHandler.handleError('Error', 'Group ID is null');
      return;
    }
    Get.toNamed('/select-members', arguments: {'groupId': groupId});
  }

  // Image upload
  Future<String?> uploadGroupImage(File imageFile, String groupId) async {
    try {
      if (!_networkService.isOnline) throw Exception('No internet connection');
      isLoadingImage.value = true;
      final ref = FirebaseStorage.instance.ref().child('group_images/$groupId.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      await remoteDataSource.updateGroupCover(groupId, url);
      // Update local state
      if (currentGroup.value?.id == groupId) {
        final updated = (currentGroup.value as GroupModel).copyWith(coverImageUrl: url);
        currentGroup.value = updated;
        final index = allGroups.indexWhere((g) => g.id == groupId);
        if (index != -1) allGroups[index] = updated as GroupModel;
        final groupIndex = groups.indexWhere((g) => g.id == groupId);
        if (groupIndex != -1) groups[groupIndex] = updated;
      }
      ErrorHandler.showSuccess('Uploaded', 'Group image updated');
      return url;
    } catch (e, stack) {
      AppLogger.e('uploadGroupImage error', e, stack);
      ErrorHandler.handleError('Upload Failed', ErrorHandler.getUserFriendlyException(e));
      return null;
    } finally {
      isLoadingImage.value = false;
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
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  await uploadGroupImage(File(picked.path), group.id);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  await uploadGroupImage(File(picked.path), group.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Dialogs (keep UI unchanged, just reusing error handling)
  // ============================================================
  void showEditGroupNameDialog(BuildContext context, GroupEntity group) {
    final controller = TextEditingController(text: group.name);
    Get.defaultDialog(
      title: 'Edit Group Name',
      content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Enter new name')),
      confirm: ElevatedButton(
        onPressed: () async {
          final newName = controller.text.trim();
          if (newName.isNotEmpty && newName != group.name) {
            final updatedGroup = (group as GroupModel).copyWith(name: newName);
            await updateGroupDetails(updatedGroup);
          }
          Get.back();
        },
        child: const Text('Save'),
      ),
      cancel: TextButton(onPressed: Get.back, child: const Text('Cancel')),
    );
  }

  void showDeleteGroupDialog(BuildContext context, String groupId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await deleteSelectedGroup(groupId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void showRemoveMemberDialog(BuildContext context, String groupId, MemberEntity member) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.name} from the group?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await removeMemberFromGroup(groupId, member.userId);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  bool canRemoveMember(MemberEntity member) {
    final currentUser = members.firstWhereOrNull((m) => m.userId == currentUserId);
    if (currentUser == null) return false;
    return currentUser.role == 'admin' && member.userId != currentUserId;
  }
}