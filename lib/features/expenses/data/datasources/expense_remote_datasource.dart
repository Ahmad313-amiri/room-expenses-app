import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';

class ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  ExpenseRemoteDataSource({required this.firestore});

  Future<void> saveExpense(String groupId, Expense expense) async {
    try {
      final collection = firestore
          .collection('groups')
          .doc(groupId)
          .collection('expenses');

      final docRef = expense.id.isNotEmpty
          ? collection.doc(expense.id)
          : collection.doc();

      final data = {
        'amount': expense.amount,
        'description': expense.description,
        'date': Timestamp.fromDate(expense.date), // ✅ اصلاح شده
        'createdBy': expense.createdBy,
        'scope': expense.scope.toString().split('.').last,
        'groupId': expense.groupId,
        'paidBy': expense.paidBy,
        'split': expense.split,
        'isDeleted': false,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save expense: $e');
    }
  }

  Future<void> deleteExpense(String groupId, String expenseId) async {
    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .doc(expenseId)
        .update({'isDeleted': true});
  }

  Stream<List<Expense>> watchExpenses(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      final rawDate = data['date'];
      DateTime date;
      if (rawDate is Timestamp) {
        date = rawDate.toDate();
      } else if (rawDate is String) {
        date = DateTime.parse(rawDate);
      } else {
        date = DateTime.now();
      }
      return Expense(
        id: doc.id,
        amount: (data['amount'] ?? 0.0).toDouble(),
        description: data['description'] ?? '',
        date: date,
        createdBy: data['createdBy'] ?? '',
        scope: data['scope'] == 'group' ? ExpenseScope.group : ExpenseScope.personal,
        groupId: data['groupId'] ?? '',
        paidBy: Map<String, double>.from(data['paidBy'] ?? {}),
        split: Map<String, double>.from(data['split'] ?? {}),
      );
    }).toList());
  }
}