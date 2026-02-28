import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final int step; // 1 or 2
  const OnboardingScreen({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: step == 2 ? const BackButton(color: Colors.black) : null,
        actions: [
          TextButton(
              onPressed: () {},
              child: const Text('Skip', style: TextStyle(color: Colors.blue)))
        ],
      ),
      body: Column(
        children: [
          const Spacer(),
          Container(
            height: 300,
            width: double.infinity,
            color: step == 1 ? Colors.orange[50] : Colors.blue[50],
            child: Icon(step == 1 ? Icons.people : Icons.calculate,
                size: 150, color: Colors.blue),
          ),
          const SizedBox(height: 40),
          Text(
            step == 1 ? 'Manage Expenses, Offline.' : 'No More Debt Confusion',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Record who paid and let the app calculate the rest. No internet needed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _dot(step == 1),
            const SizedBox(width: 5),
            _dot(step == 2),
          ]),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: Text(step == 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool active) => Container(
    width: active ? 20 : 8,
    height: 8,
    decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(4)),
  );
}
