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
    ever(_networkService.isConnected, (connected) {
      if (!connected) {
        errorMessage.value = 'You are offline. Showing cached data.';
      } else {
        errorMessage.value = '';
        if (activities.isNotEmpty) refreshAll();
      }
    });
  }

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

    // استریم هزینه‌ها به صورت لیست Activity
    Stream<List<Activity>> expensesStream = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .timeout(const Duration(seconds: 15))
        .map((snapshot) => snapshot.docs
        .map((e) => ActivityModel.fromExpense(e).toEntity())
        .toList())
        .onErrorReturnWith((error, stackTrace) {
      AppLogger.e('Expenses stream error (returning empty list)', error);
      return <Activity>[];
    });

    // استریم تسویه‌ها به صورت لیست Activity
    Stream<List<Activity>> settlementsStream = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .snapshots()
        .timeout(const Duration(seconds: 15))
        .map((snapshot) => snapshot.docs
        .map((e) => ActivityModel.fromSettlement(e).toEntity())
        .toList())
        .onErrorReturnWith((error, stackTrace) {
      AppLogger.e('Settlements stream error (returning empty list)', error);
      return <Activity>[];
    });

    bool hasEmitted = false;
    _combinedSubscription = CombineLatestStream.combine2(
      expensesStream,
      settlementsStream,
          (expenses, settlements) {
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

    // Fallback: اگر ۳ ثانیه هیچ داده‌ای نیامد، لودینگ را تمام کن
    Future.delayed(const Duration(seconds: 3), () {
      if (!hasEmitted && isLoading.value == true) {
        isLoading.value = false;
        if (activities.isEmpty) {
          errorMessage.value = 'No activities found or network is slow.';
        }
      }
    });
  }

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

      final groupsSnapshot = await _firestore
          .collection('groups')
          .where('members.$uid', isEqualTo: true)
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

  Future<void> _calculateBalancesEfficiently(List<Activity> allActivities, String uid) async {
    double youAreOwed = 0.0;
    double youOwe = 0.0;

    for (var activity in allActivities) {
      if (activity.type == ActivityType.expense) {
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