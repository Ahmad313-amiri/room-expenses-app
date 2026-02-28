import 'package:flutter/material.dart';


class EmptyTransactionsScreen extends StatelessWidget {
  const EmptyTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Transactions'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.find_in_page_outlined, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text('No activities yet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Your personal and group history will appear here.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            const Text('Tap to add your first expense',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_downward, color: Colors.blue),
          ],
        ),
      ),
      floatingActionButton:
      FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),

    );
  }
}
