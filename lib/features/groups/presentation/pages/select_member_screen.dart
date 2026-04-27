import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import '../controller/group_controller.dart';

class SelectMembersScreen extends StatefulWidget {
  const SelectMembersScreen({super.key});

  @override
  State<SelectMembersScreen> createState() => _SelectMembersScreenState();
}

class _SelectMembersScreenState extends State<SelectMembersScreen> {
  final GroupsController controller = Get.find<GroupsController>();
  final TextEditingController searchController = TextEditingController();

  final Map<String, Map<String, dynamic>> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    _refreshContacts();
      debugPrint("🔥 SelectMembersScreen INIT");
      final args = Get.arguments;
      debugPrint("📦 Arguments: $args");

  }

  Future<void> _refreshContacts() async {
    final status = await FlutterContacts.permissions.request(PermissionType.readWrite);
    if (status == PermissionStatus.granted) {
      await controller.fetchPhoneContacts();
    }
  }

  void _toggleSelection(Map<String, dynamic> user) {
    final uid = user['uid'].toString();
    setState(() {
      if (_selectedMembers.containsKey(uid)) {
        _selectedMembers.remove(uid);
      } else {
        _selectedMembers[uid] = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Add Members', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Color(0xFF1D5CFF),
            labelColor: Color(0xFF1D5CFF),
            tabs: [
              Tab(text: 'App Users'),
              Tab(text: 'Contacts'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_selectedMembers.isNotEmpty) _buildSelectedHorizontalList(),

            Expanded(
              child: TabBarView(
                children: [
                  _buildAppUsersTab(),
                  _buildPhoneContactsTab(),
                ],
              ),
            ),

            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedHorizontalList() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _selectedMembers.values.map((user) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: user['avatar'] is Uint8List
                      ? MemoryImage(user['avatar'])
                      : NetworkImage(user['avatar']) as ImageProvider,
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _toggleSelection(user),
                    child: const CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppUsersTab() {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (val) => controller.onSearchChanged(val),
            decoration: InputDecoration(
              hintText: 'Search by username...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isSearching.value) return const Center(child: CircularProgressIndicator());
            return ListView.builder(
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final user = controller.searchResults[index];
                bool isSelected = _selectedMembers.containsKey(user['uid']);
                return _buildUserListTile(
                  title: user['name'] ?? "",
                  subtitle: user['email'] ?? "-",
                  imageUrl: user['photoUrl'],
                  isSelected: isSelected,
                  onTap: () => _toggleSelection({
                    'uid': user['uid'],
                    'name': user['name'],
                    'avatar': user['photoUrl'] ?? 'https://ui-avatars.com/api/?name=${user['name']}',
                    'isAppUser': true,
                  }),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPhoneContactsTab() {
    return Obx(() {
      if (controller.contacts.isEmpty) {
        return const Center(child: Text("No contacts found. Make sure permissions are granted."));
      }
      return ListView.builder(
        itemCount: controller.contacts.length,
        itemBuilder: (context, index) {
          final Contact contact = controller.contacts[index];
          final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
          bool isSelected = _selectedMembers.containsKey(contact.id);

          return _buildUserListTile(
            title: contact.displayName?? " ",
            subtitle: phone,
            trailingIcon: isSelected ? Icons.check_circle : Icons.add_circle_outline,
            isSelected: isSelected,
            onTap: () => _toggleSelection({
              'uid': contact.id,
              'name': contact.displayName,
              'phone': phone,
              'avatar': 'https://ui-avatars.com/api/?name=${contact.displayName}',
              'isAppUser': false,
            }),
          );
        },
      );
    });
  }

  Widget _buildUserListTile({
    required String title,
    required String subtitle,
    String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
    IconData trailingIcon = Icons.add_circle_outline,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null ? Text(title[0]) : null,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Icon(
        isSelected ? Icons.check_circle : trailingIcon,
        color: isSelected ? Colors.green : Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildConfirmButton() {
    if (_selectedMembers.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D5CFF),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () async {
          try {
            final selected = _selectedMembers.values.toList();

            await controller.addSelectedMembers(selected);

            Get.snackbar(
              "Success",
              "Members added successfully",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            Get.back(result: true);

          } catch (e) {
            Get.snackbar(
              "Error",
              e.toString(),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        child: Text('Confirm (${_selectedMembers.length} Members)',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}