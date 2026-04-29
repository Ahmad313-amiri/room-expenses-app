import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../domain/usecases/get_members_paginated.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/update_member_status.dart';


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
  final GetMembersPaginated getMembersPaginatedUseCase;

  GroupsController({
    required this.searchUsersUseCase,
    required this.getGroupsUseCase,
    required this.createGroupUseCase,
    required this.addMemberUseCase,
    required this.deleteGroupUseCase,
    required this.getMembersUseCase,
    required this.remoteDataSource,
    required this.updateMemberStatusUseCase,
    required this.getMembersPaginatedUseCase,
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

  // Pagination for members
  var hasMoreMembers = true.obs;
  var isLoadingMoreMembers = false.obs;
  DocumentSnapshot? _lastMemberDoc;
  static const int _memberPageSize = 20;

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

  // ========== getter groupId ==========
  String get groupId => currentGroup.value?.id ?? '';

  // ============================================================
  // Group fetching
  // ============================================================
  Future<void> fetchGroups({
    bool forceRefresh = false,
    bool initialLoad = false,
  }) async {
    if (!_networkService.isOnline && !forceRefresh) {
      if (!initialLoad) {
        ErrorHandler.showInfo(
          'Offline',
          'Showing cached data. Connect to refresh.',
        );
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
      final remoteGroups = await getGroupsUseCase(
        uid,
      ).timeout(const Duration(seconds: 15));
      final models = remoteGroups
          .map((e) => e is GroupModel ? e : GroupModel.fromEntity(e))
          .toList();
      groups.assignAll(models);
      allGroups.assignAll(models);
      AppLogger.i('Fetched ${models.length} groups');
    } catch (e, stack) {
      AppLogger.e('fetchGroups error', e, stack);
      if (!initialLoad) {
        ErrorHandler.handleError(
          'Network Error',
          ErrorHandler.getUserFriendlyException(e),
        );
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

  // ============================================================
  // Group CRUD
  // ============================================================
  Future<String?> createNewGroup(GroupEntity group, {File? imageFile}) async {
    try {
      isLoading.value = true;
      if (group.name.trim().isEmpty) throw Exception('Group name required');
      if (!_networkService.isOnline) throw Exception('No internet connection');

      final remoteId = await createGroupUseCase(group);
      await fetchGroups();
      ErrorHandler.showSuccess('Success', 'Group created successfully');
      return remoteId;
    } catch (e, stack) {
      AppLogger.e('createNewGroup error', e, stack);
      ErrorHandler.handleError(
        'Creation Failed',
        ErrorHandler.getUserFriendlyException(e),
      );
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
      ErrorHandler.handleError(
        'Update Failed',
        ErrorHandler.getUserFriendlyException(e),
      );
      rethrow;
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

  Future<void> deleteSelectedGroup(String groupId) async {
    try {
      isLoading.value = true;
      if (!_networkService.isOnline) throw Exception('No internet connection');
      await deleteGroupUseCase(groupId);
      groups.removeWhere((g) => g.id == groupId);
      allGroups.removeWhere((g) => g.id == groupId);
      if (currentGroup.value?.id == groupId) currentGroup.value = null;
      await fetchGroups();
      Get.offAllNamed('/main', arguments: {'initialTab': 1});
      ErrorHandler.showSuccess('Deleted', 'Group permanently deleted');
    } catch (e, stack) {
      AppLogger.e('deleteSelectedGroup error', e, stack);
      ErrorHandler.handleError(
        'Delete Failed',
        ErrorHandler.getUserFriendlyException(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // Members management with pagination
  // ============================================================

  // MODIFIED: renamed from loadMembers → loadMembersInitial (clears and loads first page)
  Future<void> loadMembersInitial(String groupId) async {
    try {
      isLoading.value = true;
      members.clear();
      hasMoreMembers.value = true;
      _lastMemberDoc = null;

      final (newMembers, lastDoc, hasMore) = await getMembersPaginatedUseCase(
        groupId,
        limit: _memberPageSize,
        startAfter: null,
      );
      members.assignAll(newMembers);
      _lastMemberDoc = lastDoc;
      hasMoreMembers.value = hasMore;
      AppLogger.i('Loaded ${newMembers.length} members (initial)');
    } catch (e, stack) {
      AppLogger.e('loadMembersInitial error', e, stack);
      ErrorHandler.handleError(
        'Failed to load members',
        ErrorHandler.getUserFriendlyException(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  //  public wrapper to reset pagination and reload (used after add/remove)
  Future<void> refreshMembers(String groupId) async {
    await loadMembersInitial(groupId);
  }

  Future<void> loadMoreMembers(String groupId) async {
    if (isLoadingMoreMembers.value || !hasMoreMembers.value) return;
    isLoadingMoreMembers.value = true;
    try {
      final (newMembers, lastDoc, hasMore) = await getMembersPaginatedUseCase(
        groupId,
        limit: _memberPageSize,
        startAfter: _lastMemberDoc,
      );
      if (newMembers.isNotEmpty) {
        members.addAll(newMembers);
        _lastMemberDoc = lastDoc;
      }
      hasMoreMembers.value = hasMore;
      AppLogger.i('Loaded ${newMembers.length} more members');
    } catch (e, stack) {
      AppLogger.e('loadMoreMembers error', e, stack);
      hasMoreMembers.value = false;
    } finally {
      isLoadingMoreMembers.value = false;
    }
  }

  Future<void> addMemberToGroup(
    String groupId,
    String identifier,
    String name,
  ) async {
    try {
      isLoading.value = true;
      if (groupId.isEmpty || identifier.isEmpty || name.isEmpty) {
        throw Exception('All fields required');
      }
      // MODIFIED: use loadMembersInitial instead of old loadMembers
      if (members.isEmpty) await loadMembersInitial(groupId);

      final userData = await remoteDataSource.findUserByEmail(
        identifier.trim().toLowerCase(),
      );
      final resolvedUserId = userData?['uid'] ?? identifier;
      final existing = members.firstWhereOrNull(
        (m) => m.userId == resolvedUserId,
      );
      if (existing != null) {
        throw Exception(
          existing.invitationStatus == 'pending'
              ? 'Invitation already pending'
              : 'User already in group',
        );
      }
      final newMember = MemberEntity(
        groupId: groupId,
        userId: resolvedUserId,
        name: userData?['name'] ?? name,
        role: userData != null ? 'member' : 'guest',
        invitationStatus: 'pending',
        joinedAt: DateTime.now(),
        invitedBy: currentUserId,
        firestoreId: '',
      );
      await addMemberUseCase(groupId, newMember);
      // MODIFIED: refresh member list with reset pagination
      await refreshMembers(groupId);
      ErrorHandler.showSuccess(
        'Invitation Sent',
        'Invitation sent successfully',
      );
    } catch (e, stack) {
      AppLogger.e('addMemberToGroup error', e, stack);
      ErrorHandler.handleError(
        'Failed to add member',
        ErrorHandler.getUserFriendlyException(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      isLoading.value = true;
      await remoteDataSource.removeMember(groupId, userId);
      // MODIFIED: refresh member list with reset pagination
      await refreshMembers(groupId);
      ErrorHandler.showSuccess('Removed', 'Member removed successfully');
    } catch (e, stack) {
      AppLogger.e('removeMemberFromGroup error', e, stack);
      ErrorHandler.handleError(
        'Failed to remove member',
        ErrorHandler.getUserFriendlyException(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMemberStatusLocally(
    String groupId,
    String userId,
    String status,
  ) async {
    try {
      isLoading.value = true;
      await updateMemberStatusUseCase(groupId, userId, status);
      // MODIFIED: refresh member list with reset pagination
      await refreshMembers(groupId);
      ErrorHandler.showSuccess(
        'Status Updated',
        'Member status changed to $status',
      );
    } catch (e, stack) {
      AppLogger.e('updateMemberStatus error', e, stack);
      ErrorHandler.handleError(
        'Update Failed',
        ErrorHandler.getUserFriendlyException(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptGroupInvitation({
    required String groupId,
    required String userId,
  }) async {
    await updateMemberStatusLocally(groupId, userId, 'accepted');
  }

  Future<void> addSelectedMembers(
    List<Map<String, dynamic>> selectedUsers,
  ) async {
    final currentGroupId = currentGroup.value?.id;
    if (currentGroupId == null || currentGroupId.isEmpty) {
      ErrorHandler.handleError('Error', 'Group not found');
      return;
    }
    try {
      isLoading.value = true;
      // MODIFIED: use loadMembersInitial to reset pagination state
      await loadMembersInitial(currentGroupId);
      int added = 0;
      for (final user in selectedUsers) {
        final uid = user['uid']?.toString().trim() ?? '';
        final name = user['name']?.toString().trim() ?? 'Unknown';
        final alreadyExists = members.any(
          (m) => m.userId == uid || m.name == name,
        );
        if (alreadyExists) continue;
        final newMember = MemberEntity(
          groupId: currentGroupId,
          userId: uid.isNotEmpty ? uid : name,
          name: name,
          role: 'member',
          invitationStatus: 'accepted',
          joinedAt: DateTime.now(),
          invitedBy: currentUserId,
          firestoreId: '',
        );
        await addMemberUseCase(currentGroupId, newMember);
        added++;
      }
      // MODIFIED: refresh after adding
      await refreshMembers(currentGroupId);
      if (added > 0) {
        ErrorHandler.showSuccess('Members Added', '$added member(s) added');
      }
    } catch (e, stack) {
      AppLogger.e('addSelectedMembers error', e, stack);
      ErrorHandler.handleError(
        'Error',
        ErrorHandler.getUserFriendlyException(e),
      );
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
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => searchUsers(query),
    );
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
      ErrorHandler.showInfo(
        'Offline',
        'Cannot load contacts without internet.',
      );
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

      final fetchedContacts = await fc.FlutterContacts.getAll(
        properties: {fc.ContactProperty.phone},
      );
      contacts.assignAll(fetchedContacts);
      AppLogger.i(
        'Loaded ${fetchedContacts.length} contacts with phone numbers',
      );
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

  // MODIFIED: inside class – now calls loadMembersInitial instead of undefined loadMembers
  Future<void> loadGroupAndMembers(
    String groupId, {
    bool forceRefresh = false,
  }) async {
    if (!_networkService.isOnline && !forceRefresh) {
      ErrorHandler.showInfo('Offline', 'Cannot refresh. Connect to internet.');
      return;
    }
    final group = allGroups.firstWhereOrNull((g) => g.id == groupId);
    if (group != null) currentGroup.value = group;
    await loadMembersInitial(groupId); //
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
        .listen(
          (snapshot) {
            double total = 0;
            for (var doc in snapshot.docs) {
              total += (doc.data()['amount'] ?? 0).toDouble();
            }
            balanceText.value = total.toStringAsFixed(0);
          },
          onError: (e) {
            AppLogger.e('Balance stream error', e);
          },
        );
  }

  void goToAddMembers() {
    final groupId = currentGroup.value?.id;
    if (groupId == null || groupId.isEmpty) {
      ErrorHandler.handleError('Error', 'Group ID is null');
      return;
    }
    Get.toNamed('/select-members', arguments: {'groupId': groupId});
  }

  // ============================================================
  // Dialogs (unchanged)
  // ============================================================
  void showEditGroupNameDialog(BuildContext context, GroupEntity group) {
    final controller = TextEditingController(text: group.name);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Group Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              if (newName == group.name) {
                Navigator.pop(dialogContext);
                return;
              }

              try {
                final updatedGroup = (group as GroupModel).copyWith(name: newName);
                await updateGroupDetails(updatedGroup);

                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext);
                }
                ErrorHandler.showSuccess('Success', 'Group name updated');
              } catch (e) {
                ErrorHandler.handleError('Error', ErrorHandler.getUserFriendlyException(e));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void showDeleteGroupDialog(BuildContext context, String groupId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Group'),
              content: isLoading
                  ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()))
                  : const Text('Are you sure? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() => isLoading = true);
                    await deleteSelectedGroup(groupId);
                               },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void showRemoveMemberDialog(
    BuildContext context,
    String groupId,
    MemberEntity member,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.name} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
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
    final currentUser = members.firstWhereOrNull(
      (m) => m.userId == currentUserId,
    );
    if (currentUser == null) return false;
    return currentUser.role == 'admin' && member.userId != currentUserId;
  }

  // ADDED: Fetches all members (non-paginated) for settlement screen

  Future<List<MemberEntity>> getAllMembersForSettlement(String groupId) async {
    try {
      isLoading.value = true;
      final allMembers = await getMembersUseCase(groupId);
      return allMembers;
    } catch (e, stack) {
      AppLogger.e('getAllMembersForSettlement error', e, stack);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

// REMOVED: duplicate loadGroupAndMembers function that was outside the class
