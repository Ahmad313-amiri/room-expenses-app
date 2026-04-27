import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomly/features/groups/presentation/pages/groups_details_page.dart';
import 'package:roomly/features/groups/presentation/pages/groups_not_found.dart';

import '../binding/group_binding.dart';
import '../controller/group_controller.dart';
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GroupsController>()) {
      GroupBinding().dependencies();
    }
    final controller = Get.find<GroupsController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Groups', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () => Get.toNamed('/create_group'),
          ),
          const SizedBox(width: 15),
        ],
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshGroups(),
              child: Obx(() {
                if (controller.isLoading.value && controller.groups.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.groups.isEmpty) {
                  return const GroupsNotFound();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.groups.length,
                  itemBuilder: (context, index) {
                    final group = controller.groups[index];
                    return _buildGroupCard(group);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(GroupsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search groups...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged:  controller.filterGroups,
      ),
    );
  }

  Widget _buildGroupCard(dynamic group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.group, size: 30, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name ?? "Unknown Group",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.membersCount ?? 0} members',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MembersAvatars(count: group.membersCount ?? 0),
              ElevatedButton(
                onPressed: () {
                   if (group.id != null) {
                    Get.to(() => GroupDetailScreen(groupId: group.id!));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MembersAvatars extends StatelessWidget {
  final int count;
  const MembersAvatars({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count > 3 ? 4 : count,
            (index) => Align(
          widthFactor: 0.6,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: index == 3 && count > 3 ? Colors.teal : Colors.grey.shade300,
              child: index == 3 && count > 3
                  ? Text(
                '+${count - 3}',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              )
                  : const Icon(Icons.person, size: 12, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}