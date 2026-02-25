import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:roomly/features/groups/presentation/pages/settlement_verification_screen.dart';

class AdvancedSettleUpScreen extends StatefulWidget {
  const AdvancedSettleUpScreen({super.key});

  @override
  State<AdvancedSettleUpScreen> createState() => _AdvancedSettleUpScreenState();
}

class _AdvancedSettleUpScreenState extends State<AdvancedSettleUpScreen> {
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _paymentMethod = 'Bank Transfer';
  bool _isConfirmed = false;
  bool _hasImage = true; // Simulating a selected receipt for the thumbnail
  final List<String> _methods = ['Bank Transfer', 'Cash', 'Digital Wallet', 'Other'];

  // Function to select a date using the system date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Record Settlement',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082).withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, color: Color(0xFF9E6E00), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verification Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9E6E00),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Once recorded, the receiver will need to verify this entry in their own app to update balances.',
                          style: TextStyle(color: Colors.orange[900], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payer Selection
            _buildSelectionTile(
              icon: Icons.person,
              label: 'FROM (PAYER)',
              value: 'You',
              iconColor: Colors.blue,
            ),
            const SizedBox(height: 12),

            // Receiver Selection
            _buildSelectionTile(
              icon: Icons.person_add_alt_1,
              label: 'TO (RECEIVER)',
              value: 'Select contact',
              iconColor: Colors.grey,
            ),
            const SizedBox(height: 24),

            // Amount Input
            const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 8),
                  child: Text('\$', style: TextStyle(fontSize: 32, color: Colors.black)),
                ),
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey[300]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method and Date Row
            Row(
              children: [
                // Payment Method Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _paymentMethod,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                _paymentMethod = newValue!;
                              });
                            },
                            items: _methods.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Date Picker
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('MM/dd/yyyy').format(_selectedDate)),
                              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Receipt Attachment
            const Text('Receipt Attachment', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.grey),
                            SizedBox(width: 8),
                            Icon(Icons.image, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'UPLOAD RECEIPT/PHOTO',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text('Add visual proof of payment', style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Display receipt thumbnail if exists
                if (_hasImage)
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(Icons.receipt_long, color: Colors.orange[200], size: 40),
                        ),
                      ),
                      Positioned(
                        right: -5,
                        top: -5,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                          onPressed: () => setState(() => _hasImage = false),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Confirmation Checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isConfirmed,
                    activeColor: Colors.blue,
                    onChanged: (val) => setState(() => _isConfirmed = val!),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('I have made this payment in real life', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'The receiver must also confirm this settlement to update balances.',
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isConfirmed
                    ? () {

                  // Logic to save the settlement record
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>SettlementVerificationScreen()));
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Record Settlement',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Verification Note
            const Center(
              child: Text(
                'VERIFICATION REQUIRED BY RECEIVER',
                style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for Payer and Receiver Selection Tiles
  Widget _buildSelectionTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
