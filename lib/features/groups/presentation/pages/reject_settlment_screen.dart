import 'package:flutter/material.dart';

class RejectSettlementScreen extends StatefulWidget {
  const RejectSettlementScreen({super.key});

  @override
  State<RejectSettlementScreen> createState() => _RejectSettlementScreenState();
}

class _RejectSettlementScreenState extends State<RejectSettlementScreen> {
  // Selected reason for rejection
  String? _selectedReason = 'Amount is incorrect';

  // Controller for optional note input
  final TextEditingController _noteController = TextEditingController();

  // Predefined list of rejection reasons
  final List<String> _reasons = [
    'Amount is incorrect',
    'Haven\'t received funds yet',
    'Receipt photo is unclear',
    'Duplicate record',
    'Other reason'
  ];

  // Function triggered when "Notify Payer" button is pressed
  void _submitRejection() {
    // 1. Show feedback message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejection sent to Payer: $_selectedReason'),
        backgroundColor: Colors.redAccent,
      ),
    );

    // 2. Navigate back to the previous screen (e.g., transaction list)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Close button to exit this screen
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reject Settlement',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------
            // Section: Header Icon
            // -------------------------------
            const Center(
              child: Icon(Icons.report_problem_outlined, size: 60, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Why are you rejecting this?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),

            // -------------------------------
            // Section: Select a Reason (Radio List)
            // -------------------------------
            const Text(
              'SELECT A REASON',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Column(
              // Map each reason to a RadioListTile widget
              children: _reasons.map((reason) => _buildReasonOption(reason)).toList(),
            ),
            const SizedBox(height: 24),

            // -------------------------------
            // Section: Additional Note (Optional)
            // -------------------------------
            const Text(
              'ADDITIONAL NOTE (OPTIONAL)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Explain why you are rejecting this...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // -------------------------------
            // Section: Submit Button
            // -------------------------------
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitRejection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 12),
                    Text(
                      'Notify Payer',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // -------------------------------
            // Section: Cancel Button
            // -------------------------------
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // Helper Widget: Single Radio Option
  // -------------------------------
  Widget _buildReasonOption(String reason) {
    return RadioListTile<String>(
      title: Text(reason, style: const TextStyle(fontSize: 15)),
      value: reason,
      groupValue: _selectedReason,
      activeColor: Colors.redAccent,
      contentPadding: EdgeInsets.zero,
      onChanged: (value) {
        setState(() {
          _selectedReason = value;
        });
      },
    );
  }
}
