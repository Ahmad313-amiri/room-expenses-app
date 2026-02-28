// lib/features/expenses/domain/repositories/expense_repository.dart

import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<void> createExpense(Expense expense);

  Future<void> updateExpense(Expense expense);

  Future<void> deleteExpense(String expenseId);

  Stream<List<Expense>> watchExpenses();

  Stream<List<Expense>> watchGroupExpenses(String groupId);
}
