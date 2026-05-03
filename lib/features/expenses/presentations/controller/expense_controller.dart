// lib/features/expenses/presentations/controller/expense_controller.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../groups/domain/entities/member_entity.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/create_expense_usecase.dart';

class GroupExpenseSplitController extends GetxController {
  final AddExpenseUseCase addExpenseUseCase;

  GroupExpenseSplitController({required this.addExpenseUseCase});

  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  var splitMethod = 'Equally'.obs;
  var participantIds = <String>[].obs;
  var customShares = <String, double>{}.obs;        // for Percentage (value in percent) and Custom (value in amount)
  var shareCounts = <String, double>{}.obs;         // for Shares method (number of shares)
  var selectedPayerId = ''.obs;
  var isLoading = false.obs;

  late List<MemberEntity> members;
  late String groupId;

  void init(String groupId, List<MemberEntity> members) {
    this.groupId = groupId;
    this.members = members;
    participantIds.value = members.map((m) => m.userId).toList();
    customShares.value = {for (var m in members) m.userId: 0.0};
    shareCounts.value = {for (var m in members) m.userId: 1.0}; // default 1 share per person
    selectedPayerId.value = members.first.userId;
    AppLogger.i('Expense controller initialized for group $groupId');
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
      case 'Shares':
      // مجموع سهام
        double totalShares = 0;
        for (var id in active) {
          totalShares += shareCounts[id] ?? 0;
        }
        if (totalShares <= 0) return {};
        for (var id in active) {
          final share = shareCounts[id] ?? 0;
          shares[id] = total * (share / totalShares);
        }
        break;
    }
    return shares;
  }

  double get calculatedTotal => calculateShares().values.fold(0.0, (s, v) => s + v);

  bool get isSplitValid {
    final total = totalAmount;
    if (total <= 0) return false;
    if (participantIds.isEmpty) return false;
    return (calculatedTotal - total).abs() < 0.01;
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
      case 'Shares':
      // وقتی متد تغییر می‌کند، نیازی به تنظیم مقدار اولیه نیست (قبلاً 1.0 است)
        shareCounts.refresh();
        break;
      default:
        break;
    }
    // Refresh observables
    customShares.refresh();
    shareCounts.refresh();
  }

  Future<void> saveExpense(BuildContext context) async {
    if (isLoading.value) return;

    if (!isSplitValid) {
      ErrorHandler.handleError('Invalid Split', 'Total shares do not match the total amount');
      return;
    }

    if (groupId.isEmpty) {
      ErrorHandler.handleError('Missing Data', 'Group ID is missing');
      return;
    }

    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      ErrorHandler.handleValidationError('Please enter a description');
      return;
    }

    final amount = totalAmount;
    if (amount <= 0) {
      ErrorHandler.handleValidationError('Amount must be greater than zero');
      return;
    }

    final shares = calculateShares();
    final paidBy = <String, double>{selectedPayerId.value: amount};

    final expense = Expense(
      id: '',
      amount: amount,
      description: description,
      date: DateTime.now(),
      createdBy: selectedPayerId.value,
      scope: ExpenseScope.group,
      groupId: groupId,
      paidBy: paidBy,
      split: shares,
    );

    isLoading.value = true;

    try {
      await addExpenseUseCase(expense);
      AppLogger.i('Expense saved in group $groupId');
      ErrorHandler.showSuccess('Success', 'Expense added successfully');
      await Future.delayed(const Duration(milliseconds: 400));
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, stack) {
      AppLogger.e('Failed to save expense', e, stack);
      final message = ErrorHandler.getUserFriendlyException(e);
      ErrorHandler.handleError('Save Failed', message);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}