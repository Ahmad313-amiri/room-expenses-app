import 'package:flutter/material.dart';

/// Add Group Expense Screen
/// Allows the user to enter a new group expense, select a split method,
/// and see the net balance impact for each member.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  int selectedTabIndex = 0; // 0: Equally, 1: Custom, 2: Percentage, 3: Share

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.blue)),
        ),
        title: const Text('New Expense', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Save', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountSection(),
            const SizedBox(height: 32),
            _buildInputLabel('REASON *'),
            _buildTextField('e.g. Dinner at Alpine Lodge'),
            const SizedBox(height: 20),
            _buildInputLabel('SPLIT METHOD'),
            _buildSplitTabs(),
            const SizedBox(height: 32),
            _buildInputLabel('NET BALANCE IMPACT'),
            _buildImpactList(),
            const SizedBox(height: 120), // Space for bottom sheet
          ],
        ),
      ),
      bottomSheet: _buildStickyFooter(),
    );
  }

  /// Displays total amount input section
  Widget _buildAmountSection() {
    return Center(
      child: Column(
        children: [
          const Text(
            'ENTER TOTAL AMOUNT',
            style: TextStyle(
                color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('\$', style: TextStyle(fontSize: 32, color: Colors.blue, fontWeight: FontWeight.w300)),
              Text('120.00', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  /// Tabs for selecting split method
  Widget _buildSplitTabs() {
    List<String> tabs = ['Equally', 'Custom', 'Percentage', 'Share'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: List.generate(
          tabs.length,
              (index) {
            bool isSelected = selectedTabIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTabIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// List of net impact per member
  Widget _buildImpactList() {
    return Column(
      children: [
        _buildMemberRow('You', '+80.00', true),
        _buildMemberRow('Sarah', '-40.00', false),
        _buildMemberRow('Alex', '-40.00', false),
      ],
    );
  }

  /// Single row showing a member's net shift
  Widget _buildMemberRow(String name, String impact, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('NET SHIFT', style: TextStyle(fontSize: 9, color: Colors.grey)),
              Text(impact,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  /// Input label
  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
  );

  /// Input text field
  Widget _buildTextField(String hint) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );

  /// Bottom sticky action button
  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Create Expense',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
