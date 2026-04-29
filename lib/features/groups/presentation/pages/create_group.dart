import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../auth/data/repository/authentication_repository.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_setting.dart';
import '../controller/group_controller.dart';
import 'select_member_screen.dart';
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

  // Store selected members (as Map<String, dynamic> to be compatible with controller)
  List<Map<String, dynamic>> _selectedMembers = [];

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


  void _addMemberManual() {
    final name = _memberController.text.trim();
    if (name.isEmpty) return;

    // Check duplicate by name
    final exists = _selectedMembers.any((m) => m['name'] == name);
    if (exists) {
      ErrorHandler.showInfo('Warning', 'Member already added');
      return;
    }

    setState(() {
      _selectedMembers.add({
        'uid': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'isAppUser': false,
        'avatar': 'https://ui-avatars.com/api/?name=$name',
      });
    });
    _memberController.clear();
  }

  Future<void> _openContactsPicker() async {
    // Navigate to SelectMembersScreen and wait for result
    final result = await Get.to<List<Map<String, dynamic>>>(() => const SelectMembersScreen());
    if (result != null && result.isNotEmpty) {
      setState(() {
        for (var member in result) {
          final exists = _selectedMembers.any((m) => m['uid'] == member['uid']);
          if (!exists) {
            _selectedMembers.add(member);
          }
        }
      });
      ErrorHandler.showSuccess('Members Added', '${result.length} member(s) selected');
    }
  }

  void _removeSelectedMember(int index) {
    setState(() {
      _selectedMembers.removeAt(index);
    });
  }

  Future<void> _createGroup() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty) {
      ErrorHandler.handleValidationError('Please enter a group name');
      return;
    }

    final authRepo = Get.find<AuthenticationRepository>();
    final firebaseUser = authRepo.firebaseUser.value;
    if (firebaseUser == null) {
      ErrorHandler.handleAuthError('User not authenticated');
      return;
    }

    final uid = firebaseUser.uid;

    setState(() => _isCreating = true);

    try {
      // Build group entity
      final newGroup = GroupEntity(
        id: '',
        name: groupName,
        membersCount: _selectedMembers.length + 1,
        description: _selectedCategory,
        coverImageUrl: '',
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

      // Create group (with optional image)
      final groupId = await controller.createNewGroup(
        newGroup,
        imageFile: _selectedImage,
      );

      if (groupId == null) throw Exception('Group creation failed');

      // Add all selected members
      for (var member in _selectedMembers) {
        final identifier = member['uid'] ?? member['phone'] ?? '';
        final name = member['name'] ?? '';
        if (identifier.isNotEmpty && name.isNotEmpty) {
          await controller.addMemberToGroup(groupId, identifier, name);
        }
      }

      // Add creator as member (already done in repository, but ensure)
      // Optionally, add creator to the list if not already there (but repository does it)

      AppLogger.i('Group created successfully: $groupId');
      ErrorHandler.showSuccess('Success', 'Group created successfully');

      if (!mounted) return;
      // Navigate to group detail screen and remove this screen from stack
      Get.off(() => GroupDetailScreen(groupId: groupId));
    } catch (e, stack) {
      AppLogger.e('Group creation failed', e, stack);
      final message = ErrorHandler.getUserFriendlyException(e);
      ErrorHandler.handleError('Creation Failed', message);
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
                      : Colors.white.withValues(alpha: 0.5),
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
        if (_selectedMembers.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedMembers.length,
              itemBuilder: (context, index) {
                final member = _selectedMembers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: member['avatar'] != null
                                ? NetworkImage(member['avatar'])
                                : null,
                            child: member['avatar'] == null
                                ? Text(member['name'][0].toUpperCase())
                                : null,
                          ),
                          GestureDetector(
                            onTap: () => _removeSelectedMember(index),
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
                      Text(member['name'], style: const TextStyle(fontSize: 10)),
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