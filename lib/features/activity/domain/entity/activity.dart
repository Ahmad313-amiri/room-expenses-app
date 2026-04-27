enum ActivityType { expense, settlement }

class Activity {
  final String id;
  final String groupId; // ✅ ADD THIS
  final ActivityType type;
  final DateTime date;

  final String? description;
  final String? createdBy;

  final String? from;
  final String? to;
  final double? amount;
  final String? status;

  Activity({
    required this.id,
    required this.groupId, // ✅ ADD THIS
    required this.type,
    required this.date,
    this.description,
    this.createdBy,
    this.from,
    this.to,
    this.amount,
    this.status,
  });
}