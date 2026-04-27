// lib/features/activity/presentation/screens/activity_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../groups/presentation/controller/group_controller.dart';

class ActivityScreen extends StatefulWidget {
  final String? groupId;

  const ActivityScreen({
    Key? key,
    this.groupId,
  }) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GroupsController groupsController = Get.find<GroupsController>();

  String? groupId;

  bool _expenseLoading = true;
  bool _settlementLoading = true;

  String _expenseError = '';
  String _settlementError = '';

  final List<ExpenseWithDebts> _expenses = [];
  final List<Map<String, dynamic>> _settlements = [];

  final Map<String, Map<String, String>> _memberNamesByGroup = {};

  @override
  void initState() {
    super.initState();

    groupId = widget.groupId;
    _tabController = TabController(length: 2, vsync: this);

    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------- INITIAL LOAD ----------------

  Future<void> _loadInitialData() async {
    await _loadMembers();

    _loadExpenses();
    _loadSettlements();
  }

  // ---------------- MEMBERS ----------------

  Future<void> _loadMembers() async {
    _memberNamesByGroup.clear();

    if (groupId != null && groupId!.isNotEmpty) {
      await _fetchMembers(groupId!, storeUnder: groupId!);
      return;
    }

    final groups = groupsController.groups;

    await Future.wait(
      groups.map(
            (group) => _fetchMembers(group.id, storeUnder: group.id),
      ),
    );
  }

  Future<void> _fetchMembers(
      String grpId, {
        required String storeUnder,
      }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(grpId)
        .collection('members')
        .get(const GetOptions(source: Source.serverAndCache));

    _memberNamesByGroup[storeUnder] = {
      for (final doc in snapshot.docs)
        doc.id: (doc.data()['name'] ?? 'Unknown').toString(),
    };
  }

  // ---------------- EXPENSES ----------------

  Future<void> _loadExpenses() async {
    if (mounted) {
      setState(() {
        _expenseLoading = true;
        _expenseError = '';
        _expenses.clear();
      });
    }

    try {
      final List<ExpenseWithDebts> temp = [];

      if (groupId != null && groupId!.isNotEmpty) {
        await _fetchExpenses(
          grpId: groupId!,
          storeUnder: groupId!,
          target: temp,
        );
      } else {
        final groups = groupsController.groups;

        await Future.wait(
          groups.map(
                (group) => _fetchExpenses(
              grpId: group.id,
              storeUnder: group.id,
              target: temp,
            ),
          ),
        );
      }

      temp.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;

      setState(() {
        _expenses.addAll(temp);
        _expenseLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _expenseLoading = false;
        _expenseError = e.toString();
      });
    }
  }

  Future<void> _fetchExpenses({
    required String grpId,
    required String storeUnder,
    required List<ExpenseWithDebts> target,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(grpId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .limit(30)
        .get(const GetOptions(source: Source.serverAndCache));

    final names = _memberNamesByGroup[storeUnder] ?? {};

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final paidBy = Map<String, dynamic>.from(data['paidBy'] ?? {});
      final split = Map<String, dynamic>.from(data['split'] ?? {});

      final payerId = paidBy.isNotEmpty ? paidBy.keys.first : '';

      final List<Debt> debts = [];

      split.forEach((userId, amount) {
        if (userId != payerId) {
          debts.add(
            Debt(
              debtorId: userId,
              amount: (amount as num).toDouble(),
            ),
          );
        }
      });

      target.add(
        ExpenseWithDebts(
          id: doc.id,
          groupId: grpId,
          description: (data['description'] ?? '').toString(),
          amount: ((data['amount'] ?? 0) as num).toDouble(),
          date:
          (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          payerId: payerId,
          debts: debts,
          memberNames: names,
        ),
      );
    }
  }

  // ---------------- SETTLEMENTS ----------------

  Future<void> _loadSettlements() async {
    if (mounted) {
      setState(() {
        _settlementLoading = true;
        _settlementError = '';
        _settlements.clear();
      });
    }

    try {
      final List<Map<String, dynamic>> temp = [];

      if (groupId != null && groupId!.isNotEmpty) {
        await _fetchSettlements(
          grpId: groupId!,
          storeUnder: groupId!,
          target: temp,
        );
      } else {
        final groups = groupsController.groups;

        await Future.wait(
          groups.map(
                (group) => _fetchSettlements(
              grpId: group.id,
              storeUnder: group.id,
              target: temp,
            ),
          ),
        );
      }

      temp.sort(
            (a, b) =>
            (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );

      if (!mounted) return;

      setState(() {
        _settlements.addAll(temp);
        _settlementLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _settlementLoading = false;
        _settlementError = e.toString();
      });
    }
  }

  Future<void> _fetchSettlements({
    required String grpId,
    required String storeUnder,
    required List<Map<String, dynamic>> target,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(grpId)
        .collection('settlements')
        .orderBy('date', descending: true)
        .limit(30)
        .get(const GetOptions(source: Source.serverAndCache));

    final names = _memberNamesByGroup[storeUnder] ?? {};

    for (final doc in snapshot.docs) {
      final data = doc.data();

      target.add({
        'id': doc.id,
        'groupId': grpId,
        'from': data['from'],
        'to': data['to'],
        'amount': ((data['amount'] ?? 0) as num).toDouble(),
        'date':
        (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        'paymentMethod': data['paymentMethod'] ?? '',
        'memberNames': names,
      });
    }
  }

  // ---------------- REFRESH ----------------

  Future<void> _refreshExpenses() async {
    await _loadExpenses();
  }

  Future<void> _refreshSettlements() async {
    await _loadSettlements();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text(
          'Activities',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2ECC71),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2ECC71),
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Settlements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _expensesTab(),
          _settlementsTab(),
        ],
      ),
    );
  }

  // ---------------- EXPENSE TAB ----------------

  Widget _expensesTab() {
    if (_expenseLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2ECC71),
        ),
      );
    }

    if (_expenseError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _expenseError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: _refreshExpenses,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_expenses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshExpenses,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No expenses found.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _expenses.length,
        itemBuilder: (_, index) {
          return _buildExpenseCard(_expenses[index]);
        },
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseWithDebts expense) {
    final payerName =
        expense.memberNames[expense.payerId] ?? 'Unknown';

    final date =
    DateFormat('yyyy/MM/dd – HH:mm').format(expense.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(
            Icons.receipt,
            color: Colors.blue,
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Paid by $payerName • $date',
        ),
        trailing: Text(
          '\$${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2ECC71),
          ),
        ),
        children: expense.debts.isEmpty
            ? const [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text('No debts (single payer)'),
          ),
        ]
            : [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: expense.debts.map((debt) {
                final debtor =
                    expense.memberNames[debt.debtorId] ??
                        'Unknown';

                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.person_outline,
                    size: 20,
                  ),
                  title: Text(debtor),
                  trailing: Text(
                    '\$${debt.amount.toStringAsFixed(2)} owes $payerName',
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SETTLEMENT TAB ----------------

  Widget _settlementsTab() {
    if (_settlementLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2ECC71),
        ),
      );
    }

    if (_settlementError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _settlementError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: _refreshSettlements,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_settlements.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshSettlements,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No settlements found.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshSettlements,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _settlements.length,
        itemBuilder: (_, index) {
          return _buildSettlementCard(_settlements[index]);
        },
      ),
    );
  }

  Widget _buildSettlementCard(
      Map<String, dynamic> settlement,
      ) {
    final names =
    settlement['memberNames'] as Map<String, String>;

    final fromName =
        names[settlement['from']] ?? 'Unknown';

    final toName =
        names[settlement['to']] ?? 'Unknown';

    final amount = settlement['amount'];

    final date = settlement['date'] as DateTime;

    final method = settlement['paymentMethod'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: const Icon(
            Icons.swap_horiz,
            color: Colors.green,
          ),
        ),
        title: Text(
          '$fromName → $toName',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('yyyy/MM/dd – HH:mm')
                  .format(date),
            ),
            if (method.toString().isNotEmpty)
              Text(
                'Method: $method',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Text(
          NumberFormat.currency(
            symbol: '',
            decimalDigits: 0,
          ).format(amount),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2ECC71),
          ),
        ),
      ),
    );
  }
}

// ---------------- MODELS ----------------

class ExpenseWithDebts {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final DateTime date;
  final String payerId;
  final List<Debt> debts;
  final Map<String, String> memberNames;

  ExpenseWithDebts({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.date,
    required this.payerId,
    required this.debts,
    required this.memberNames,
  });
}

class Debt {
  final String debtorId;
  final double amount;

  Debt({
    required this.debtorId,
    required this.amount,
  });
}