import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';
import '../model/expense_model.dart';

class ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  ExpenseRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses');
  }

  Future<void> saveExpense(String groupId, Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    await _collection(groupId)
        .doc(expense.id)
        .set(model.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteExpense(String groupId, String expenseId) async {
    await _collection(groupId)
        .doc(expenseId)
        .set({'isDeleted': true}, SetOptions(merge: true));
  }

  Stream<List<Expense>> watchExpenses(String groupId) {
    return _collection(groupId).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc).toEntity())
          .toList(),
    );
  }
}