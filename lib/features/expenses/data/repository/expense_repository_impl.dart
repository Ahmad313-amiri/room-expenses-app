import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repository/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';


/// Implementation of ExpenseRepository using Firebase remote data source.
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remote;

  ExpenseRepositoryImpl(this.remote);

  @override
  Future<void> addExpense(Expense expense) async {
    try {
      await remote.saveExpense(expense.groupId, expense);
      AppLogger.i('Expense added: ${expense.id}');
    } catch (e, stack) {
      AppLogger.e('Failed to add expense', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    try {
      await remote.saveExpense(expense.groupId, expense);
      AppLogger.i('Expense updated: ${expense.id}');
    } catch (e, stack) {
      AppLogger.e('Failed to update expense', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Future<void> deleteExpense(String groupId, String expenseId) async {
    try {
      await remote.deleteExpense(groupId, expenseId);
      AppLogger.i('Expense deleted: $expenseId');
    } catch (e, stack) {
      AppLogger.e('Failed to delete expense', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) {
    try {
      return remote.watchExpenses(groupId);
    } catch (e, stack) {
      AppLogger.e('Failed to watch expenses', e, stack);
      // Return empty stream to avoid crashes
      return Stream.value([]);
    }
  }
}