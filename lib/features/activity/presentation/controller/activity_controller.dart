import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../../core/util/net_work.dart';

import '../../../auth/data/repository/authentication_repository.dart';
import '../../data/models/activity_model.dart';
import '../../domain/entity/activity.dart';

class ActivityController extends GetxController {
  var activities = <Activity>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var totalYouAreOwed = 0.0.obs;
  var totalYouOwe = 0.0.obs;

  StreamSubscription? _combinedSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find<NetworkService>();

  String? get currentUserId {
    final authRepo = Get.find<AuthenticationRepository>();
    return authRepo.firebaseUser.value?.uid;
  }

  @override
  void onInit() {
    super.onInit();
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    // استفاده از NetworkService به جای connectivity_plus مستقیم
    ever(_networkService.isConnected, (connected) {
      if (!connected) {
        errorMessage.value = 'You are offline. Showing cached data.';
      } else {
        errorMessage.value = '';
        if (activities.isNotEmpty) refreshAll();
      }
    });
  }

  /// Load activities for a specific group (used in group detail screen)
  Future<void> loadActivities(String groupId) async {
    if (groupId.isEmpty) {
      isLoading.value = false;
      errorMessage.value = 'Group ID is missing';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';

    if (!_networkService.isOnline) {
      isLoading.value = false;
      errorMessage.value = 'No internet connection. Cannot load activities.';
      return;
    }

    await _combinedSubscription?.cancel();

    final expensesStream = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .timeout(const Duration(seconds: 15))
        .handleError((e) {
      AppLogger.e('Expenses stream error', e);
      return Stream.empty();
    });

    final settlementsStream = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .snapshots()
        .timeout(const Duration(seconds: 15))
        .handleError((e) {
      AppLogger.e('Settlements stream error', e);
      return Stream.empty();
    });

    bool hasEmitted = false;
    _combinedSubscription = CombineLatestStream.combine2(
      expensesStream,
      settlementsStream,
          (expenseSnap, settleSnap) {
        final expenses = expenseSnap.docs
            .map((e) => ActivityModel.fromExpense(e).toEntity())
            .toList();
        final settlements = settleSnap.docs
            .map((e) => ActivityModel.fromSettlement(e).toEntity())
            .toList();
        final all = [...expenses, ...settlements];
        all.sort((a, b) => b.date.compareTo(a.date));
        return all;
      },
    ).listen((combinedList) {
      activities.value = combinedList;
      if (!hasEmitted) {
        hasEmitted = true;
        isLoading.value = false;
      }
      errorMessage.value = '';
    }, onError: (error) {
      isLoading.value = false;
      errorMessage.value = 'Error: ${ErrorHandler.getUserFriendlyException(error)}';
    });

    // Timeout fallback
    Future.delayed(const Duration(seconds: 3), () {
      if (!hasEmitted && isLoading.value == true) {
        isLoading.value = false;
        if (activities.isEmpty) {
          errorMessage.value = 'No activities found or network is slow.';
        }
      }
    });
  }

  /// Fetch all activities across all groups for home screen
  Future<void> fetchAllActivities({bool initialLoad = false}) async {
    if (!_networkService.isOnline) {
      if (!initialLoad) {
        errorMessage.value = 'No internet connection. Showing cached data.';
      }
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('User not logged in');

      // Get user's groups - but we don't want to depend on GroupsController
      // Instead, fetch groups from Firestore directly
      final groupsSnapshot = await _firestore
          .collection('groups')
          .where('members.$uid', isEqualTo: true) // requires member array field
          .get()
          .timeout(const Duration(seconds: 10));

      final groupIds = groupsSnapshot.docs.map((doc) => doc.id).toList();

      if (groupIds.isEmpty) {
        activities.clear();
        totalYouAreOwed.value = 0.0;
        totalYouOwe.value = 0.0;
        isLoading.value = false;
        return;
      }

      final futures = groupIds.map((groupId) => _fetchActivitiesFromGroup(groupId)).toList();
      final results = await Future.wait(futures);
      final allActivities = results.expand((list) => list).toList();
      allActivities.sort((a, b) => b.date.compareTo(a.date));

      activities.value = allActivities;
      await _calculateBalancesEfficiently(allActivities, uid);
      isLoading.value = false;
    } catch (e, stack) {
      AppLogger.e('fetchAllActivities error', e, stack);
      isLoading.value = false;
      if (!initialLoad) {
        errorMessage.value = ErrorHandler.getUserFriendlyException(e);
      }
    }
  }

  Future<List<Activity>> _fetchActivitiesFromGroup(String groupId) async {
    try {
      final expensesSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('expenses')
          .where('isDeleted', isEqualTo: false)
          .get()
          .timeout(const Duration(seconds: 10));

      final settlementsSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('settlements')
          .get()
          .timeout(const Duration(seconds: 10));

      final expenses = expensesSnapshot.docs
          .map((e) => ActivityModel.fromExpense(e).toEntity())
          .toList();
      final settlements = settlementsSnapshot.docs
          .map((e) => ActivityModel.fromSettlement(e).toEntity())
          .toList();
      return [...expenses, ...settlements];
    } catch (e) {
      AppLogger.e('Error fetching activities for group $groupId', e);
      return [];
    }
  }

  /// Efficient balance calculation using data already loaded in activities
  Future<void> _calculateBalancesEfficiently(List<Activity> allActivities, String uid) async {
    double youAreOwed = 0.0;
    double youOwe = 0.0;

    for (var activity in allActivities) {
      if (activity.type == ActivityType.expense) {
        // For expenses, we need the split details. Instead of fetching each,
        // we could store split data in ActivityModel. But for V1, fetch once.
        try {
          final doc = await _firestore
              .collection('groups')
              .doc(activity.groupId)
              .collection('expenses')
              .doc(activity.id)
              .get();
          if (doc.exists) {
            final data = doc.data()!;
            final paidBy = Map<String, dynamic>.from(data['paidBy'] ?? {});
            final split = Map<String, dynamic>.from(data['split'] ?? {});
            final payerId = paidBy.keys.firstOrNull;
            if (payerId == uid) {
              for (var entry in split.entries) {
                if (entry.key != uid) {
                  youAreOwed += (entry.value as num).toDouble();
                }
              }
            } else {
              if (split.containsKey(uid)) {
                youOwe += (split[uid] as num).toDouble();
              }
            }
          }
        } catch (e) {
          AppLogger.e('Error fetching split for expense ${activity.id}', e);
        }
      } else if (activity.type == ActivityType.settlement) {
        if (activity.from == uid) {
          youOwe += activity.amount ?? 0.0;
        } else if (activity.to == uid) {
          youAreOwed += activity.amount ?? 0.0;
        }
      }
    }

    totalYouAreOwed.value = youAreOwed;
    totalYouOwe.value = youOwe;
  }

  Future<void> refreshAll() async {
    await fetchAllActivities();
  }

  @override
  void onClose() {
    _combinedSubscription?.cancel();
    super.onClose();
  }
}