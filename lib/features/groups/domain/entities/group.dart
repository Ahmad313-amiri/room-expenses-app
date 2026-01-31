

import '../enums/groups_status.dart';

class Group {
  final String name;
  final String description;
  final double amount;
  final GroupStatus status;
  final String iconKey;

  Group({
    required this.name,
    required this.description,
    required this.amount,
    required this.status,
    required this.iconKey,
  });
}
