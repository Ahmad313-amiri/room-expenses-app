import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/group_controller.dart';

class AcceptInviteScreen extends StatelessWidget {
  const AcceptInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GroupsController controller = Get.find<GroupsController>();
    final String groupId = Get.arguments?['groupId'] ?? '';
    final String userId = Get.arguments?['userId'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Accept Invitation',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : Image.network(
              'https://i.ibb.co/FV9jLsf/accept-invite.png',
              height: 200,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.group_add, size: 100, color: Colors.blue),
            )),
            const SizedBox(height: 24),
            const Text(
              'You have been invited!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join the group to start tracking expenses with your friends.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (groupId.isNotEmpty && userId.isNotEmpty) {
                    await controller.acceptGroupInvitation(
                      groupId: groupId,
                      userId: userId,
                    );
                    Get.offNamed('/group_details', arguments: {'groupId': groupId});
                  } else {
                    Get.snackbar("Error", "Invalid Invitation Data");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D5CFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Accept Invitation',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text('Decline',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}