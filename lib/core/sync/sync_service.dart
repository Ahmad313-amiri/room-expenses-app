import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/datasources/expense_remote_datasource.dart';
import '../../features/expenses/domain/entities/expense.dart';

class SyncService {
  final ExpenseLocalDataSource local;
  final ExpenseRemoteDataSource remote;

  SyncService({
    required this.local,
    required this.remote,
  });

  Future<void> syncPendingExpenses() async {
    final expenses = await local.getPendingExpenses();

    for (final expense in expenses) {
      try {
        if (expense.isDeleted) {
          await remote.deleteExpense(expense.id);
        } else {
          await remote.upsertExpense(expense);
        }

        await local.markAsSynced(expense.id);
      } catch (e) {
        // اگر شکست خورد، رها کن
        // دوباره در sync بعدی تلاش می‌شود
      }
    }
  }
}
