import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';
import '../model/expense_model.dart';

class ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  ExpenseRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _expenseCollection =>
      firestore.collection('expenses');

  Future<void> saveExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);

    await _expenseCollection
        .doc(expense.id)
        .set(model.toMap(), SetOptions(merge: true));
  }

  Future<List<Expense>> getAllExpenses() async {
    final snapshot = await _expenseCollection.get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data()).toEntity())
        .toList();
  }

  Stream<List<Expense>> watchExpenses() {
    return _expenseCollection.snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data()).toEntity())
          .toList(),
    );
  }

  Future<void> softDelete(String id) async {
    await _expenseCollection.doc(id).set(
      {
        'isDeleted': true,
        'syncStatus': 'synced',
      },
      SetOptions(merge: true),
    );
  }
}
