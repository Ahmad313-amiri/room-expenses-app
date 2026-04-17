import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<void> call(Expense expense) {
    return repository.addExpense(expense);
  }
}