import 'package:cloud_firestore/cloud_firestore.dart';

class SettlementRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveSettlement(
      String groupId,
      Map<String, dynamic> data,
      ) async {
    if (groupId.isEmpty) throw Exception("Group ID missing");

    if (data['from'] == null || data['to'] == null) {
      throw Exception("Invalid settlement participants");
    }

    if ((data['amount'] ?? 0) <= 0) {
      throw Exception("Invalid amount");
    }

    final id = firestore
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .doc()
        .id;

    await firestore
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .doc(id)
        .set({
      ...data,
      'id': id,
      'date': FieldValue.serverTimestamp(),
      'status': 'pending',
      'type': 'settlement',
    });
  }
}