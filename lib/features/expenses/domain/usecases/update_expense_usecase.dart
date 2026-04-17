import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<void> call(Expense expense) {
    return repository.updateExpense(expense);
  }
}