import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomly/features/home/presentation/pages/activity_page.dart';
import '../../../activity/domain/entity/activity.dart';
import '../../../activity/presentation/controller/activity_controller.dart';
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
    activityController.loadActivities(widget.groupId);
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
          child: Text(activityController.errorMessage.value, style: const TextStyle(color: Colors.red)),
        );
      }

      final recentActivities = activityController.activities.take(3).toList();
      // Build a map of userId -> name from groupsController.members
      final Map<String, String> memberNames = {};
      for (var member in groupsController.members) {
        memberNames[member.userId] = member.name;
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 29),
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen()));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text('See All'),
                  ),
                ),
              ],
            ),
          ),
          if (recentActivities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No activity yet"),
            )
          else
            Column(
              children: recentActivities.map((activity) => _buildActivityCard(activity, memberNames)).toList(),
            ),
        ],
      );
    });
  }

  // FIXED: show user name instead of userId
  Widget _buildActivityCard(Activity activity, Map<String, String> memberNames) {
    if (activity.type == ActivityType.expense) {
      final payerName = memberNames[activity.createdBy] ?? activity.createdBy ?? 'Someone';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                    activity.description ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Paid by $payerName",
                    style: const TextStyle(color: Colors.grey),
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
        ),
        child: Row(
          children: [
            const Icon(Icons.handshake, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(child: Text("$fromName → $toName")),
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