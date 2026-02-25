import 'package:flutter/material.dart';
import 'package:roomly/features/groups/presentation/pages/reject_settlment_screen.dart';

class SettlementVerificationScreen extends StatelessWidget {
  const SettlementVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Back button to close the screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settlement Verification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------
            // Section: Message & Amount Display
            // -------------------------------
            Center(
              child: Column(
                children: [
                  // Icon representing the transaction
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.handshake_outlined, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  // Transaction message
                  const Text(
                    'Ali Ahmad recorded that he paid you',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  // Transaction amount
                  const Text(
                    '50,000 AFN',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // -------------------------------
            // Section: Attached Receipt Preview
            // -------------------------------
            const Text(
              'ATTACHED RECEIPT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              // Tap gesture to open the receipt in a modal preview
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    insetPadding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        // InteractiveViewer allows pinch-zoom and pan
                        InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 3.0,
                          child: Image.network(
                            'https://via.placeholder.com/400x200', // Replace with real receipt image
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Close button on the top-right corner
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 28),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/400x200'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  // Overlay label to indicate "tap to enlarge"
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Tap to enlarge', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // -------------------------------
            // Section: Transaction Details
            // -------------------------------
            _buildDetailRow('From:', 'Ali Ahmad'),
            _buildDetailRow('Date:', 'October 27, 2023'),
            _buildDetailRow('Method:', 'Cash / Physical'),
            const Divider(height: 32),

            // -------------------------------
            // Section: Payer's Note
            // -------------------------------
            const Text(
              'PAYER\'S NOTE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'I handed over the cash this morning at the office. Please confirm.',
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 24),

            // -------------------------------
            // Section: Safety Warning
            // -------------------------------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Only confirm if you have actually received these funds in the real world.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFE65100)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // -------------------------------
            // Section: Action Buttons
            // -------------------------------
            Row(
              children: [
                // Reject Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (_)=>RejectSettlementScreen())), // Reject action
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 16),
                // Confirm Receipt Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to success animation page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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

  // -------------------------------
  // Helper Widget: Display a label-value row
  // -------------------------------
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
