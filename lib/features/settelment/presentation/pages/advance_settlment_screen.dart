import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../../core/util/net_work.dart';
import '../../../groups/presentation/controller/group_controller.dart';
import '../../data/data_sources/settelment_remote_datasource.dart';

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
  bool isMembersLoading = true;
  String membersError = '';

  late final SettlementRemoteDataSource _settlementDataSource;
  late final NetworkService _networkService;
  late final GroupsController _groupsController;

  @override
  void initState() {
    super.initState();
    _settlementDataSource = SettlementRemoteDataSource();
    _networkService = Get.find<NetworkService>();
    _groupsController = Get.find<GroupsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMembers();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    if (!_networkService.isOnline) {
      setState(() {
        isMembersLoading = false;
        membersError = 'No internet connection. Cannot load members.';
      });
      return;
    }

    setState(() {
      isMembersLoading = true;
      membersError = '';
    });

    try {
      final memberEntities = await _groupsController.getAllMembersForSettlement(widget.groupId);
      members = memberEntities.map((m) {
        return {
          'id': m.userId,
          'name': m.name,
          'userId': m.userId,
        };
      }).toList();
      AppLogger.i('Fetched ${members.length} members for settlement');
      setState(() => isMembersLoading = false);
    } catch (e, stack) {
      AppLogger.e('Error fetching members for settlement', e, stack);
      setState(() {
        membersError = ErrorHandler.getUserFriendlyException(e);
        isMembersLoading = false;
      });
    }
  }

  Future<void> _saveSettlement(BuildContext ctx) async {
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (selectedPayer == null || selectedReceiver == null) {
      ErrorHandler.handleValidationError('Please select both payer and receiver');
      return;
    }
    if (selectedPayer == selectedReceiver) {
      ErrorHandler.handleValidationError('Payer and receiver cannot be the same');
      return;
    }
    if (amount <= 0) {
      ErrorHandler.handleValidationError('Please enter a valid amount greater than zero');
      return;
    }
    if (!_isConfirmed) {
      ErrorHandler.handleValidationError('Please confirm that you have made this payment');
      return;
    }
    if (!_networkService.isOnline) {
      ErrorHandler.handleError('Offline', 'You need internet connection to record settlement');
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = {
        'from': selectedPayer,
        'to': selectedReceiver,
        'amount': amount,
        'paymentMethod': _paymentMethod,
        'date': _selectedDate,
        'groupId': widget.groupId,
      };
      await _settlementDataSource.saveSettlement(widget.groupId, data);
      AppLogger.i('Settlement saved in group ${widget.groupId}');

      if (mounted) {
        // نمایش پیام موفقیت
        ErrorHandler.showSuccess('Success', 'Settlement recorded successfully');

        // تأخیر برای دیده شدن پیام
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // بستن صفحه و بازگشت با نتیجه true (برای رفرش صفحه قبلی در صورت نیاز)
          Navigator.of(ctx).pop(true);
        }
      }
    } catch (e, stack) {
      AppLogger.e('Failed to save settlement', e, stack);
      if (mounted) {
        final message = ErrorHandler.getUserFriendlyException(e);
        ErrorHandler.handleError('Failed to Save', message);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
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
            if (isMembersLoading)
              const Center(child: CircularProgressIndicator())
            else if (membersError.isNotEmpty)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(membersError, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchMembers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else ...[
                DropdownButtonFormField<String>(
                  value: selectedPayer,
                  hint: const Text("Select Payer"),
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: members.map<DropdownMenuItem<String>>((m) {
                    return DropdownMenuItem<String>(
                      value: m['userId'] as String,
                      child: Text(m['name'] as String),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedPayer = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedReceiver,
                  hint: const Text("Select Receiver"),
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: members.map<DropdownMenuItem<String>>((m) {
                    return DropdownMenuItem<String>(
                      value: m['userId'] as String,
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _paymentMethod,
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() => _paymentMethod = newValue!);
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isConfirmed,
                        activeColor: Colors.blue,
                        onChanged: (val) => setState(() => _isConfirmed = val ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'I confirm that this payment has been made in real life.',
                          style: TextStyle(fontWeight: FontWeight.w500),
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
                    onPressed: (_isConfirmed && !isLoading && selectedPayer != null && selectedReceiver != null)
                        ? () => _saveSettlement(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      disabledBackgroundColor: Colors.grey.shade300,
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
                const SizedBox(height: 20),
              ],
          ],
        ),
      ),
    );
  }
}