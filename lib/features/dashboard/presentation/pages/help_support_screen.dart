import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Help & Support'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Quick Start Guide',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const ExpansionTile(
              title: Text('How to export reports?'),
              children: [
                Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Go to Settings > Data and click on Export CSV.'))
              ]),
          const ExpansionTile(
              title: Text('Can I use this offline?'),
              children: [
                Padding(
                    padding: EdgeInsets.all(16),
                    child:
                    Text('Yes, all data is stored locally on your device.'))
              ]),
          const SizedBox(height: 30),
          const Text('Report an Issue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                  hintText: 'Describe your issue...', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Attach Screenshot')),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Submit Report')),
        ],
      ),
    );
  }
}
