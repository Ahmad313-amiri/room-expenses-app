import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';

class ExpenseModel {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String createdBy;
  final String groupId;
  final ExpenseScope scope;
  final bool isDeleted;
  final Map<String, double> shares;
  final Map<String, double> paidBy;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdBy,
    required this.scope,
    required this.shares,
    required this.paidBy,
    required  this.groupId,
    this.isDeleted = false,
  });

  // Firestore → Model
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ExpenseModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      groupId: data['groupId'],
      scope: data['scope'] == 'group'
          ? ExpenseScope.group
          : ExpenseScope.personal,
      isDeleted: data['isDeleted'] ?? false,
      shares: (data['shares'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num).toDouble())),

      paidBy: (data['paidBy'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  // Model → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'groupId': groupId,
      'scope': scope == ExpenseScope.group ? 'group' : 'personal',
      'isDeleted': isDeleted,
      'shares': shares,
      'paidBy': paidBy,
    };
  }

  // Entity → Model
  factory ExpenseModel.fromEntity(Expense e) {
    return ExpenseModel(
      id: e.id,
      amount: e.amount,
      description: e.description,
      date: e.date,
      createdBy: e.createdBy,
      groupId: e.groupId,
      scope: e.scope,
      isDeleted: e.isDeleted,
      shares: e.split,
      paidBy: e.paidBy,
    );
  }

  // Model → Entity
  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      description: description,
      date: date,
      createdBy: createdBy,
      groupId: groupId,
      scope: scope,
      isDeleted: isDeleted,
      paidBy: paidBy,
      split: shares,
    );
  }
}