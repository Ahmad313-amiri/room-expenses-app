// activity_controller.dart (نسخه اصلاح شده)

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
  String? _currentGroupId; // برای گروه جاری (در جزئیات گروه)

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
        // اینترنت وصل شد – تلاش برای reconnect استریم
        if (_currentGroupId != null && _currentGroupId!.isNotEmpty) {
          loadActivities(_currentGroupId!);
        } else {
          fetchAllActivities();
        }
      } else if (!_isOnline) {
        errorMessage.value = 'ارتباط اینترنت قطع است. داده‌های قبلی نشان داده می‌شوند.';
      } else {
        errorMessage.value = '';
      }
    });
  }

  // ============================================================
  // بارگذاری فعالیت‌های یک گروه خاص (با استریم زنده و بدون timeout)
  // ============================================================
  Future<void> loadActivities(String groupId) async {
    if (groupId.isEmpty) {
      isLoading.value = false;
      errorMessage.value = 'شناسه گروه معتبر نیست';
      return;
    }

    _currentGroupId = groupId;
    isLoading.value = true;
    errorMessage.value = '';

    if (!_isOnline) {
      isLoading.value = false;
      errorMessage.value = 'بدون اینترنت، امکان بارگذاری نیست. بعد از اتصال مجدد تلاش می‌شود.';
      return;
    }

    // لغو استریم قبلی
    await _combinedSubscription?.cancel();

    // استریم هزینه‌ها (بدون timeout)
    final expensesStream = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .snapshots()
        .handleError((e) {
      // در صورت خطا، خطا را منتشر می‌کنیم تا در listener مدیریت شود
      throw Exception('خطا در بارگذاری هزینه‌ها: $e');
    });

    // استریم تسویه‌ها (بدون timeout)
    final settlementsStream = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .snapshots()
        .handleError((e) {
      throw Exception('خطا در بارگذاری تسویه‌ها: $e');
    });

    bool hasFirstEmission = false;

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
    ).listen(
          (combinedList) {
        activities.value = combinedList;
        if (!hasFirstEmission) {
          hasFirstEmission = true;
          isLoading.value = false;
          errorMessage.value = '';
        }
        // همچنین پس از هر آپدیت، ترازها را مجدد محاسبه کن (برای dashboard)
        if (currentUserId != null) {
          _calculateBalancesFromList(combinedList, currentUserId!);
        }
      },
      onError: (error) {
        isLoading.value = false;
        errorMessage.value = error.toString();
        // استریم بسته شده – دیگر آپدیتی نمی‌آید. کاربر می‌تواند دوباره تلاش کند.
      },
    );
  }

  // محاسبه ترازها از روی لیست فعالیت‌ها (بدون کوئری اضافی)
  Future<void> _calculateBalancesFromList(List<Activity> allActivities, String uid) async {
    double youAreOwed = 0.0;
    double youOwe = 0.0;

    for (var activity in allActivities) {
      if (activity.type == ActivityType.expense) {
        // چون در Activity مدل split و paidBy را نداریم، باید از فایرفستور بخوانیم
        // اما برای جلوگیری از درخواست زیاد، بهتر است در همان لحظه که استریم آمد، اطلاعات split را هم داشته باشیم.
        // راهکار: مدل Activity را گسترش دهیم یا از یک Map کمکی استفاده کنیم.
        // فعلاً همان روش قبلی را با کوئری جداگانه نگه می‌داریم، اما آن را بهینه می‌کنیم.
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
          // خطا را نادیده می‌گیریم تا محاسبه متوقف نشود
        }
      } else if (activity.type == ActivityType.settlement) {
        if (activity.from == uid) youOwe += activity.amount ?? 0.0;
        else if (activity.to == uid) youAreOwed += activity.amount ?? 0.0;
      }
    }

    totalYouAreOwed.value = youAreOwed;
    totalYouOwe.value = youOwe;
  }

  // ============================================================
  // بارگذاری تمام فعالیت‌های کاربر (برای داشبورد) – بدون استریم
  // ============================================================
  Future<void> fetchAllActivities({bool initialLoad = false}) async {
    if (!_isOnline) {
      if (!initialLoad) errorMessage.value = 'بدون اینترنت – داده‌های قبلی نشان داده می‌شوند.';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final uid = currentUserId;
      if (uid == null) throw Exception('کاربر وارد نشده است');

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
      if (!initialLoad) errorMessage.value = 'خطا در بارگذاری: $e';
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
          .map((e) => ActivityModel.fromExpense(e).toEntity())
          .toList();
      final settlements = settlementsSnapshot.docs
          .map((e) => ActivityModel.fromSettlement(e).toEntity())
          .toList();
      return [...expenses, ...settlements];
    } catch (e) {
      print('Error fetching group $groupId: $e');
      return [];
    }
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