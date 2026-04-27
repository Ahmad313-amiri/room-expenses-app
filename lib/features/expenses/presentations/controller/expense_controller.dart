// lib/features/expenses/presentation/controllers/group_expense_split_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../groups/domain/entities/member_entity.dart';
import '../../../home/presentation/pages/activity_page.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/create_expense_usecase.dart';


class GroupExpenseSplitController extends GetxController {
  final AddExpenseUseCase addExpenseUseCase;

  GroupExpenseSplitController({required this.addExpenseUseCase});

  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  // Reactive state
  var splitMethod = 'Equally'.obs;
  var participantIds = <String>[].obs;
  var customShares = <String, double>{}.obs;
  var selectedPayerId = ''.obs;

  late List<MemberEntity> members;
  late String groupId;

  void init(String groupId, List<MemberEntity> members) {
    this.groupId = groupId;
    this.members = members;
    participantIds.value = members.map((m) => m.userId).toList();
    customShares.value = {for (var m in members) m.userId: 0.0};
    selectedPayerId.value = members.first.userId;
  }

  double get totalAmount => double.tryParse(amountController.text) ?? 0.0;

  Map<String, double> calculateShares() {
    final total = totalAmount;
    if (total <= 0) return {};
    final active = participantIds;
    final Map<String, double> shares = {};

    switch (splitMethod.value) {
      case 'Equally':
        final perPerson = total / active.length;
        for (var id in active) shares[id] = perPerson;
        break;
      case 'Percentage':
        for (var id in active) {
          final percent = customShares[id] ?? 0.0;
          shares[id] = total * (percent / 100.0);
        }
        break;
      case 'Custom':
        for (var id in active) {
          shares[id] = customShares[id] ?? 0.0;
        }
        break;
    }
    return shares;
  }

  double get calculatedTotal => calculateShares().values.fold(0.0, (s, v) => s + v);

  bool get isSplitValid {
    final total = totalAmount;
    return total > 0 && participantIds.isNotEmpty && (calculatedTotal - total).abs() < 0.01;
  }

  void updateCustomSharesForMethod() {
    final total = totalAmount;
    if (total <= 0) return;
    final active = participantIds;
    if (active.isEmpty) return;

    switch (splitMethod.value) {
      case 'Percentage':
        final percentPerPerson = 100.0 / active.length;
        for (var id in active) customShares[id] = percentPerPerson;
        break;
      case 'Custom':
        final amountPerPerson = total / active.length;
        for (var id in active) customShares[id] = amountPerPerson;
        break;
      default:
        break;
    }
    customShares.refresh();
  }

  Future<void> saveExpense() async {
    print("GROUP ID = $groupId");
    if (!isSplitValid) {
      Get.snackbar('Error', 'Total shares do not match the total amount');
      return;
    }

    if (groupId.isEmpty) {
      Get.snackbar("Error", "Group ID missing");
      return;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a description');
      return;
    }

    final amount = totalAmount;
    final description = descriptionController.text.trim();
    final shares = calculateShares();

    final paidBy = <String, double>{
      selectedPayerId.value: amount,
    };
    print("🔥 CREATE EXPENSE CALLED");
    final expenseId = FirebaseFirestore.instance.collection('groups')
        .doc(groupId)
        .collection('expenses')
        .doc()
        .id;

    final expense = Expense(
      id: expenseId,
      amount: amount,
      description: description,
      date: DateTime.now(),
      createdBy: selectedPayerId.value,
      scope: ExpenseScope.group,
      groupId: groupId,
      paidBy: paidBy,
      split: shares,
    );

    try {
      await addExpenseUseCase(expense);

      print("✅ EXPENSE SAVED SUCCESSFULLY");

      Get.offAll(() => ActivityScreen());

      Future.delayed(const Duration(milliseconds: 200), () {
        Get.snackbar(
          'Success',
          'Expense saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      });

    } catch (e) {
    Get.snackbar(
    'Error',
    'Failed to save expense: $e',
    backgroundColor: Colors.red,
    colorText: Colors.white,
    );
    }
    // Get.back();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}