// lib/features/expenses/data/model/isar/expense_isar.dart

import 'package:isar/isar.dart';
import '../../../domain/entities/expense.dart';

part 'expense_isar.g.dart';


@Collection()
class ExpenseIsar {
  Id? isarId; // Auto increment local id (Isar internal)

  @Index(unique: true)
  late String id; // UUID

  late double amount;

  late String description;

  late DateTime date;

  late String createdBy;

  String? groupId;

  @enumerated
  late ExpenseScope scope;

  @enumerated
  late SyncStatus syncStatus;

  late bool isDeleted;

  // Converters
  factory ExpenseIsar.fromEntity(Expense expense) {
    return ExpenseIsar()
      ..id = expense.id
      ..amount = expense.amount
      ..description = expense.description
      ..date = expense.date
      ..createdBy = expense.createdBy
      ..groupId = expense.groupId
      ..scope = expense.scope
      ..syncStatus = expense.syncStatus
      ..isDeleted = expense.isDeleted;
  }

  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      description: description,
      date: date,
      createdBy: createdBy,
      groupId: groupId,
      scope: scope,
      syncStatus: syncStatus,
      isDeleted: isDeleted,
    );
  }
  ExpenseIsar();
}
