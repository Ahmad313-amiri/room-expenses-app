// lib/features/activity/presentation/controller/activity_controller.dart

import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../auth/data/repository/authentication_repository.dart';
import '../../data/models/activity_model.dart';
import '../../domain/entity/activity.dart';
import '../../../groups/presentation/controller/group_controller.dart';

class ActivityController extends GetxController {
  var activities = <Activity>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  var totalYouAreOwed = 0.0.obs;
  var totalYouOwe = 0.0.obs;

  StreamSubscription? _combinedSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  String? _currentGroupId;

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
    _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      if (!wasOnline && _isOnline) {
        if (_currentGroupId != null && _currentGroupId!.isNotEmpty) {
          loadActivities(_currentGroupId!);
        } else {
          fetchAllActivities();
        }
      } else if (!_isOnline) {
        errorMessage.value = 'No internet connection. Showing cached data.';
      } else {
        errorMessage.value = '';
      }
    });
  }

  // حالت گروه خاص (با استریم زنده)
  Future<void> loadActivities(String groupId) async {
    if (groupId.isEmpty) {
      isLoading.value = false;
      errorMessage.value = 'Invalid group ID';
      return;
    }

    _currentGroupId = groupId;
    isLoading.value = true;
    errorMessage.value = '';

    if (!_isOnline) {
      isLoading.value = false;
      errorMessage.value = 'No internet. Please connect.';
      return;
    }

    await _combinedSubscription?.cancel();

    final expensesStream = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .snapshots()
        .handleError((e) => throw Exception('Expenses stream error: $e'));

    final settlementsStream = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .snapshots()
        .handleError((e) => throw Exception('Settlements stream error: $e'));

    bool hasFirstEmission = false;

    _combinedSubscription = CombineLatestStream.combine2(
      expensesStream,
      settlementsStream,
          (expenseSnap, settleSnap) {
        final expenses = expenseSnap.docs
            .map((e) => ActivityModel.fromExpense(e, groupId).toEntity())
            .toList();
        final settlements = settleSnap.docs
            .map((e) => ActivityModel.fromSettlement(e, groupId).toEntity())
            .toList();
        final all = [...expenses, ...settlements];
        all.sort((a, b) => b.date.compareTo(a.date));
        return all;
      },
    ).listen(
          (combinedList) {
        activities.value = combinedList;
        if (!hasFirstEmission) {
          hasFirstEmission = true;
          isLoading.value = false;
          errorMessage.value = '';
        }
        if (currentUserId != null) {
          _calculateBalancesFromList(combinedList, currentUserId!);
        }
      },
      onError: (error) {
        isLoading.value = false;
        errorMessage.value = error.toString();
      },
    );
  }

  // حالت همه گروه‌ها (داشبورد) – بدون استریم
  Future<void> fetchAllActivities({bool initialLoad = false}) async {
    if (_currentGroupId != null) {
      _currentGroupId = null;
      await _combinedSubscription?.cancel();
      _combinedSubscription = null;
    }

    if (!_isOnline) {
      if (!initialLoad) errorMessage.value = 'No internet – showing cached data.';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('User not logged in');

      final groupsController = Get.find<GroupsController>();
      await groupsController.fetchGroups(initialLoad: true);
      final userGroups = groupsController.groups;

      if (userGroups.isEmpty) {
        activities.clear();
        totalYouAreOwed.value = 0.0;
        totalYouOwe.value = 0.0;
        isLoading.value = false;
        return;
      }

      final futures = userGroups.map((group) => _fetchActivitiesFromGroup(group.id)).toList();
      final results = await Future.wait(futures);
      final allActivities = results.expand((list) => list).toList();
      allActivities.sort((a, b) => b.date.compareTo(a.date));

      activities.value = allActivities;
      await _calculateBalancesFromList(allActivities, uid);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      if (!initialLoad) errorMessage.value = 'Error: ${e.toString()}';
    }
  }

  Future<List<Activity>> _fetchActivitiesFromGroup(String groupId) async {
    try {
      final expensesSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('expenses')
          .get();
      final settlementsSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('settlements')
          .get();

      final expenses = expensesSnapshot.docs
          .map((e) => ActivityModel.fromExpense(e, groupId).toEntity())
          .toList();
      final settlements = settlementsSnapshot.docs
          .map((e) => ActivityModel.fromSettlement(e, groupId).toEntity())
          .toList();
      return [...expenses, ...settlements];
    } catch (e) {
      print('Error fetching group $groupId: $e');
      return [];
    }
  }

  Future<void> _calculateBalancesFromList(List<Activity> allActivities, String uid) async {
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
          // ignore
        }
      } else if (activity.type == ActivityType.settlement) {
        if (activity.from == uid) youOwe += activity.amount ?? 0.0;
        else if (activity.to == uid) youAreOwed += activity.amount ?? 0.0;
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