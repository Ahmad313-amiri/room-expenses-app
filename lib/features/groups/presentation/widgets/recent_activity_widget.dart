import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/app_logger.dart';
import '../../../activity/domain/entity/activity.dart';
import '../../../activity/presentation/controller/activity_controller.dart';

import '../../../home/presentation/pages/activity_page.dart';
import '../controller/group_controller.dart';

class RecentActivityWidget extends StatefulWidget {
  final String groupId;
  const RecentActivityWidget({super.key, required this.groupId});

  @override
  State<RecentActivityWidget> createState() => _RecentActivityWidgetState();
}

class _RecentActivityWidgetState extends State<RecentActivityWidget> {
  final ActivityController activityController = Get.find<ActivityController>();
  final GroupsController groupsController = Get.find<GroupsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      activityController.loadActivities(widget.groupId);
    });
    AppLogger.d('RecentActivityWidget initialized for group ${widget.groupId}');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (activityController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (activityController.errorMessage.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(
                activityController.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  activityController.loadActivities(widget.groupId);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final recentActivities = activityController.activities.take(3).toList();

      final Map<String, String> memberNames = {};
      for (var member in groupsController.members) {
        memberNames[member.userId] = member.name;
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (activityController.activities.isNotEmpty)
                  TextButton(
                    onPressed: () {
              Get.to(() => ActivityScreen(groupId: widget.groupId));
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
          ),
          if (recentActivities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No activity yet",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Column(
              children: recentActivities.map((activity) => _buildActivityCard(activity, memberNames)).toList(),
            ),
        ],
      );
    });
  }

  Widget _buildActivityCard(Activity activity, Map<String, String> memberNames) {
    if (activity.type == ActivityType.expense) {
      final payerName = memberNames[activity.createdBy] ?? activity.createdBy ?? 'Someone';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.description ?? 'Expense',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Paid by $payerName",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              "\$${activity.amount?.toStringAsFixed(2) ?? '0.00'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      final fromName = memberNames[activity.from] ?? activity.from ?? 'Someone';
      final toName = memberNames[activity.to] ?? activity.to ?? 'Someone';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.handshake, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$fromName → $toName",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              "\$${activity.amount?.toStringAsFixed(2) ?? '0.00'}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }
}