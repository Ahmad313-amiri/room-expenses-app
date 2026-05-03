import '../../domain/entity/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String groupId;
  final String type;
  final DateTime date;

  final String? description;
  final String? createdBy;

  final String? from;
  final String? to;
  final double? amount;
  final String? status;

  ActivityModel({
    required this.id,
    required this.groupId,
    required this.type,
    required this.date,
    this.description,
    this.createdBy,
    this.from,
    this.to,
    this.amount,
    this.status,
  });

  factory ActivityModel.fromExpense(DocumentSnapshot doc, String groupId) {
    final data = doc.data() as Map<String, dynamic>;

    // Safe timestamp conversion – اگر null بود از زمان فعلی استفاده کن
    final timestamp = data['date'] as Timestamp?;
    final date = timestamp?.toDate() ?? DateTime.now();

    return ActivityModel(
      id: doc.id,
      groupId: groupId,
      type: "expense",
      date: date,
      description: data['description'],
      createdBy: data['createdBy'],
      amount: (data['amount'] as num?)?.toDouble(),
    );
  }

  factory ActivityModel.fromSettlement(DocumentSnapshot doc, String groupId) {
    final data = doc.data() as Map<String, dynamic>;

    final timestamp = data['date'] as Timestamp?;
    final date = timestamp?.toDate() ?? DateTime.now();

    return ActivityModel(
      id: doc.id,
      groupId: groupId,
      type: "settlement",
      date: date,
      from: data['from'],
      to: data['to'],
      amount: (data['amount'] as num?)?.toDouble(),
      status: data['status'] ?? 'pending',
    );
  }

  Activity toEntity() {
    return Activity(
      id: id,
      groupId: groupId,
      type: type == "expense" ? ActivityType.expense : ActivityType.settlement,
      date: date,
      description: description,
      createdBy: createdBy,
      from: from,
      to: to,
      amount: amount,
      status: status,
    );
  }
}