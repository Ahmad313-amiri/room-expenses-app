import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomly/features/auth/data/repository/authentication_repository.dart';
import 'package:roomly/features/groups/domain/entities/group.dart';
import 'package:roomly/features/groups/domain/entities/group_setting.dart';
import 'package:roomly/features/groups/presentation/pages/select_member_screen.dart';
import '../../data/models/member_model.dart';
import '../controller/group_controller.dart';
import 'groups_details_page.dart';

class CreateNewGroupScreen extends StatefulWidget {
  const CreateNewGroupScreen({super.key});

  @override
  State<CreateNewGroupScreen> createState() => _CreateNewGroupScreenState();
}

class _CreateNewGroupScreenState extends State<CreateNewGroupScreen> {
  final _nameController = TextEditingController();
  final _memberController = TextEditingController();

  late GroupsController controller;

  final List<Map<String, String>> _categories = [
    {'name': 'Home', 'icon': 'home'},
    {'name': 'Travel', 'icon': 'flight'},
    {'name': 'Dining', 'icon': 'restaurant'},
    {'name': 'Other', 'icon': 'more_horiz'},
  ];

  final List<String> _currencyOptions = [
    'USD - Dollar',
    'EUR - Euro',
    'AFN - Afghani',
    'IRR - Rial'
  ];

  late String _selectedCategory;
  late String _selectedCurrency;

  File? _selectedImage;
  bool _isCreating = false;

  List<MemberModel> members = [];

  @override
  void initState() {
    super.initState();
    controller = Get.find<GroupsController>();
    _selectedCategory = _categories[0]['name']!;
    _selectedCurrency = _currencyOptions[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addMemberManual() {
    final name = _memberController.text.trim();
    if (name.isEmpty) return;

    final exists = members.any((m) => m.name == name);
    if (exists) {
      Get.snackbar("Warning", "Member already added");
      return;
    }

    setState(() {
      members.add(MemberModel(
        name: name,
        userId:DateTime.now().toString(),
        firestoreId: '',
        groupId: '',
        role: '',
        joinedAt:DateTime.now(),
        invitationStatus: '',
      ));
    });

    _memberController.clear();
  }

  void _openContactsPicker() async {
    final result = await Get.to(() => const SelectMembersScreen());

    if (result != null && result is List) {
      setState(() {
        for (var m in result) {
          if (!members.any((old) => old.userId == m['uid'])) {
            members.add(
              MemberModel(
                firestoreId: '',
                groupId: '',
                userId: m['uid'],
                name: m['name'] ?? '',
                role: 'member',
                joinedAt: DateTime.now(),
                invitationStatus: 'pending',
                isAppUser: true,
              ),
            );
          }
        }
      });
    }
  }

  Future<void> _createGroup() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a group name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final authRepo = Get.find<AuthenticationRepository>();
    final firebaseUser = authRepo.firebaseUser.value;
    if (firebaseUser == null) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    final uid = firebaseUser.uid;
    final userName = firebaseUser.displayName ?? 'You';

    setState(() => _isCreating = true);

    try {
      // Ensure the creator is added as admin if not already in the list
      if (!members.any((m) => m.userId == uid)) {
        members.insert(
          0,
          MemberModel(
            name: userName,
            userId: uid,
            firestoreId: '',
            groupId: '',
            role: 'admin',
            joinedAt: DateTime.now(),
            invitationStatus: 'accepted',
            isAppUser: true,
          ),
        );
      }

      // Build the group entity
      final newGroup = GroupEntity(
        id: '',
        name: groupName,
        membersCount: members.length,
        description: _selectedCategory,
        coverImageUrl: '', // Will be updated after upload
        currency: _selectedCurrency.split(' ')[0],
        createdBy: uid,
        isArchived: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        settings: GroupSettingsEntity(
          allowInvites: true,
          defaultSplitMethod: 'equal',
          expenseCategories: ['General', 'Food', 'Transport'],
        ),
      );

      // Create group (with optional image upload)
      final groupId = await controller.createNewGroup(
        newGroup,
        imageFile: _selectedImage, // Pass the selected image file (can be null)
      );
      if (groupId == null) throw Exception('Group creation failed');

      // Add all members to the newly created group
      for (var member in members) {
        final identifier = member.userId.isNotEmpty ? member.userId : member.userId;
        final name = member.name;
        if (identifier.isNotEmpty && name.isNotEmpty) {
          await controller.addMemberToGroup(groupId, identifier, name);
        }
      }

      if (!mounted) return;
      // Navigate to the group detail screen and remove the creation screen from stack
      Get.off(() => GroupDetailScreen(groupId: groupId));
    } catch (e) {
      // Show user-friendly error message
      Get.snackbar(
        'Creation Failed',
        e.toString().contains('internet') || e.toString().contains('Network')
            ? 'No internet connection. Please try again.'
            : e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create New Group',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 32),
            _buildTextField(
              "Group Name",
              _nameController,
              "Example: Friends Trip",
            ),
            const SizedBox(height: 32),
            _buildCategorySelector(),
            const SizedBox(height: 32),
            _buildCurrencySelector(),
            const SizedBox(height: 32),
            _buildMemberSection(),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceActionSheet,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Icon(
                  Icons.groups_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF1D5CFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      String hint,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _categories.map((cat) {
            bool isSelected = _selectedCategory == cat['name'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['name']!),
              child: Container(
                width: 75,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha:  0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1D5CFF)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getIconData(cat['icon']!),
                      color: isSelected ? const Color(0xFF1D5CFF) : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['name']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? const Color(0xFF1D5CFF)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Currency',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCurrency,
              isExpanded: true,
              items: _currencyOptions
                  .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCurrency = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Group Members',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _openContactsPicker,
              icon: const Icon(Icons.contacts, size: 18),
              label: const Text("Select Contact"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _memberController,
          decoration: InputDecoration(
            hintText: "Enter person's name...",
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF1D5CFF)),
              onPressed: _addMemberManual,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _addMemberManual(),
        ),
        const SizedBox(height: 16),
        if (members.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final m = members[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            // backgroundImage: NetworkImage(),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => members.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(m.name, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _createGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D5CFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isCreating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Create Group',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'home':
        return Icons.home_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }
}