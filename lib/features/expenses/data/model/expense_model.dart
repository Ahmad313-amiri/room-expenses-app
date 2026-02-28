// lib/features/expenses/data/models/expense_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required String id,
    required double amount,
    required String description,
    required DateTime date,
    required String createdBy,
    required ExpenseScope scope,
    String? groupId,
    SyncStatus syncStatus = SyncStatus.pending,
    bool isDeleted = false,
  }) : super(
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

  // Factory: Firestore Document → ExpenseModel
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      groupId: data['groupId'],
      scope: data['scope'] == 'group' ? ExpenseScope.group : ExpenseScope.personal,
      syncStatus: SyncStatus.synced,
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // To Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'groupId': groupId,
      'scope': scope == ExpenseScope.group ? 'group' : 'personal',
      'isDeleted': isDeleted,
    };
  }

  // Factory: Domain Entity → ExpenseModel
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      description: expense.description,
      date: expense.date,
      createdBy: expense.createdBy,
      groupId: expense.groupId,
      scope: expense.scope,
      syncStatus: expense.syncStatus,
      isDeleted: expense.isDeleted,
    );
  }

  // Convert back to Entity
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
}
