

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SettlementVerificationScreen extends StatelessWidget {
  const SettlementVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=james'),
            ),
            const SizedBox(height: 16),
            const Text('James Ahmad paid you', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const Text('\$45.00', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),

            // Receipt details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _row('Group', 'Beach Trip'),
                  _row('Date', 'Oct 28, 2023'),
                  _row('Method', 'Cash'),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('ATTACHED RECEIPT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network('https://via.placeholder.com/300x150', fit: BoxFit.cover),
            ),
            const Spacer(),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Reject', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // ✅ Show success Lottie animation after confirming
                      showDialog(
                        context: context,
                        barrierDismissible: false, // Prevent closing
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Lottie.network(
                            'https://assets10.lottiefiles.com/packages/lf20_jbrw3hcz.json', // Success animation
                            repeat: false,
                            onLoaded: (composition) {
                              // Close dialog automatically after animation
                              Future.delayed(composition.duration, () {
                                Navigator.pop(context); // Close Lottie dialog
                                Navigator.pop(context); // Go back to previous screen
                              });
                            },
                          ),
                        ),
                      );
                    },
                    child: const Text('Confirm Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
