import 'package:flutter/material.dart';

class BalanceItem extends StatelessWidget {
  final String name;
  final String amount;
  final bool isOwed;

  const BalanceItem({
    super.key,
    required this.name,
    required this.amount,
    required this.isOwed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: Text(
          amount,
          style: TextStyle(
            color: isOwed ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
