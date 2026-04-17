
import 'package:flutter/material.dart';

class GroupBalanceWidget extends StatelessWidget {
  final String balanceText;
  final int memberCount;
  const GroupBalanceWidget({
    super.key,
    required this.balanceText,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('GROUP BALANCE',
            style: TextStyle(
                color: Colors.grey, letterSpacing: 1.2, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(balanceText,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 4),
        Text('$memberCount members', style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}