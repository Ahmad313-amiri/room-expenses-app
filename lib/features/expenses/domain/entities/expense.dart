// lib/features/expenses/domain/entities/expense.dart

enum ExpenseScope {
  personal,
  group,
}

enum SyncStatus {
  pending,
  synced,
  failed,
}

class Expense {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String createdBy;
  final String? groupId;
  final ExpenseScope scope;
  final SyncStatus syncStatus;
  final bool isDeleted;

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdBy,
    required this.scope,
    this.groupId,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    String? createdBy,
    String? groupId,
    ExpenseScope? scope,
    SyncStatus? syncStatus,
    bool? isDeleted,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      groupId: groupId ?? this.groupId,
      scope: scope ?? this.scope,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
