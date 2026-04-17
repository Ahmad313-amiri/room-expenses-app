import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);

  Future<void> updateExpense(Expense expense);

  Future<void> deleteExpense(String groupId, String expenseId);

  Stream<List<Expense>> watchGroupExpenses(String groupId);
}