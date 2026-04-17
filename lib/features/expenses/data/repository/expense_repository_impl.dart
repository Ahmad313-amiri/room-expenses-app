import '../../domain/entities/expense.dart';
import '../../domain/repository/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remote;

  ExpenseRepositoryImpl(this.remote);

  @override
  Future<void> addExpense(Expense expense) async {
    await remote.saveExpense(expense.groupId, expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await remote.saveExpense(expense.groupId, expense);
  }

  @override
  Future<void> deleteExpense(String groupId, String expenseId) async {
    await remote.deleteExpense(groupId, expenseId);
  }

  @override
  Stream<List<Expense>> watchGroupExpenses(String groupId) {
    return remote.watchExpenses(groupId);
  }
}