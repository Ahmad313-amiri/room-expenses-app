import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../expenses/presentations/controller/expense_controller.dart';
import '../../domain/entities/member_entity.dart';

class GroupExpenseSplitScreen extends StatefulWidget {
  final String groupId;
  final List<MemberEntity> members;

  const GroupExpenseSplitScreen({
    super.key,
    required this.groupId,
    required this.members,
  });

  @override
  State<GroupExpenseSplitScreen> createState() =>
      _GroupExpenseSplitScreenState();
}

class _GroupExpenseSplitScreenState extends State<GroupExpenseSplitScreen> {
  late GroupExpenseSplitController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      GroupExpenseSplitController(addExpenseUseCase: Get.find()),
    );
    controller.init(widget.groupId, widget.members);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'New Group Expense',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.saveExpense(context),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(
            () => Form(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Total Amount',
                  style: TextStyle(color: Colors.grey),
                ),
                TextFormField(
                  controller: controller.amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(fontSize: 48, color: Colors.grey),
                  ),
                  onChanged: (_) => controller.updateCustomSharesForMethod(),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('What was it for?'),
                TextFormField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Weekend Getaway Dinner',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildSectionTitle('Who paid?'),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.members.length,
                    itemBuilder: (context, index) =>
                        _buildPayerAvatar(widget.members[index]),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTab('Equally', 'Equally'),
                      _buildTab('Percentage', 'Percentage'),
                      _buildTab('Custom', 'Custom'),
                      _buildTab('Shares', 'Shares'),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _buildSectionTitle('Split between'),
                ...widget.members.map((member) => _buildSplitRow(member)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREVIEW SHARES',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${controller.participantIds.length} people'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Accounted',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '\$${controller.calculatedTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (!controller.isSplitValid &&
                              controller.totalAmount > 0)
                            Text(
                              'Diff: \$${(controller.totalAmount - controller.calculatedTotal).toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSplitValid
                        ? () => controller.saveExpense(context)
                        : null,
                    icon: const Icon(Icons.receipt_long),
                    label: const Text(
                      'Confirm Expense',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A60FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPayerAvatar(MemberEntity member) {
    return Obx(() {
      final isSelected = controller.selectedPayerId.value == member.userId;
      return Padding(
        padding: const EdgeInsets.only(right: 15),
        child: InkWell(
          onTap: () => controller.selectedPayerId.value = member.userId,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isSelected
                        ? Colors.blue
                        : Colors.grey[200],
                    child: CircleAvatar(
                      radius: 27,
                      backgroundImage: member.photoUrl != null
                          ? NetworkImage(member.photoUrl!)
                          : null,
                      child: member.photoUrl == null
                          ? Text(member.name[0].toUpperCase())
                          : null,
                    ),
                  ),
                  if (isSelected)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                member.name,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTab(String label, String method) {
    return Obx(() {
      final isActive = controller.splitMethod.value == method;
      return Expanded(
        child: InkWell(
          onTap: () {
            controller.splitMethod.value = method;
            controller.updateCustomSharesForMethod();
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                ),
              ]
                  : [],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.blue : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSplitRow(MemberEntity member) {
    final userId = member.userId;
    final isCustomEditable = controller.splitMethod.value != 'Equally';
    final isShares = controller.splitMethod.value == 'Shares';

    return Obx(() {
      final isChecked = controller.participantIds.contains(userId);
      final share = controller.calculateShares()[userId] ?? 0.0;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (v) {
                if (v == true) {
                  if (!controller.participantIds.contains(userId))
                    controller.participantIds.add(userId);
                } else {
                  controller.participantIds.remove(userId);
                }
                controller.updateCustomSharesForMethod();
              },
              activeColor: Colors.blue,
            ),
            CircleAvatar(
              radius: 15,
              backgroundImage: member.photoUrl != null
                  ? NetworkImage(member.photoUrl!)
                  : null,
              child: member.photoUrl == null
                  ? Text(member.name[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (isShares)
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: (controller.shareCounts[userId] ?? 1.0).toStringAsFixed(0),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    suffixText: 'share',
                  ),
                  onChanged: (value) {
                    final newShares = double.tryParse(value) ?? 0.0;
                    if (newShares > 0) {
                      controller.shareCounts[userId] = newShares;
                    } else {
                      controller.shareCounts[userId] = 1.0;
                    }
                    controller.shareCounts.refresh();
                  },
                ),
              )
            else if (isCustomEditable)
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: controller.splitMethod.value == 'Percentage'
                      ? controller.customShares[userId]?.toStringAsFixed(2) ?? '0.00'
                      : share.toStringAsFixed(2),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixText: controller.splitMethod.value == 'Percentage' ? '%' : '',
                  ),
                  onChanged: (value) {
                    final newValue = double.tryParse(value) ?? 0.0;
                    controller.customShares[userId] = newValue;
                    controller.customShares.refresh();
                  },
                ),
              )
            else
              Text(
                '\$${share.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
          ],
        ),
      );
    });
  }
}