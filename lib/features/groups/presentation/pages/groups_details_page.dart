import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../activity/presentation/controller/activity_controller.dart';
import '../controller/group_controller.dart';
import '../widgets/group_actions.dart';
import '../widgets/group_header_widget.dart';
import '../widgets/group_balance_widget.dart';
import '../widgets/member_list_widget.dart';
import '../widgets/recent_activity_widget.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late GroupsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<GroupsController>();
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadGroupAndMembers(widget.groupId).catchError((e) {
        ErrorHandler.handleError(
          'Load Error',
          ErrorHandler.getUserFriendlyException(e),
        );
      });
    });
    AppLogger.i('GroupDetailScreen initialized for group ${widget.groupId}');
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
        title: Obx(() {
          final group = controller.currentGroup.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  group?.name ?? 'Group Details',
                  style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.grey, size: 20),
                onPressed: group == null
                    ? null
                    : () => controller.showEditGroupNameDialog(context, group),
              ),
            ],
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => controller.showDeleteGroupDialog(context, widget.groupId),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshGroupDetail(widget.groupId),
        child: Obx(() {
          if (controller.isLoading.value && controller.currentGroup.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final group = controller.currentGroup.value;
          if (group == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Group not found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 30),
                GroupHeaderWidget(
                  group: group,
                  onEditImage: () => controller.showPickerMenu(context, group),
                  imageFile: controller.groupImageFile.value,
                  isLoadingImage: controller.isLoadingImage.value,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.groupImageFile.value == null
                      ? 'Tap to add group photo'
                      : 'Tap to change photo',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                GroupBalanceWidget(
                  balanceText: controller.balanceText.value,
                  memberCount: controller.members.length,
                ),
                const SizedBox(height: 24),
                GroupActionsWidget(controller: controller),
                const SizedBox(height: 32),
                MembersListWidget(
                  members: controller.members,
                  canRemoveMember: controller.canRemoveMember,
                  onRemoveMember: (member) =>
                      controller.showRemoveMemberDialog(context, widget.groupId, member),
                  onAddMember: () => controller.goToAddMembers(),
                ),
                const SizedBox(height: 24),
                RecentActivityWidget(groupId: widget.groupId),
                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }
}