import 'package:flutter/material.dart';

import '../widgets/activity_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SplitEase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('TOTAL BALANCE', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const Text('+ \$150.00', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green)),
            const Text('Net Positive', style: TextStyle(color: Colors.green)),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text('70% Collected', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Owed to you'),
                        Text('\$200.00', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('You owe'),
                        Text('\$50.00', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/new_expense');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Expense'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('See all')),
              ],
            ),
            const ActivityItem(title: 'Team Lunch', description: 'Alice paid · You owe \$15.00', amount: '-\$15.00', time: 'TODAY'),
            const ActivityItem(title: 'Roadtrip Gas', description: 'You paid \$60.00 total', amount: '+\$30.00', time: 'YESTERDAY'),
            const ActivityItem(title: 'Movie Night', description: 'Split with Bob & Sarah', amount: '+\$24.00', time: 'OCT 24'),
            const ActivityItem(title: 'Groceries', description: 'You paid for shared items', amount: 'Settled', time: 'OCT 20'),
          ],
        ),
      ),
    );
  }
}
