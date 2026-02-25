import '../../domain/entities/expense.dart';

abstract class ExpenseLocalDataSource {
  Future<void> saveExpense(Expense expense);

  Future<List<Expense>> getAllExpenses();

  Future<List<Expense>> getPendingExpenses();

  Future<void> markAsSynced(String id);

  Future<void> softDelete(String id);

  Stream<List<Expense>> watchExpenses();
}
