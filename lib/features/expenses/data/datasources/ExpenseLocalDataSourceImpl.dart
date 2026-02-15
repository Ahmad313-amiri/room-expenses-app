import 'package:isar/isar.dart';
import '../../../../core/database/isar_service.dart';

import '../../domain/entities/expense.dart';
import '../model/isar/expense_isar.dart';
import 'expense_local_datasource.dart';

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  @override
  Future<void> saveExpense(Expense expense) async {
    final isar = await IsarService.openIsar();

    final model = ExpenseIsar.fromEntity(expense);

    await isar.writeTxn(() async {
      await isar.expenseIsars.put(model);
    });
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    final isar = await IsarService.openIsar();

    final data = await isar.expenseIsars
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .sortByDateDesc()
        .findAll();

    return data.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<Expense>> getPendingExpenses() async {
    final isar = await IsarService.openIsar();

    final data = await isar.expenseIsars
        .where()
        .filter()
        .syncStatusEqualTo(SyncStatus.pending)
        .findAll();

    return data.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    final isar = await IsarService.openIsar();

    final expense = await isar.expenseIsars.filter().idEqualTo(id).findFirst();

    if (expense == null) return;

    await isar.writeTxn(() async {
      expense.syncStatus = SyncStatus.synced;
      await isar.expenseIsars.put(expense);
    });
  }

  @override
  Future<void> softDelete(String id) async {
    final isar = await IsarService.openIsar();

    final expense = await isar.expenseIsars.filter().idEqualTo(id).findFirst();

    if (expense == null) return;

    await isar.writeTxn(() async {
      expense.isDeleted = true;
      expense.syncStatus = SyncStatus.pending;
      await isar.expenseIsars.put(expense);
    });
  }

  @override
  Stream<List<Expense>> watchExpenses() async* {
    final isar = await IsarService.openIsar();

    yield* isar.expenseIsars
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((event) => event.map((e) => e.toEntity()).toList());
  }
}
