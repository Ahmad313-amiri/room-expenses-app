import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/error_handler.dart';
import '../controller/group_controller.dart';
import 'groups_details_page.dart';
import 'groups_not_found.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GroupsController>()) {
      Get.put(GroupsController(
        searchUsersUseCase: Get.find(),
        getGroupsUseCase: Get.find(),
        createGroupUseCase: Get.find(),
        addMemberUseCase: Get.find(),
        deleteGroupUseCase: Get.find(),
        getMembersUseCase: Get.find(),
        remoteDataSource: Get.find(),
        updateMemberStatusUseCase: Get.find(),
        getMembersPaginatedUseCase: Get.find(),
      ));
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
            onPressed: () => Get.toNamed('/create-group'),
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
                // نمایش خطا (اگر خطایی وجود داشته باشد و لیست خالی باشد)
                if (controller.groups.isEmpty && controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            onPressed: () => controller.refreshGroups(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // در حال بارگذاری اولیه – نمایش placeholder (اسکلت)
                if (controller.isLoading.value && controller.groups.isEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 3,
                    itemBuilder: (context, index) => const ShimmerGroupCard(),
                  );
                }

                // بعد از بارگذاری، اگر لیست خالی بود
                if (controller.groups.isEmpty) {
                  return const GroupsNotFound();
                }

                // نمایش لیست واقعی گروه‌ها با padding پایین برای اسکرول کامل
                return Scrollbar(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: controller.groups.length,
                    itemBuilder: (context, index) {
                      final group = controller.groups[index];
                      return _buildGroupCard(group);
                    },
                  ),
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
        onChanged: controller.filterGroups,
      ),
    );
  }

  Widget _buildGroupCard(dynamic group) {
    final hasCoverImage = group.coverImageUrl != null &&
        group.coverImageUrl is String &&
        group.coverImageUrl.isNotEmpty;

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
                backgroundImage: hasCoverImage
                    ? NetworkImage(group.coverImageUrl) as ImageProvider
                    : null,
                child: !hasCoverImage
                    ? const Icon(Icons.group, size: 30, color: Colors.blue)
                    : null,
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
                  if (group.id != null && group.id.isNotEmpty) {
                    Get.to(() => GroupDetailScreen(groupId: group.id));
                  } else {
                    ErrorHandler.handleError('Error', 'Invalid group data');
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

class ShimmerGroupCard extends StatelessWidget {
  const ShimmerGroupCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
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
              Row(
                children: List.generate(
                  3,
                      (index) => Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
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