import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../domain/entities/expense.dart';
import '../model/expense_model.dart';

/// Remote data source for expense-related Firebase operations.
/// Handles save, delete, and real-time watching of expenses.
class ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  ExpenseRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses');
  }

  /// Saves (creates or updates) an expense.
  /// Throws user-friendly exception on failure.
  Future<void> saveExpense(String groupId, Expense expense) async {
    try {
      if (groupId.isEmpty) {
        throw Exception('Group ID cannot be empty');
      }
      if (expense.amount <= 0) {
        throw Exception('Amount must be greater than zero');
      }
      if (expense.description.trim().isEmpty) {
        throw Exception('Description is required');
      }

      final model = ExpenseModel.fromEntity(expense);


      await _collection(groupId)
          .doc(expense.id)
          .set(model.toFirestore(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 15));

      AppLogger.i('Expense saved: ${expense.id} in group $groupId');
    } catch (e, stack) {
      AppLogger.e('Failed to save expense', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  /// Soft-deletes an expense by setting isDeleted = true.
  /// V1: hard delete is not used because we want to keep history.
  Future<void> deleteExpense(String groupId, String expenseId) async {
    try {
      await _collection(groupId)
          .doc(expenseId)
          .update({'isDeleted': true})
          .timeout(const Duration(seconds: 15));

      AppLogger.i('Expense soft-deleted: $expenseId');
    } catch (e, stack) {
      AppLogger.e('Failed to delete expense', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  /// Real-time stream of expenses for a group.
  /// Automatically filters out soft-deleted expenses (isDeleted != true).
  Stream<List<Expense>> watchExpenses(String groupId) {
    try {
      final stream = _collection(groupId)
          .where('isDeleted', isEqualTo: false)
          .snapshots()
          .timeout(const Duration(seconds: 10))
          .map((snapshot) => snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc).toEntity())
          .toList());

      AppLogger.i('Watching expenses for group $groupId');
      return stream;
    } catch (e, stack) {
      AppLogger.e('Error setting up expense stream', e, stack);
      // Return empty stream instead of throwing, to keep UI responsive
      return Stream.value([]);
    }
  }
}