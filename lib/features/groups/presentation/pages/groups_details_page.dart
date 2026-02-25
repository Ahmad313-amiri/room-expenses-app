// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:isar/isar.dart';
// import 'package:roomly/features/groups/presentation/pages/add_expense.dart';
// import 'package:roomly/features/groups/presentation/pages/advance_settle_screen.dart';
// import 'package:roomly/features/groups/presentation/pages/select_member_screen.dart';
// import 'package:roomly/features/groups/presentation/pages/spilit_method.dart';
//
// // Member data model
// class Member {
//   final String name;
//   final String avatar;
//   final String lastActivity;
//   final String status;
//
//   Member({
//     required this.name,
//     required this.avatar,
//     required this.lastActivity,
//     required this.status,
//   });
// }
//
// // Group Detail Screen
// class GroupDetailScreen extends StatefulWidget {
//   final String groupId; // دریافت شناسه گروه
//   const GroupDetailScreen({super.key, required this.groupId});
//
//   @override
//   State<GroupDetailScreen> createState() => _GroupDetailScreenState();
// }
//
// class _GroupDetailScreenState extends State<GroupDetailScreen> {
//   late final GroupsController controller;
//   late GroupEntity? group;
//   List<MemberEntity> members = [];
//
//   File? _imageFile;
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     controller = Get.find<GroupsController>();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     // گروه را از controller بگیرید (یا مستقیماً از repository)
//     group = controller.groups.firstWhereOrNull((g) => g.id == widget.groupId);
//     members = await controller.getMembers(widget.groupId);
//     setState(() {});
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 1000, maxHeight: 1000, imageQuality: 85);
//       if (pickedFile != null) {
//         setState(() => _imageFile = File(pickedFile.path));
//         // آپلود عکس و به‌روزرسانی گروه
//       }
//     } catch (e) {
//       debugPrint("Error picking image: $e");
//     }
//   }
//
//   void _showEditGroupNameDialog() {
//     final TextEditingController nameController = TextEditingController(text: group?.name ?? '');
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Group Name'),
//         content: TextField(controller: nameController, decoration: const InputDecoration(hintText: "Enter new name")),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           TextButton(
//             onPressed: () async {
//               if (nameController.text.isNotEmpty && group != null) {
//                 final updatedGroup = group!.copyWith(name: nameController.text);
//                 await controller.updateGroup(updatedGroup); // نیاز به متد update
//                 setState(() => group = updatedGroup);
//               }
//               Navigator.pop(context);
//             },
//             child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showDeleteGroupDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Group?'),
//         content: const Text('This will delete all expenses and data. This action cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           TextButton(
//             onPressed: () async {
//               await controller.archiveSelectedGroup(widget.groupId); // آرشیو کردن
//               Navigator.pop(context);
//               Navigator.pop(context); // بازگشت به لیست گروه‌ها
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//   // Group profile image
//   File? _imageFile;
//   final ImagePicker _picker = ImagePicker();
//   final String _defaultImageUrl =
//       'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400';
//
//   // Pick image from gallery or camera
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );
//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       debugPrint("Error picking image: $e");
//     }
//   }
//
//   // Remove current image and reset to default
//   void _removeImage() {
//     setState(() {
//       _imageFile = null;
//     });
//   }
//
//   // Show bottom sheet for image options
//   void _showPickerMenu() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             const ListTile(
//               title: Text('Group Photo', style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library, color: Colors.blue),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 _pickImage(ImageSource.gallery);
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: Colors.blue),
//               title: const Text('Take a Photo'),
//               onTap: () {
//                 _pickImage(ImageSource.camera);
//                 Navigator.pop(context);
//               },
//             ),
//             // Option to remove current photo if an image is selected
//             if (_imageFile != null)
//               ListTile(
//                 leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
//                 title: const Text('Remove Current Photo',
//                     style: TextStyle(color: Colors.redAccent)),
//                 onTap: () {
//                   _removeImage();
//                   Navigator.pop(context);
//                 },
//               ),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Dialog to edit group name
//   void _showEditGroupNameDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Group Name'),
//         content: const TextField(
//           decoration: InputDecoration(hintText: "Enter new name"),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold))),
//         ],
//       ),
//     );
//   }
//
//   // Dialog to confirm group deletion
//   void _showDeleteGroupDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Group?'),
//         content: const Text(
//             'This will delete all expenses and data. This action cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Delete', style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         // AppBar title with edit icon
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Ski Trip 2024',
//                 style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
//             const SizedBox(width: 4),
//             IconButton(
//               icon: const Icon(Icons.edit_note, color: Colors.grey, size: 20),
//               onPressed: _showEditGroupNameDialog,
//             ),
//           ],
//         ),
//         centerTitle: true,
//         actions: [
//           // Delete group button
//           IconButton(
//             icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
//             onPressed: _showDeleteGroupDialog,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 30),
//             // Group profile image with edit button
//             Center(
//               child: GestureDetector(
//                 onTap: _showPickerMenu,
//                 child: Stack(
//                   alignment: Alignment.bottomRight,
//                   children: [
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
//                         image: DecorationImage(
//                           // Show selected image or default
//                           image: _imageFile != null
//                               ? FileImage(_imageFile!) as ImageProvider
//                               : NetworkImage(_defaultImageUrl),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     // Edit icon on image
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: Colors.white, width: 2),
//                       ),
//                       child: const Icon(Icons.edit, color: Colors.white, size: 18),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             // Image hint text
//             Text(
//               _imageFile == null ? 'Tap to add group photo' : 'Tap to change or remove photo',
//               style: const TextStyle(color: Colors.grey, fontSize: 13),
//             ),
//             const SizedBox(height: 24),
//             // Financial overview
//             Column(
//               children: [
//                 const Text('GROUP BALANCE',
//                     style: TextStyle(
//                         color: Colors.grey, letterSpacing: 1.2, fontSize: 11, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 const Text('You are owed \$150.00',
//                     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
//                 const SizedBox(height: 4),
//                 Text('${members.length} members • Active 2 weeks ago',
//                     style: const TextStyle(color: Colors.grey, fontSize: 13)),
//               ],
//             ),
//             const SizedBox(height: 24),
//             // Main action buttons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 children: [
//                   Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(context,MaterialPageRoute(builder: (_)=>AdvancedSettleUpScreen()));
//                         },
//                         icon: const Icon(Icons.handshake_outlined, size: 18),
//                         label: const Text('Settle Up',
//                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           elevation: 0,
//                         ),
//                       )),
//                   const SizedBox(width: 12),
//                   Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(context,MaterialPageRoute(builder: (_)=>SplitMethodScreen()));
//                         },
//                         icon: const Icon(Icons.add_circle_outline, size: 18),
//                         label: const Text('Add Expense',
//                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           elevation: 0,
//                         ),
//                       )),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             // Members section
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('Group Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       TextButton.icon(
//                         onPressed: () {
//                           // Navigate to add members screen
//                           Navigator.push(context, MaterialPageRoute(builder: (_)=>SelectMembersScreen()));
//                         },
//                         icon: const Icon(Icons.person_add_alt_1, size: 18),
//                         label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // List of members
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: members.length,
//                   itemBuilder: (context, index) => _buildMemberCard(index),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             // Recent activity
//             Column(
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
//                 ),
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//                   child: const Row(
//                     children: [
//                       Icon(Icons.restaurant, color: Colors.blue),
//                       SizedBox(width: 16),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Dinner at Alpine Lodge', style: TextStyle(fontWeight: FontWeight.bold)),
//                           Text('Paid by You • \$124.50', style: TextStyle(color: Colors.grey, fontSize: 12)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 100),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Member card
//   Widget _buildMemberCard(int index) {
//     final member = members[index];
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//       child: Row(
//         children: [
//           CircleAvatar(backgroundImage: NetworkImage(member.avatar), radius: 22),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                 Text(member.lastActivity, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               // Status text
//               Text(
//                 member.status,
//                 style: TextStyle(
//                   color: member.status.contains('Owes') ? Colors.green : Colors.red,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 13,
//                 ),
//               ),
//               // Remove button
//               GestureDetector(
//                 onTap: () => setState(() => members.removeAt(index)),
//                 child: const Padding(
//                   padding: EdgeInsets.only(top: 4),
//                   child: Text('Remove',
//                       style: TextStyle(
//                           color: Colors.grey, fontSize: 11, decoration: TextDecoration.underline)),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//















import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/member_entity.dart';
import '../controller/group_controller.dart';
import 'add_expense.dart';
import 'advance_settle_screen.dart';
import 'select_member_screen.dart';
import 'split_method.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late final GroupsController controller;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final String _defaultImageUrl =
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400';

  @override
  void initState() {
    super.initState();
    controller = Get.find<GroupsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadMembers(widget.groupId);
    });
  }

  GroupEntity? get group =>
      controller.groups.firstWhereOrNull((g) => g.id == widget.groupId);

  // ========== متدهای مدیریت تصویر ==========
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        // TODO: آپلود تصویر و به‌روزرسانی گروه در کنترلر
        // await controller.uploadGroupImage(widget.groupId, _imageFile!);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _removeImage() {
    setState(() => _imageFile = null);
    // TODO: حذف تصویر گروه در کنترلر
  }

  void _showPickerMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text('Group Photo',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Take a Photo'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            if (_imageFile != null)
              ListTile(
                leading:
                const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Remove Current Photo',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  _removeImage();
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ========== دیالوگ ویرایش نام گروه ==========
  void _showEditGroupNameDialog() {
    final TextEditingController nameController =
    TextEditingController(text: group?.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && group != null) {
                // TODO: فراخوانی متد به‌روزرسانی نام در کنترلر
                // await controller.updateGroupName(widget.groupId, nameController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ========== دیالوگ حذف گروه ==========
  void _showDeleteGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text(
            'This will delete all expenses and data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await controller.archiveSelectedGroup(widget.groupId);
              Navigator.pop(context);
              Get.back(); // بازگشت به لیست گروه‌ها
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ========== ساخت بخش‌های UI ==========
  Widget _buildGroupImage() {
    return Center(
      child: GestureDetector(
        onTap: _showPickerMenu,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                image: DecorationImage(
                  image: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : (group?.coverImageUrl.isNotEmpty == true
                      ? NetworkImage(group!.coverImageUrl)
                      : NetworkImage(_defaultImageUrl)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      children: [
        const Text('GROUP BALANCE',
            style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.2,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('You are owed \$150.00',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A))),
        const SizedBox(height: 4),
        Text('${controller.members.length} members',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const AdvancedSettleUpScreen());
              },
              icon: const Icon(Icons.handshake_outlined, size: 18),
              label: const Text('Settle Up',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const SplitMethodScreen());
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Expense',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Group Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => Get.to(() => const SelectMembersScreen()),
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Add',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.members.length,
          itemBuilder: (context, index) {
            final member = controller.members[index];
            return _buildMemberCard(member, index);
          },
        ),
      ],
    );
  }

  Widget _buildMemberCard(MemberEntity member, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.userId,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(member.role,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                member.invitationStatus,
                style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: فراخوانی متد حذف عضو از کنترلر
                  // controller.removeMember(widget.groupId, member.id);
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Remove',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Row(
            children: [
              Icon(Icons.restaurant, color: Colors.blue),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dinner at Alpine Lodge',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Paid by You • \$124.50',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              group?.name ?? 'Group Details',
              style: const TextStyle(
                  color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.grey, size: 20),
              onPressed: _showEditGroupNameDialog,
            ),
          ],
        )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _showDeleteGroupDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildGroupImage(),
              const SizedBox(height: 12),
              Text(
                _imageFile == null
                    ? 'Tap to add group photo'
                    : 'Tap to change or remove photo',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              _buildBalanceSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 32),
              _buildMembersList(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }
}


















