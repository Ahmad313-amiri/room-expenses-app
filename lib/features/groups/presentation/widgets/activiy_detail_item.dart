import 'package:flutter/material.dart';

class ActivityDetailItem extends StatelessWidget {
  final String title;
  final String description;
  final String? type;
  final String amount;
  final String? total;

  const ActivityDetailItem({
    super.key,
    required this.title,
    required this.description,
    this.type,
    required this.amount,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(description),
          if (type != null) Text(type!),
        ]),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (total != null) Text(total!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
