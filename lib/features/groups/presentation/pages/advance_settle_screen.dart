import 'package:flutter/material.dart';

/// Transparency Settle Screen
/// Shows detailed breakdown of debts per member before settlement.
class AdvancedSettleUpScreen extends StatelessWidget {
  const AdvancedSettleUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Transparency', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BREAKDOWN BY PERSON',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildDebtCard('Sarah Miller', 45.00, [
              _buildReasonItem('Dinner at Alpine', 32.50),
              _buildReasonItem('Taxi to Hotel', 12.50),
            ]),
            _buildDebtCard('Alex Johnson', 12.50, [_buildReasonItem('Grocery Shopping', 12.50)]),
          ],
        ),
      ),
      bottomSheet: _buildSettleFooter(),
    );
  }

  /// Debt card for a single member with details
  Widget _buildDebtCard(String name, double total, List<Widget> reasons) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey[100]!)),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Colors.blue),
              const SizedBox(width: 12),
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: Colors.blue, size: 20),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          ...reasons
        ],
      ),
    );
  }

  /// Individual reason item
  Widget _buildReasonItem(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text('+\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  /// Bottom footer with total settlement and action
  Widget _buildSettleFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TOTAL SETTLEMENT', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text('\$57.50', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ]),
              Text('2 People', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Settle Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.bolt, color: Colors.white)
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
