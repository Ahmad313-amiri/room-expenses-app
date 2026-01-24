import 'package:flutter/material.dart';
import '../widgets/group_card.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Groups')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('TOTAL BALANCE', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const Text('+ \$120.50', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
            const Text('+12% vs last mo', style: TextStyle(color: Colors.green)),
            const SizedBox(height: 24),
            const Text('Active Circles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sort by Activity', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            GroupCard(name: 'Apt 4B Roommates', lastExpense: 'Utility Bill', status: 'You owe', amount: '\$45.00', isOwed: false),
            GroupCard(name: 'Europe Summer \'24', lastExpense: 'Active 2 days ago', status: 'You are owed', amount: '\$165.50', isOwed: true),
            GroupCard(name: 'Friday Dinners', lastExpense: 'All expenses settled', status: 'Settled up', amount: ''),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
