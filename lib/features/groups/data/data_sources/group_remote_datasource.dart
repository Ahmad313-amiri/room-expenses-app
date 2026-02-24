// MODIFIED: اضافه شدن متدهای مربوط به Member و Expense
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../expenses/data/model/expense_model.dart';
import '../../../domain/entities/member_entity.dart';
import '../../models/group_model.dart' hide MemberEntity;
import '../../models/members_model.dart';


class GroupRemoteDataSource {
  final FirebaseFirestore firestore;

  GroupRemoteDataSource(this.firestore);

  CollectionReference get _groups => firestore.collection('groups');
  CollectionReference get _members => firestore.collection('members');
  CollectionReference get _expenses => firestore.collection('expenses');

  // ========== گروه‌ها ==========
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
        ..isArchived = data['isArchived'] ?? false
        ..createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()
        ..updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    }).toList();
  }

  // ========== اعضا ==========
  Future<String> addMember(MemberModel member) async {
    final doc = await _members.add({
      'groupId': member.groupId,
      'userId': member.userId,
      'role': member.role,
      'joinedAt': FieldValue.serverTimestamp(),
      'invitationStatus': member.invitationStatus,
      'invitedBy': member.invitedBy,
    });
    return doc.id;
  }

  Future<List<MemberEntity>> getMembers(String groupId) async {
    final snapshot = await _members.where('groupId', isEqualTo: groupId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MemberEntity()
        ..firestoreId = doc.id
        ..groupId = groupId
        ..userId = data['userId'] ?? ''
        ..role = data['role'] ?? 'member'
        ..joinedAt = (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now()
        ..invitationStatus = data['invitationStatus'] ?? 'pending'
        ..invitedBy = data['invitedBy'];
    }).toList();
  }

  // ========== خرج‌ها ==========
  Future<String> addExpense(ExpenseModel expense) async {
    final doc = await _expenses.add({
      'groupId': expense.groupId,
      'amount': expense.amount,
      'description': expense.description,
      'paidBy': expense.paidBy,
      'splitAmong': expense.splitAmong,
      'date': expense.date.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<List<ExpenseModel>> getExpenses(String groupId) async {
    final snapshot = await _expenses.where('groupId', isEqualTo: groupId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ExpenseModel()
        ..firestoreId = doc.id
        ..groupId = groupId
        ..amount = (data['amount'] as num).toDouble()
        ..description = data['description'] ?? ''
        ..paidBy = data['paidBy'] ?? ''
        ..splitAmong = List<String>.from(data['splitAmong'] ?? [])
        ..date = DateTime.parse(data['date'] ?? DateTime.now().toIso8601String());
    }).toList();
  }
}