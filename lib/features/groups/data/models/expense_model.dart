import 'package:isar/isar.dart';

import '../../../expenses/domain/entities/expense.dart';

part 'expense_model.g.dart';
@Collection()
class ExpenseModel {
  Id id = Isar.autoIncrement; // برای دیتابیس لوکال

  @Index(unique: true)
  late String firestoreId; // برای هماهنگی با ریموت

  late String groupId;
  late double amount;
  late String description;
  late String createdBy;

  @enumerated
  late ExpenseScope scope;

  DateTime date = DateTime.now();

  @enumerated
  SyncStatus syncStatus = SyncStatus.pending;

  bool isDeleted = false;

  // متدهای تبدیل به Entity و Firestore که قبلاً داشتید را حفظ کنید
  Expense toEntity() => Expense(
    id: firestoreId,
    amount: amount,
    description: description,
    date: date,
    createdBy: createdBy,
    scope: scope,
    groupId: groupId,
    syncStatus: syncStatus,
  );
}