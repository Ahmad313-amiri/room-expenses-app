import 'package:isar/isar.dart';
import '../../../../core/database/isar_service.dart';
import '../../domain/entities/expense.dart';
import '../model/isar/expense_isar.dart';

class ExpenseLocalDataSource {
  Future<void> saveExpense(ExpenseIsar expense) async {
    final isar = await IsarService.openIsar();

    await isar.writeTxn(() async {
      await isar.expenseIsars.put(expense);
    });
  }

  Future<List<ExpenseIsar>> getAllExpenses() async {
    final isar = await IsarService.openIsar();

    return await isar.expenseIsars.where().findAll();
  }

  Stream<List<ExpenseIsar>> watchExpenses() async* {
    final isar = await IsarService.openIsar();

    yield* isar.expenseIsars.where().watch(fireImmediately: true);
  }

  Future<void> softDelete(String id) async {
    final isar = await IsarService.openIsar();

    final expense =
    await isar.expenseIsars.filter().idEqualTo(id).findFirst();

    if (expense != null) {
      await isar.writeTxn(() async {
        expense.isDeleted = true;
        expense.syncStatus = SyncStatus.pending;
        await isar.expenseIsars.put(expense);
      });
    }
  }
}
