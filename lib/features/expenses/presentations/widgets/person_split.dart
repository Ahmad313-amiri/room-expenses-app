import 'package:flutter/material.dart';

class PersonSplit extends StatelessWidget {
  final String name;
  final String amount;

  const PersonSplit({super.key, required this.name, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
