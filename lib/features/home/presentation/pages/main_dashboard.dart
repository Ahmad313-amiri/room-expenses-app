// lib/features/home/presentation/pages/main_dashboard.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../activity/presentation/activity_widget.dart';
import '../../../activity/presentation/controller/activity_controller.dart';
import '../../../activity/domain/entity/activity.dart';
import '../../../groups/presentation/controller/group_controller.dart';
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
  bool _dataFetchStarted = false;
  bool _groupsLoadError = false;
  bool _activitiesLoadError = false;

  @override
  void initState() {
    super.initState();
    groupController = Get.find<GroupsController>();
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }
    activityController = Get.find<ActivityController>();
    _startBackgroundFetch();
  }

  void _startBackgroundFetch() {
    if (_dataFetchStarted) return;
    _dataFetchStarted = true;

    groupController.fetchGroups(initialLoad: true).catchError((e) {
      if (mounted) setState(() => _groupsLoadError = true);
      AppLogger.e('Dashboard groups fetch error', e);
    });

    activityController.fetchAllActivities(initialLoad: true).catchError((e) {
      if (mounted) setState(() => _activitiesLoadError = true);
      AppLogger.e('Dashboard activities fetch error', e);
    });
  }

  Future<void> _onRefresh() async {
    try {
      await Future.wait([
        groupController.refreshGroups(),
        activityController.refreshAll(),
      ]);
      setState(() {
        _groupsLoadError = false;
        _activitiesLoadError = false;
      });
      ErrorHandler.showSuccess('Refreshed', 'Dashboard updated');
    } catch (e) {
      AppLogger.e('Refresh error', e);
      ErrorHandler.handleError('Refresh Failed', ErrorHandler.getUserFriendlyException(e));
    }
  }

  Future<void> _reloadAfterReturn() async {
    // Small delay to allow Firestore to commit the new data
    await Future.delayed(const Duration(milliseconds: 300));
    await activityController.fetchAllActivities(initialLoad: false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Net Standing Card
            Obx(() {
              final owed = activityController.totalYouAreOwed.value;
              final owe = activityController.totalYouOwe.value;
              final net = owed - owe;
              final isLoading = activityController.isLoading.value && owed == 0 && owe == 0 && !_activitiesLoadError;

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
                      if (_activitiesLoadError)
                        Text(
                          'Could not load balance',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        )
                      else if (isLoading)
                        const ShimmerLine(width: 100, height: 24)
                      else
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
                              border: Border.all(color: Colors.white.withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_up, color: Colors.white),
                                SizedBox(width: 6),
                                Text('% increase this month',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
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
              final isLoading = activityController.isLoading.value && owed == 0 && owe == 0 && !_activitiesLoadError;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: isLoading
                          ? const ShimmerCard()
                          : OwedCard(
                        icon: Icons.north_east_outlined,
                        iconColor: Colors.green,
                        owedText: 'you are owed',
                        amount: owed.toStringAsFixed(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isLoading
                          ? const ShimmerCard()
                          : OwedCard(
                        icon: Icons.south_west_rounded,
                        iconColor: Colors.red,
                        owedText: 'you owe',
                        amount: owe.toStringAsFixed(2),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Recent Activity Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Activity',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  GestureDetector(
                    onTap: () => Get.to(() => const ActivityScreen()),
                    child: const Text('View all',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),

            // Recent Activity List
            Expanded(
              child: Obx(() {
                if (_activitiesLoadError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          ErrorHandler.getUserFriendlyException('Failed to load activities'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          onPressed: _onRefresh,
                        ),
                      ],
                    ),
                  );
                }
                if (activityController.isLoading.value && activityController.activities.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final recent = activityController.activities.take(5).toList();
                if (recent.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No expenses or settlements found yet.',
                            style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                        onTap: () async {
                          final groupId = act.groupId;
                          if (groupId.isNotEmpty) {
                            await Get.toNamed('/group-details', arguments: {'groupId': groupId});
                            _reloadAfterReturn();
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
                            icon: act.type == ActivityType.expense
                                ? Icons.receipt_long
                                : Icons.swap_horiz,
                            amount: act.amount ?? 0.0,
                            description: act.type == ActivityType.expense
                                ? (act.description ?? 'Expense')
                                : '${act.from} → ${act.to}',
                            status: act.status ?? '',
                            time: _formatRelativeDate(act.date), // ← improved date
                            title: act.type == ActivityType.expense
                                ? (act.description ?? 'Expense')
                                : 'Settlement',
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

  // Improved relative date formatter
  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      // fallback to exact date
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Shimmer widgets (unchanged)
class ShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  const ShimmerLine({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 40, width: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Container(height: 12, width: 80, color: Colors.grey.shade300),
            const SizedBox(height: 4),
            Container(height: 20, width: 60, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}