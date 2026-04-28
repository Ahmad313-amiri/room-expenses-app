import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/error_handler.dart';
import '../../../settelment/presentation/pages/advance_settlment_screen.dart';
import '../controller/group_controller.dart';
import '../pages/split_method.dart';

class GroupActionsWidget extends StatelessWidget {
  final GroupsController controller;
  const GroupActionsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final groupId = controller.groupId; // Fixed: removed .value
                if (groupId.isEmpty) {
                  ErrorHandler.handleError('Error', 'Group not loaded yet');
                  return;
                }
                Get.to(() => AdvancedSettleUpScreen(groupId: groupId));
              },
              icon: const Icon(Icons.handshake_outlined, size: 18),
              label: const Text('Settle Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final groupId = controller.groupId; // Fixed: removed .value
                if (groupId.isEmpty) {
                  ErrorHandler.handleError('Error', 'Group not loaded yet');
                  return;
                }
                Get.to(() => GroupExpenseSplitScreen(
                  groupId: groupId,
                  members: controller.members,
                ));
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}