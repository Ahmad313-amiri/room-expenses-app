import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/group_controller.dart';


void showCreateMemberModal(BuildContext context, String groupId) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController identifierController = TextEditingController();
  final GroupsController controller = Get.find<GroupsController>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create New Member',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFF1F2F6),
              child: Icon(Icons.person_add_alt_1, size: 40, color: Colors.blue),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: identifierController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email or Phone (Optional)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.contact_mail_outlined),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final identifier = identifierController.text.trim();

                  if (name.isEmpty) {
                    Get.snackbar("Error", "Please enter a name");
                    return;
                  }

                  await controller.addMemberToGroup(
                    groupId,
                    identifier,
                    name,
                  );

                  Get.back();

                  nameController.dispose();
                  identifierController.dispose();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Create & Add to Group',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}