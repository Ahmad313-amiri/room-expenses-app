
import '../repository/expense_repository.dart';
class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<void> call(String groupId, String expenseId) {
    return repository.deleteExpense(groupId, expenseId);
  }
}