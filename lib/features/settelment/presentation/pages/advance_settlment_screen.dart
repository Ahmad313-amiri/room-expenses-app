import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../home/presentation/pages/activity_page.dart';


class AdvancedSettleUpScreen extends StatefulWidget {
  final String groupId;
  const AdvancedSettleUpScreen({super.key, required this.groupId});

  @override
  State<AdvancedSettleUpScreen> createState() => _AdvancedSettleUpScreenState();
}

class _AdvancedSettleUpScreenState extends State<AdvancedSettleUpScreen> {
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _paymentMethod = 'Bank Transfer';
  bool _isConfirmed = false;
  final List<String> _methods = ['Bank Transfer', 'Cash', 'Digital Wallet', 'Other'];

  List<Map<String, dynamic>> members = [];

  String? selectedPayer;
  String? selectedReceiver;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  // ---------------- FETCH MEMBERS ----------------
  Future<void> fetchMembers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('members')
        .get();

    members = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'userId': doc['userId'],
      };
    }).toList();

    if (mounted) setState(() {});
  }


  // ---------------- SAVE SETTLEMENT ----------------
  Future<void> saveSettlement() async {
    final amount = double.tryParse(_amountController.text) ?? 0;

      if (selectedPayer == null || selectedReceiver == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (selectedPayer == selectedReceiver) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payer and Receiver cannot be same")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('settlements')
          .add({
        'from': selectedPayer,
        'to': selectedReceiver,
        'amount': amount,
        'paymentMethod': _paymentMethod,
        'date': _selectedDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Settlement saved successfully "),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>  ActivityScreen(),),

      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) setState(() => isLoading = false);
  }

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
         centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedPayer,
              hint: const Text("Select Payer"),
              items: members.map<DropdownMenuItem<String>>((m) {
                return DropdownMenuItem<String>(
                  value: m['id'] as String,
                  child: Text(m['name'] as String),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedPayer = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedReceiver,
              hint: const Text("Select Receiver"),
              items: members.map<DropdownMenuItem<String>>((m) {
                return DropdownMenuItem<String>(
                  value: m['id'] as String,
                  child: Text(m['name'] as String),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedReceiver = val),
            ),
            const SizedBox(height: 24),
            const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                // prefixIcon: const Padding(
                //   padding: EdgeInsets.only(top: 8, left: 16, right: 8),
                //   child: Text('', style: TextStyle(fontSize: 30, color: Colors.black)),
                // ),
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
            Row(
              children: [
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

            const SizedBox(height: 24),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isConfirmed && !isLoading
                    ? saveSettlement
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Record Settlement',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}