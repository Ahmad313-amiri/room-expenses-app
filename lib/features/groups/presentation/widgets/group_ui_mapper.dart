import 'package:flutter/material.dart';

import '../../domain/enums/groups_status.dart';

class GroupUIMapper {
  static Color statusColor(GroupStatus status) {
    switch (status) {
      case GroupStatus.owe:
        return Colors.red.shade800;
      case GroupStatus.owed:
        return Colors.orange.shade800;
      case GroupStatus.settled:
        return Colors.green.shade800;
    }
  }

  static String statusText(GroupStatus status) {
    switch (status) {
      case GroupStatus.owe:
        return 'You owe';
      case GroupStatus.owed:
        return 'You are owed';
      case GroupStatus.settled:
        return 'Settled up';
    }
  }

  static IconData icon(String key) {
    switch (key) {
      case 'home':
        return Icons.home;
      case 'public':
        return Icons.public;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.group;
    }
  }
}
