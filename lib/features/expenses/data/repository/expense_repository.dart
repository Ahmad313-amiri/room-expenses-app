import '../../domain/entities/expense.dart';

import '../datasources/expense_local_datasource.dart';
import '../datasources/remote/expense_remote_datasource.dart';
import '../model/isar/expense_isar.dart';


class ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  // ---------- FETCH ----------
  Future<List<Expense>> fetchExpenses({bool fromRemote = false}) async {
    if (fromRemote) {
      final remoteExpenses = await remoteDataSource.getAllExpenses();

      for (final expense in remoteExpenses) {
        final isarModel = ExpenseIsar.fromEntity(expense);
        isarModel.syncStatus = SyncStatus.synced;
        await localDataSource.saveExpense(isarModel as Expense);
      }

      return remoteExpenses;
    } else {
      final localList = await localDataSource.getAllExpenses();
      return localList.map((e) => e.toEntity()).toList();
    }
  }

  // ---------- WATCH (Realtime from Isar) ----------
  Stream<List<Expense>> watchExpenses() {
    return localDataSource.watchExpenses().map(
          (list) => list.map((e) => e.toEntity()).toList(),
    );
  }

  // ---------- ADD ----------
  Future<void> addExpense(Expense expense) async {
    final expenseIsar = ExpenseIsar.fromEntity(expense);
    expenseIsar.syncStatus = SyncStatus.pending;

    // اول Local ذخیره می‌کنیم
    await localDataSource.saveExpense(expenseIsar);

    try {
      // بعد Remote
      await remoteDataSource.saveExpense(expense);

      // اگر موفق بود synced می‌شود
      expenseIsar.syncStatus = SyncStatus.synced;
      await localDataSource.saveExpense(expenseIsar);
    } catch (_) {
      // اگر اینترنت نبود pending باقی می‌ماند
    }
  }

  // ---------- DELETE (Soft) ----------
  Future<void> deleteExpense(String id) async {
    // اول Local
    await localDataSource.softDelete(id);

    try {
      // بعد Remote
      await remoteDataSource.softDelete(id);

      // اگر موفق بود synced کنیم
      final expense = await localDataSource.getById(id);
      if (expense != null) {
        expense.syncStatus = SyncStatus.synced;
        await localDataSource.saveExpense(expense);
      }
    } catch (_) {
      // اگر اینترنت نبود pending باقی می‌ماند
    }
  }

  // ---------- SYNC PENDING ----------
  Future<void> syncPendingExpenses() async {
    final pendingList = await localDataSource.getPendingExpenses();

    for (final expense in pendingList) {
      try {
        await remoteDataSource.saveExpense(expense.toEntity());
        expense.syncStatus = SyncStatus.synced;
        await localDataSource.saveExpense(expense);
      } catch (_) {
        // اگر شکست خورد، به مورد بعدی می‌رود
      }
    }
  }
}
