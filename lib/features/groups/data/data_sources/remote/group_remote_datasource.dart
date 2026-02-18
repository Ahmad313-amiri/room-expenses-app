import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/group_model.dart';

class GroupRemoteDataSource {
  final FirebaseFirestore firestore;

  GroupRemoteDataSource(this.firestore);

  CollectionReference get _groups => firestore.collection('groups');

  Future<String> addGroup(GroupModel group) async {
    final doc = await _groups.add({
      'name': group.name,
      'description': group.description,
      'currency': group.currency,
      'createdBy': group.createdBy,
      'isArchived': group.isArchived,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'settings': {
        'allowInvites': group.settings.allowInvites,
        'defaultSplitMethod': group.settings.defaultSplitMethod,
        'expenseCategories': group.settings.expenseCategories,
      },
    });
    return doc.id;
  }

  Future<List<GroupModel>> getGroups(String userId) async {
    final snapshot = await _groups.where('createdBy', isEqualTo: userId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return GroupModel()
        ..firestoreId = doc.id
        ..name = data['name'] ?? ''
        ..description = data['description'] ?? ''
        ..currency = data['currency'] ?? 'USD'
        ..createdBy = data['createdBy'] ?? ''
        ..isArchived = data['isArchived'] ?? false;
    }).toList();
  }
}
