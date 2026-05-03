import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';

/// Remote data source for recording settlements between members.
class SettlementRemoteDataSource {
  final FirebaseFirestore firestore;

  SettlementRemoteDataSource({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Saves a settlement transaction.
  /// Throws user-friendly exception on failure.
  Future<void> saveSettlement(String groupId, Map<String, dynamic> data) async {
    try {
      if (groupId.isEmpty) {
        throw Exception('Group ID is missing');
      }
      if (data['from'] == null || data['to'] == null) {
        throw Exception('Invalid settlement participants');
      }
      final amount = (data['amount'] ?? 0).toDouble();
      if (amount <= 0) {
        throw Exception('Amount must be greater than zero');
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
        'status': 'completed',
        'type': 'settlement',
      }).timeout(const Duration(seconds: 15));

      AppLogger.i('Settlement saved in group $groupId: $id');
    } catch (e, stack) {
      AppLogger.e('Failed to save settlement', e, stack);
      throw ErrorHandler.getUserFriendlyException(e);
    }
  }

  Stream<QuerySnapshot> watchSettlements(String groupId) {
    return firestore
        .collection('groups')
        .doc(groupId)
        .collection('settlements')
        .snapshots();
  }
}