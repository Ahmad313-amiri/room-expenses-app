import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../../auth/data/repository/authentication_repository.dart';
import '../../data/data_sources/group_local_datasource.dart';
import '../../data/data_sources/group_remote_datasource.dart';
import '../../data/repository/group_repository_impl.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_setting.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/usecases/add_member.dart';
import '../../domain/usecases/archive_group.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/get_groups.dart';
import '../../domain/usecases/get_members.dart';
import '../controller/group_controller.dart';
import 'groups_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();
  GroupsController get controller => Get.find<GroupsController>();

  List<Map<String, dynamic>> members = [];
  String groupImageUrl = '';
  bool _isCreating = false;

  late final String currentUserId; // ذخیره userId واقعی


  // @override
  // void initState() {
  //   super.initState();
  //
  //   // --- FIX: register controller if not already available ---
  //   if (!Get.isRegistered<GroupsController>()) {
  //     final isar = Isar.getInstance()!;
  //     final firestore = FirebaseFirestore.instance;
  //     final local = GroupLocalDataSource(isar);
  //     final remote = GroupRemoteDataSource(firestore);
  //     final repository = GroupRepositoryImpl(local: local, remote: remote);
  //
  //     Get.put(GroupsController(
  //       getGroupsUseCase: GetGroups(repository),
  //       createGroupUseCase: CreateGroup(repository),
  //       addMemberUseCase: AddMember(repository),
  //       archiveGroupUseCase: ArchiveGroup(repository),
  //       getMembersUseCase: GetMembers(repository),
  //     ));
  //   }
  //   final authRepo = Get.find<AuthenticationRepository>();
  //   currentUserId = authRepo.firebaseUser.value?.uid ?? '';
  //
  //   // اضافه کردن خود کاربر به لیست اعضا
  //   members.add({
  //     'id': currentUserId,
  //     'name': 'You (Owner)',
  //     'initials': 'ME',
  //     'isOwner': true,
  //     'isCurrentUser': true,
  //     'userId': currentUserId,
  //   });
  //
  // }

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      _showSnackBar('Please enter a group name');
      return;
    }
    if (members.length < 2) {
      _showSnackBar('Add at least one more member');
      return;
    }

    setState(() => _isCreating = true);

    try {
      final newGroup = GroupEntity(
        id: '',
        name: groupName,
        description: '',
        coverImageUrl: groupImageUrl,
        currency: 'USD',
        createdBy: currentUserId, // استفاده از userId واقعی
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        settings: GroupSettingsEntity(
          allowInvites: true,
          defaultSplitMethod: 'equal',
          expenseCategories: [],
        ),
      );

      await controller.createNewGroup(newGroup);

      final createdGroup = controller.groups.lastWhere(
            (g) => g.name == groupName && g.createdBy == currentUserId,
        orElse: () => controller.groups.last,
      );

      for (var member in members) {
        if (member['isCurrentUser']) continue; // خودکار اضافه می‌شه

        final memberEntity = MemberEntity(
          firestoreId: '',
          groupId: createdGroup.id,
          userId: member['userId'], // این userId می‌تونه موقت باشه، بعداً باید با شناسه واقعی جایگزین بشه
          role: 'member',
          joinedAt: DateTime.now(),
          invitationStatus: 'pending',
          invitedBy: currentUserId,
        );
        await controller.addMemberToGroup(createdGroup.id, memberEntity);
      }

      _showSuccessDialog(groupName, createdGroup.id);
    } catch (e) {
      _showSnackBar('Failed to create group: $e');
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _showSuccessDialog(String groupName, String groupId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 12),
            Text('Success!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Group "$groupName" created successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.off(() => GroupDetailScreen(groupId: groupId));
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addMember(String nameOrEmail) {
    if (nameOrEmail.trim().isEmpty) return;
    if (members.any((m) => m['name'].toLowerCase() == nameOrEmail.toLowerCase())) {
      _showSnackBar('Member already added');
      return;
    }

    String initials = nameOrEmail
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('')
        .substring(0, nameOrEmail.contains(' ') ? 2 : 1);

    setState(() {
      members.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': nameOrEmail,
        'initials': initials,
        'isOwner': false,
        'isCurrentUser': false,
        'userId': 'temp_${DateTime.now().millisecondsSinceEpoch}', // موقت
      });
      _memberController.clear();
    });
  }

  void _showSnackBar(String message) {
    Get.snackbar(
      'Notice',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ========== بخش‌های UI (بدون تغییر) ==========
  Widget _buildPhotoUploadSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _uploadGroupPhoto,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: groupImageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(groupImageUrl, fit: BoxFit.cover),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 32, color: Colors.grey),
                SizedBox(height: 8),
                Text('Tap to add', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Upload Group Photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Tap to change icon', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildGroupDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Group Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('GROUP NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        TextField(
          controller: _groupNameController,
          decoration: InputDecoration(
            hintText: 'e.g. Europe Trip, Roommates',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memberController,
                    decoration: InputDecoration(
                      hintText: '+ Name or email address',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onSubmitted: (value) => _addMember(value),
                  ),
                ),
                IconButton(
                   onPressed: () => _addMember(_memberController.text),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Press Enter or tap + to add member',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        if (members.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: members.map((member) => _buildMemberChip(member)).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildMemberChip(Map<String, dynamic> member) {
    return Chip(
      backgroundColor: member['isOwner'] ? Colors.blue.shade50 : Colors.grey.shade100,
      side: BorderSide.none,
      avatar: CircleAvatar(
        backgroundColor: member['isOwner'] ? Colors.blue.shade100 : Colors.grey.shade300,
        child: Text(
          member['initials'],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: member['isOwner'] ? Colors.blue : Colors.grey.shade700,
          ),
        ),
      ),
      label: Text(
        member['name'],
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: member['isOwner'] ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      deleteIcon: member['isCurrentUser'] ? null : const Icon(Icons.close, size: 16, color: Colors.grey),
      onDeleted: member['isCurrentUser']
          ? null
          : () => setState(() => members.removeWhere((m) => m['id'] == member['id'])),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _createGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isCreating
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Create Group', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _uploadGroupPhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // باز کردن دوربین
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                setState(() => groupImageUrl = 'https://via.placeholder.com/150');
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context);
                setState(() => groupImageUrl = '');
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text('Create New Group', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPhotoUploadSection(),
                const SizedBox(height: 32),
                _buildGroupDetailsSection(),
                const SizedBox(height: 32),
                _buildAddMembersSection(),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'People you add will be invited to join the group to track shared expenses.',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildCreateButton(),
              ],
            ),
          );
        }),
      ),
    );
  }
}