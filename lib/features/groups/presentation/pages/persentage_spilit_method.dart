import 'package:flutter/material.dart';

/// Percentage Split Page
/// This page represents the "Percentage" tab in the Split Method screen
class PercentageSplitPage extends StatefulWidget {
  const PercentageSplitPage({super.key});

  @override
  State<PercentageSplitPage> createState() => _PercentageSplitPageState();
}

class _PercentageSplitPageState extends State<PercentageSplitPage> {
  // Total expense to split among members
  final double totalAmount = 1200.00;

  // Sample members with initial percentages
  final List<Map<String, dynamic>> members = [
    {'name': 'Alice Miller', 'initials': 'AM', 'color': Colors.blue.shade100, 'percent': 33.0},
    {'name': 'Bob Johnson', 'initials': 'BJ', 'color': Colors.orange.shade100, 'percent': 34.0},
    {'name': 'Charlie Reed', 'initials': 'CR', 'color': Colors.green.shade100, 'percent': 33.0},
  ];

  // Controllers for percentage input fields
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the default percentages
    _controllers = {
      for (var m in members)
        m['name']: TextEditingController(text: m['percent'].toInt().toString())
    };
  }

  /// Calculate the total percentage entered by the user
  double get totalPercentage {
    double sum = 0;
    _controllers.forEach((key, controller) {
      sum += double.tryParse(controller.text) ?? 0;
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    // The Confirm button is active only if the total percentage equals 100
    bool isBalanced = totalPercentage == 100;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        title: const Text('Split Method', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Next', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fake tab bar for visual effect
          _buildFakeTabBar(),
          const SizedBox(height: 16),
          // Step indicator (three-dot indicator at the top)
          _buildDotIndicator(),
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main card displaying Percentage Split info
                  _buildMainInfoCard(),
                  const SizedBox(height: 32),
                  // Section header for member list
                  _buildSectionHeader(),
                  const SizedBox(height: 16),
                  // List of members with percentage input fields
                  ...members.map((m) => _buildMemberRow(m)).toList(),
                ],
              ),
            ),
          ),
          // Footer with validation and Confirm button
          _buildFooter(isBalanced),
        ],
      ),
    );
  }

  /// Fake tab bar to simulate the tab UI
  Widget _buildFakeTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _tabItem('Equal', false),
          _tabItem('Custom', false),
          _tabItem('Percentage', true), // Active tab
        ],
      ),
    );
  }

  /// Individual tab item
  Widget _tabItem(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isActive ? const Border(bottom: BorderSide(color: Colors.blue, width: 3)) : null,
      ),
      child: Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  /// Three-dot step indicator at the top
  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(radius: 3, backgroundColor: Colors.grey.shade300),
        const SizedBox(width: 6),
        Container(width: 20, height: 6, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        CircleAvatar(radius: 3, backgroundColor: Colors.grey.shade300),
      ],
    );
  }

  /// Main info card for Percentage Split
  Widget _buildMainInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Percentage Split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Total: \$${totalAmount.toStringAsFixed(2)} | ${members.length} members',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: const Text('100% total required', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  /// Section header for member list
  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text('Member Shares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('PERCENTAGE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  /// Each member row with initial, name, calculated amount, and percentage input
  Widget _buildMemberRow(Map<String, dynamic> member) {
    double percent = double.tryParse(_controllers[member['name']]!.text) ?? 0;
    double calculatedAmount = (percent / 100) * totalAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Circle avatar with initials
          CircleAvatar(
            backgroundColor: member['color'],
            child: Text(member['initials'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),

          // Name and calculated dollar amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('(\$${calculatedAmount.toStringAsFixed(2)})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // Percentage input field
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[member['name']],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) => setState(() {}), // Rebuild page for live calculation
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  ),
                ),
                const Text('%', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Footer with validation, progress bar, and Confirm button
  Widget _buildFooter(bool isBalanced) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade100))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total percentage and matched amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL PERCENTAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Row(
                    children: [
                      Text('${totalPercentage.toInt()}%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isBalanced ? Colors.green : Colors.blue)),
                      if (isBalanced)
                        const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check_circle, color: Colors.green, size: 20)),
                    ],
                  ),
                ],
              ),
              // Matched amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('AMOUNT MATCHED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar representing total percentage
          LinearProgressIndicator(
            value: totalPercentage / 100,
            backgroundColor: Colors.grey.shade100,
            color: isBalanced ? Colors.green : Colors.blue,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 24),
          // Confirm button
          ElevatedButton(
            onPressed: isBalanced ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D5CFF),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Confirm Percentage Split', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
