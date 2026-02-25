import 'package:flutter/material.dart';

class SelectMembersScreen extends StatefulWidget {
  const SelectMembersScreen({super.key});

  @override
  State<SelectMembersScreen> createState() => _SelectMembersScreenState();
}

class _SelectMembersScreenState extends State<SelectMembersScreen> {
  final List<Map<String, dynamic>> _allContacts = [
    {'name': 'Alex Thompson', 'email': 'alex.t@example.com', 'selected': true, 'initial': 'A'},
    {'name': 'Beth Harman', 'email': 'beth.h@example.com', 'selected': false, 'initial': 'B'},
    {'name': 'Brooke Shields', 'email': 'brooke@example.com', 'selected': false, 'initial': 'B'},
    {'name': 'Jordan Lee', 'email': 'jordan.lee@example.com', 'selected': true, 'initial': 'J'},
    {'name': 'Taylor Swift', 'email': 'taylor.s@example.com', 'selected': true, 'initial': 'T'},
  ];

  List<Map<String, dynamic>> _filteredContacts = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _filteredContacts = _allContacts;
  }

  void _showCreateMemberModal(BuildContext context) {
    // Show a bottom sheet modal for creating a new member
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to adjust when the keyboard is shown
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Padding to avoid keyboard overlap
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take minimum height needed
          children: [
            const Text(
              'Create New Member',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Avatar section, optional image
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFF1F2F6),
              child: Icon(Icons.person_add_alt_1, size: 40, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            // Full name text field
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            // Phone number text field (optional)
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 24),
            // Create & Add button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context), // Close modal on press
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Primary button color
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Create & Add to Group',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  void _filterSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts
            .where((c) =>
        c['name'].toLowerCase().contains(query.toLowerCase()) ||
            c['email'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelectAll(bool? select) {
    setState(() {
      for (var contact in _filteredContacts) {
        contact['selected'] = select ?? false;
      }
    });
  }

  Future<bool> _showDiscardDialog(BuildContext context) async {
    final selectedCount = _allContacts.where((c) => c['selected']).length;
    if (selectedCount == 0) return true;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Discard Selection?'),
          ],
        ),
        content: Text(
            'You have selected $selectedCount members. If you leave now, these changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Keep Editing', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final selectedContacts =
    _allContacts.where((c) => c['selected']).toList();

    bool isAllSelected = _filteredContacts.isNotEmpty &&
        _filteredContacts.every((c) => c['selected']);

     return WillPopScope(
      // Disable default back button alert and handle manually
       onWillPop: () async {
         // Show discard confirmation before popping
         return await _showDiscardDialog(context); // prevent default pop
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            // Back arrow button now opens the modal
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
            onPressed: () async {
              if (await _showDiscardDialog(context)) {
              Navigator.pop(context); // Only pop if confirmed
              }
            },
          ),
          title: const Text(
            'Select Members',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            TextButton(
              // Cancel button also opens the same modal
              onPressed: () {
                _showCreateMemberModal(context);
              },
              child: const Text('New Member', style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
          ],
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نوار جستجو
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: _filterSearch,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            // افراد انتخاب شده
            if (selectedContacts.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: selectedContacts.length,
                  itemBuilder: (context, index) =>
                      _buildSelectedAvatar(selectedContacts[index]),
                ),
              ),
            // Select All header
            if (_filteredContacts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_filteredContacts.length} Results Found',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => _toggleSelectAll(!isAllSelected),
                      child: Row(
                        children: [
                          Text(isAllSelected ? 'Deselect All' : 'Select All',
                              style: const TextStyle(
                                  color: Colors.blue, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Icon(
                            isAllSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            // لیست مخاطبین
            Expanded(
              child: _filteredContacts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) =>
                    _buildContactTile(_filteredContacts[index]),
              ),
            ),
            // دکمه پایین
            _buildBottomButton(selectedContacts.length),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAvatar(Map<String, dynamic> contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => setState(() => contact['selected'] = false),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: Colors.blue, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(contact['name'].split(' ')[0],
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildContactTile(Map<String, dynamic> contact) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
        ),
        title: Text(contact['name'],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle:
        Text(contact['email'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: Icon(
          contact['selected'] ? Icons.check_circle : Icons.radio_button_unchecked,
          color: contact['selected'] ? Colors.blue : Colors.grey[300],
          size: 26,
        ),
        onTap: () {
          setState(() {
            contact['selected'] = !contact['selected'];
          });
        },
      ),
    );
  }

  Widget _buildBottomButton(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: count > 0 ? () {} : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D5CFF),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Add $count Members',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No contacts found for "$_searchQuery"',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
