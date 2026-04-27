import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final double amount;
  final String description;
  final String status;
  final String time;
  final String title;
  final Color iconColor;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.amount,
    required this.description,
    required this.status,
    required this.time,
    required this.title,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.2),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('\$${amount.toStringAsFixed(2)}'),
          Text(status, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}