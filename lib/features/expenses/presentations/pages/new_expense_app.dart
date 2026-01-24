import 'package:flutter/material.dart';
import '../widgets/person_split.dart';

class NewExpensePage extends StatelessWidget {
  const NewExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Expense'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const SizedBox(height: 24),
          const Text('\$ 42.50', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          const Text('USD', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Friday Pizza Night',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('CATEGORY', style: TextStyle(color: Colors.grey, fontSize: 12))),
          DropdownButtonFormField(
            decoration: const InputDecoration(hintText: 'Food & Drink', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'food', child: Text('Food & Drink')),
              DropdownMenuItem(value: 'travel', child: Text('Travel')),
              DropdownMenuItem(value: 'utilities', child: Text('Utilities')),
            ],
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('DATE', style: TextStyle(color: Colors.grey, fontSize: 12))),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Today',
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('Paid by', style: TextStyle(color: Colors.grey, fontSize: 12))),
          DropdownButtonFormField(
            decoration: const InputDecoration(hintText: 'You', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'you', child: Text('You')),
              DropdownMenuItem(value: 'alice', child: Text('Alice')),
              DropdownMenuItem(value: 'bob', child: Text('Bob')),
            ],
            onChanged: (value) {},
          ),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft, child: Text('Split logic', style: TextStyle(fontWeight: FontWeight.bold))),
          const Align(alignment: Alignment.centerLeft, child: Text('Total: \$42.50', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Equal'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('%'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Exact'))),
            ],
          ),
          const SizedBox(height: 24),
          const PersonSplit(name: 'You', amount: '\$14.17'),
          const PersonSplit(name: 'Alex', amount: '\$14.17'),
          const PersonSplit(name: 'Sarah', amount: '\$14.16'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Save Expense'),
            ),
          ),
        ]),
      ),
    );
  }
}
