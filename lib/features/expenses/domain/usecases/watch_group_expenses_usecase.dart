import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class WatchGroupExpensesUseCase {
  final ExpenseRepository repository;

  WatchGroupExpensesUseCase(this.repository);

  Stream<List<Expense>> call(String groupId) {
    return repository.watchGroupExpenses(groupId);
  }
}