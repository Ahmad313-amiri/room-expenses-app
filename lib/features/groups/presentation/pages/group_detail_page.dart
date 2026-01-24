import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/balance_item.dart';
import '../widgets/activiy_detail_item.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Europe Trip'),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          const Text('TOTAL GROUP SPEND', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const Text('\$2,450.00', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  Text('Your Standing', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text('+\$120.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                  Text('YOU ARE OWED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('BALANCES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const BalanceItem(name: 'Alice owes you', amount: '\$40.00', isOwed: true),
          const BalanceItem(name: 'You owe Bob', amount: '\$15.00', isOwed: false),
          ListTile(
            title: const Text('Sarah Set'),
            trailing: TextButton(onPressed: () {}, child: const Text('See all')),
          ),
          const SizedBox(height: 24),
          const Text('RECENT ACTIVITY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const ActivityDetailItem(title: 'Train Tickets', description: 'you paid today', type: 'You lent', amount: '\$30.00', total: '\$45.00'),
          const ActivityDetailItem(title: 'Supermarket Run', description: 'Alice paid yesterday', type: 'You borrowed', amount: '\$27.50', total: '\$82.50'),
          const ActivityDetailItem(title: 'Airbnb Deposit', description: 'Bob paid Oct 12', type: 'You borrowed', amount: '\$50.00', total: '\$150.00'),
          const ActivityDetailItem(title: 'Paid Sarah', description: 'you settled up • Oct 10', amount: '\$20.00'),
          const SizedBox(height: 24),
          const Center(child: Text('Start of history', style: TextStyle(color: Colors.grey, fontSize: 12))),
        ]),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(onPressed: () {}, icon: const Icon(Icons.payment), label: const Text('Settle Up')),
          const SizedBox(width: 8),
          FloatingActionButton(onPressed: () { Navigator.pushNamed(context, '/new_expense'); }, child: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
