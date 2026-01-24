import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String amount;
  final String time;

  const ActivityItem({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(description),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(amount,
              style: TextStyle(
                color: amount.startsWith('-') ? Colors.red : amount.startsWith('+') ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              )),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
