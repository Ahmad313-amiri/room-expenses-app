import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../activity/presentation/activity_widget.dart';
import '../../../activity/presentation/controller/activity_controller.dart';
import '../../../activity/domain/entity/activity.dart';
import '../../../groups/presentation/controller/group_controller.dart';
import '../widgets/activity_card.dart';
import '../widgets/owed_card.dart';
import 'activity_page.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  late GroupsController groupController;
  late ActivityController activityController;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    groupController = Get.find<GroupsController>();
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }
    activityController = Get.find<ActivityController>();
    activityController .fetchAllActivities(initialLoad: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isInitialLoading = true);
    try {
      await groupController.fetchGroups(initialLoad: true);
      await activityController.fetchAllActivities(initialLoad: true);
    } catch (e) {
      AppLogger.e('Dashboard load error', e);
      ErrorHandler.handleError('Load Error', ErrorHandler.getUserFriendlyException(e));
    }
    if (mounted) setState(() => _isInitialLoading = false);
  }

  Future<void> _onRefresh() async {
    try {
      await groupController.refreshGroups();
      await activityController.refreshAll();
    } catch (e) {
      AppLogger.e('Refresh error', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.person),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Dashboard',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Net Standing Card
            Obx(() {
              final net = activityController.totalYouAreOwed.value - activityController.totalYouOwe.value;
              return Container(
                width: 600,
                margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL NET STANDING', style: TextStyle(color: Colors.grey[200])),
                      Text(
                        '${net >= 0 ? '+' : '-'}\$${net.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: net >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_up, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  '% increase this month',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Owed Cards
            Obx(() {
              final owed = activityController.totalYouAreOwed.value;
              final owe = activityController.totalYouOwe.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 3),
                    child: OwedCard(
                      icon: Icons.north_east_outlined,
                      iconColor: Colors.green,
                      owedText: 'you are owed',
                      amount: owed.toStringAsFixed(2),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18, left: 5),
                      child: OwedCard(
                        icon: Icons.south_west_rounded,
                        iconColor: Colors.red,
                        owedText: 'you owe',
                        amount: owe.toStringAsFixed(2),
                      ),
                    ),
                  ),
                ],
              );
            }),
            // Recent Activity Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  GestureDetector(
                    onTap: () => Get.to(() => const ActivityScreen()),
                    child: const Text('View all', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (activityController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (activityController.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          activityController.errorMessage.value,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          onPressed: _onRefresh,
                        ),
                      ],
                    ),
                  );
                }
                final recent = activityController.activities.take(5).toList();
                if (recent.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No expenses or settlements found yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: recent.length,
                    itemBuilder: (context, index) {
                      final act = recent[index];
                      return GestureDetector(
                        onTap: () {
                          // فعالیت‌ها دارای groupId هستند (در ActivityController بارگذاری می‌شوند)
                          final groupId = act.groupId;
                          if (groupId.isNotEmpty) {
                            Get.toNamed('/group-details', arguments: {'groupId': groupId});
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ActivityCard(
                            icon: act.type == ActivityType.expense ? Icons.receipt_long : Icons.swap_horiz,
                            amount: act.amount ?? 0.0,
                            description: act.type == ActivityType.expense
                                ? act.description ?? ''
                                : '${act.from} → ${act.to}',
                            status: act.status ?? '',
                            time: _formatDate(act.date),
                            title: act.type == ActivityType.expense ? act.description ?? 'Expense' : 'Settlement',
                            iconColor: act.type == ActivityType.expense ? Colors.blue : Colors.green,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Today';
    } else if (date.day == now.subtract(const Duration(days: 1)).day) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}