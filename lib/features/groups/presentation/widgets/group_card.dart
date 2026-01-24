import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final String name;
  final String lastExpense;
  final String status;
  final String amount;
  final bool? isOwed;

  const GroupCard({
    super.key,
    required this.name,
    required this.lastExpense,
    required this.status,
    required this.amount,
    this.isOwed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(lastExpense),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (amount.isNotEmpty)
              Text(amount,
                  style: TextStyle(
                      color: isOwed == true ? Colors.green : isOwed == false ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.bold)),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/group_detail');
        },
      ),
    );
  }
}
