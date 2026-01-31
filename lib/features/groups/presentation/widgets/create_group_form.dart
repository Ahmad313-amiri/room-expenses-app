import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();

  List<Map<String, dynamic>> members = [
    {'id': '1', 'name': 'You (Owner)', 'initials': 'ME', 'isOwner': true, 'isCurrentUser': true},
    {'id': '2', 'name': 'John Doe', 'initials': 'JD', 'isOwner': false, 'isCurrentUser': false},
    {'id': '3', 'name': 'Sarah Adams', 'initials': 'SA', 'isOwner': false, 'isCurrentUser': false},
  ];

  String groupImageUrl = ''; // For uploaded image
  bool _isCreating = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Group',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upload Group Photo Section
                _buildPhotoUploadSection(),

                const SizedBox(height: 32),

                // Group Details Section
                _buildGroupDetailsSection(),

                const SizedBox(height: 32),

                // Add Members Section
                _buildAddMembersSection(),

                const SizedBox(height: 32),

                // Information Text
                _buildInfoText(),

                const SizedBox(height: 40),

                // Create Group Button
                _buildCreateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: groupImageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                groupImageUrl,
                fit: BoxFit.cover,
              ),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 32,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to add',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Upload Group Photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to change icon',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'GROUP NAME',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _groupNameController,
          decoration: InputDecoration(
            hintText: 'e.g. Europe Trip, Roommates',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAddMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Members',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Member Input Field
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
                    style: const TextStyle(fontSize: 16),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _addMember(value);
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_memberController.text.isNotEmpty) {
                      _addMember(_memberController.text);
                    }
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Press Enter or tap + to add member',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 20),

        // Members List
        if (members.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: members.map((member) {
              return _buildMemberChip(member);
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildMemberChip(Map<String, dynamic> member) {
    return Chip(
      backgroundColor: member['isOwner']
          ? Colors.blue.shade50
          : Colors.grey.shade100,
      side: BorderSide.none,
      avatar: CircleAvatar(
        backgroundColor: member['isOwner']
            ? Colors.blue.shade100
            : Colors.grey.shade300,
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
      deleteIcon: member['isCurrentUser']
          ? null
          : const Icon(
        Icons.close,
        size: 16,
        color: Colors.grey,
      ),
      onDeleted: member['isCurrentUser']
          ? null
          : () {
        setState(() {
          members.removeWhere((m) => m['id'] == member['id']);
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'People you add will be invited to join the group to track shared expenses.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _isCreating
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'Create Group',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _uploadGroupPhoto() {
    // In a real app, this would open image picker
    // For demo, we'll simulate with a dialog
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
                _showSnackBar('Camera opened');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Simulate selecting an image
                setState(() {
                  groupImageUrl = 'https://via.placeholder.com/150';
                });
                _showSnackBar('Photo selected');
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  groupImageUrl = '';
                });
                _showSnackBar('Photo removed');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addMember(String nameOrEmail) {
    if (nameOrEmail.trim().isEmpty) return;

    // Check if member already exists
    if (members.any((member) =>
    member['name'].toLowerCase() == nameOrEmail.toLowerCase())) {
      _showSnackBar('Member already added');
      return;
    }

    // Generate initials
    String initials = nameOrEmail
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('')
        .substring(0, 2);

    setState(() {
      members.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': nameOrEmail,
        'initials': initials,
        'isOwner': false,
        'isCurrentUser': false,
      });
      _memberController.clear();
    });
  }

  void _createGroup() async {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      _showSnackBar('Please enter a group name');
      return;
    }

    if (members.length < 2) {
      _showSnackBar('Add at least one more member');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isCreating = false;
    });

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Success!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text('Group "$groupName" created successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {'success': true, 'groupName': groupName});
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}