import 'package:flutter/material.dart';


class DashboardEmptyScreen extends StatelessWidget {
  const DashboardEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.account_balance_wallet,
                  color: Colors.blue, size: 20)),
        ),
        title: const Text('My Dashboard',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Container(
                height: 200,
                width: 250,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20)),
                child:
                const Icon(Icons.menu_book, size: 100, color: Colors.brown),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Your financial journey starts here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Start tracking your expenses, managing budgets, and splitting bills with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            _buildQuickAction(
                Icons.group_add, 'Create your first group', 'Split bills with friends.'),
            _buildQuickAction(Icons.receipt_long, 'Add a personal expense',
                'Track your daily spending.'),
            _buildQuickAction(Icons.account_balance, 'Setup your wallets',
                'Organize accounts.'),
          ],
        ),
      ),

    );
  }

  Widget _buildQuickAction(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!)),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.blue[50], child: Icon(icon, color: Colors.blue)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
