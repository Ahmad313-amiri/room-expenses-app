import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_logger.dart';
import '../../../../core/util/error_handler.dart';
import '../../../activity/presentation/controller/activity_controller.dart';
import '../../../groups/presentation/controller/group_controller.dart';

class ActivityScreen extends StatefulWidget {
  final String? groupId;

  const ActivityScreen({Key? key, this.groupId}) : super(key: key);

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
  bool _summaryLoading = true;

  String _expenseError = '';
  String _settlementError = '';
  String _summaryError = '';

  final List<ExpenseWithDebts> _expenses = [];
  final List<Map<String, dynamic>> _settlements = [];
  final List<GroupSummary> _summaries = [];

  final Map<String, Map<String, String>> _groupMemberNames = {};
  final Map<String, Map<String, String>> _groupMemberPhones = {};

  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    groupId = widget.groupId;
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activityController = Get.find<ActivityController>();
      if (activityController.activities.isEmpty) {
        activityController.fetchAllActivities();
      }
    });

    if (groupId != null && groupId!.isNotEmpty) {
      _loadInitialData();
    } else {
      _setupGroupListener();
    }
  }

  void _setupGroupListener() {
    if (groupsController.groups.isNotEmpty && !_initialLoadDone) {
      _loadInitialData();
      return;
    }
    ever(groupsController.groups, (List groups) {
      if (groups.isNotEmpty && !_initialLoadDone && mounted) {
        _loadInitialData();
      } else if (groups.isEmpty && !_initialLoadDone && mounted) {
        _finishLoadingWithoutData();
      }
    });
  }
  void _finishLoadingWithoutData() {
    if (mounted) {
      setState(() {
        _expenseLoading = false;
        _settlementLoading = false;
        _summaryLoading = false;
        _initialLoadDone = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_initialLoadDone) return;
    _initialLoadDone = true;
    await _loadMembers();
    await Future.wait([
      _loadExpenses(),
      _loadSettlements(),
      _loadSummary(),
    ]);
    if (mounted) {
      setState(() {
        if (_expenses.isEmpty) _expenseLoading = false;
        if (_settlements.isEmpty) _settlementLoading = false;
        if (_summaries.isEmpty) _summaryLoading = false;
      });
    }
  }

  // ==========================================================
  // Members & Display Name
  // ==========================================================
  Future<void> _loadMembers() async {
    _groupMemberNames.clear();
    _groupMemberPhones.clear();

    if (groupId != null && groupId!.isNotEmpty) {
      await _fetchMembers(groupId!, storeUnder: groupId!);
      return;
    }

    final groups = groupsController.groups;
    if (groups.isEmpty) return;

    await Future.wait(
      groups.map((group) => _fetchMembers(group.id, storeUnder: group.id)),
    );
  }

  Future<void> _fetchMembers(String grpId, {required String storeUnder}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(grpId)
        .collection('members')
        .get(const GetOptions(source: Source.serverAndCache));

    final names = <String, String>{};
    final phones = <String, String>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final userId = doc.id;
      final name = (data['name'] ?? '').toString().trim();
      final phone = (data['phoneNumber'] ?? data['phone'] ?? '').toString().trim();
      if (name.isNotEmpty) names[userId] = name;
      if (phone.isNotEmpty) phones[userId] = phone;
    }

    _groupMemberNames[storeUnder] = names;
    _groupMemberPhones[storeUnder] = phones;
  }

  String _getDisplayName(String groupKey, dynamic userId) {
    if (userId == null) return 'Unknown';
    final id = userId.toString();

    final name = _groupMemberNames[groupKey]?[id];
    if (name != null && name.trim().isNotEmpty) return name;

    final phone = _groupMemberPhones[groupKey]?[id];
    if (phone != null && phone.trim().isNotEmpty) return phone;

    if (id.length > 8) {
      return '${id.substring(0, 8)}...';
    }
    return id.isNotEmpty ? 'User_$id' : 'Unknown';
  }

  // ==========================================================
  // Expenses
  // ==========================================================
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
        await _fetchExpenses(grpId: groupId!, storeUnder: groupId!, target: temp);
      } else {
        final groups = groupsController.groups;
        if (groups.isEmpty) {
            if (mounted) setState(() => _expenseLoading = false);
          return;
        }
        await Future.wait(
          groups.map((group) => _fetchExpenses(
            grpId: group.id,
            storeUnder: group.id,
            target: temp,
          )),
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
      ErrorHandler.handleError('Error', 'Failed to load expenses: ${e.toString()}');
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

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final paidBy = Map<String, dynamic>.from(data['paidBy'] ?? {});
      final split = Map<String, dynamic>.from(data['split'] ?? {});
      final payerId = paidBy.isNotEmpty ? paidBy.keys.first : '';

      final List<Debt> debts = [];
      split.forEach((userId, amount) {
        if (userId != payerId) {
          debts.add(Debt(debtorId: userId, amount: (amount as num).toDouble()));
        }
      });

      target.add(ExpenseWithDebts(
        id: doc.id,
        groupId: grpId,
        description: (data['description'] ?? 'Expense').toString(),
        amount: ((data['amount'] ?? 0) as num).toDouble(),
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        payerId: payerId,
        debts: debts,
        groupKey: storeUnder,
      ));
    }
  }

  Future<void> _deleteExpense(ExpenseWithDebts expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(expense.groupId)
          .collection('expenses')
          .doc(expense.id)
          .delete();
      await _loadExpenses();
      await _loadSummary();
      if (mounted) {
        ErrorHandler.showSuccess('Success', 'Expense deleted successfully');
      }
    } catch (e) {
      AppLogger.error('Delete expense error', e);
      if (mounted) {
        ErrorHandler.handleError(
          'Delete Failed',
          'You do not have permission to delete this expense or an error occurred: ${e.toString()}',
        );
      }
    }
  }

  // ==========================================================
  // Settlements
  // ==========================================================
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
        await _fetchSettlements(grpId: groupId!, storeUnder: groupId!, target: temp);
      } else {
        final groups = groupsController.groups;
        if (groups.isEmpty) {
          if (mounted) setState(() => _settlementLoading = false);
          return;
        }
        await Future.wait(
          groups.map((group) => _fetchSettlements(
            grpId: group.id,
            storeUnder: group.id,
            target: temp,
          )),
        );
      }

      temp.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

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
      ErrorHandler.handleError('Error', 'Failed to load settlements: ${e.toString()}');
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

    for (final doc in snapshot.docs) {
      final data = doc.data();
      target.add({
        'id': doc.id,
        'groupId': grpId,
        'from': data['from'],
        'to': data['to'],
        'amount': ((data['amount'] ?? 0) as num).toDouble(),
        'date': (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        'paymentMethod': data['paymentMethod'],
        'groupKey': storeUnder,
      });
    }
  }

  Future<void> _deleteSettlement(Map<String, dynamic> settlement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Settlement'),
        content: const Text('Are you sure you want to delete this settlement?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(settlement['groupId'])
          .collection('settlements')
          .doc(settlement['id'])
          .delete();
      await _loadSettlements();
      await _loadSummary();
      if (mounted) {
        ErrorHandler.showSuccess('Success', 'Settlement deleted successfully');
      }
    } catch (e) {
      AppLogger.error('Delete settlement error', e);
      if (mounted) {
        ErrorHandler.handleError(
          'Delete Failed',
          'You do not have permission to delete this settlement or an error occurred: ${e.toString()}',
        );
      }
    }
  }

  // ==========================================================
  // Summary
  // ==========================================================
  Future<void> _loadSummary() async {
    if (mounted) {
      setState(() {
        _summaryLoading = true;
        _summaryError = '';
        _summaries.clear();
      });
    }

    try {
      final groups = groupsController.groups;
      if (groups.isEmpty) {
        if (mounted) setState(() => _summaryLoading = false);
        return;
      }

      final List<GroupSummary> tempSummaries = [];

      for (final group in groups) {
        final expensesSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(group.id)
            .collection('expenses')
            .get(const GetOptions(source: Source.serverAndCache));

        final membersSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(group.id)
            .collection('members')
            .get(const GetOptions(source: Source.serverAndCache));

        final Set<String> memberIds = membersSnapshot.docs.map((d) => d.id).toSet();

        final Map<String, double> paidByUser = {};
        final Map<String, double> splitByUser = {};

        for (final doc in expensesSnapshot.docs) {
          final data = doc.data();
          final amount = ((data['amount'] ?? 0) as num).toDouble();

          final paidByMap = Map<String, dynamic>.from(data['paidBy'] ?? {});
          if (paidByMap.isNotEmpty) {
            final payerId = paidByMap.keys.first;
            paidByUser[payerId] = (paidByUser[payerId] ?? 0) + amount;
          }

          final splitMap = Map<String, dynamic>.from(data['split'] ?? {});
          splitMap.forEach((userId, value) {
            splitByUser[userId] = (splitByUser[userId] ?? 0) + (value as num).toDouble();
          });
        }

        final Map<String, double> netBalance = {};
        final allUserIds = {...paidByUser.keys, ...splitByUser.keys, ...memberIds};

        for (final userId in allUserIds) {
          final paid = paidByUser[userId] ?? 0.0;
          final split = splitByUser[userId] ?? 0.0;
          final net = split - paid;
          if (net != 0) {
            netBalance[userId] = net;
          }
        }

        tempSummaries.add(GroupSummary(
          groupId: group.id,
          groupName: group.name,
          totalExpenses: expensesSnapshot.docs.fold(0.0,
                  (sum, doc) => sum + ((doc['amount'] ?? 0) as num).toDouble()),
          netBalances: netBalance,
        ));
      }

      if (!mounted) return;
      setState(() {
        _summaries.addAll(tempSummaries);
        _summaryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _summaryLoading = false;
        _summaryError = e.toString();
      });
      ErrorHandler.handleError('Error', 'Failed to load summary: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 6, right: 6, top: 5, bottom: 0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1D5CFF),
                indicatorColor: const Color(0xFF1D5CFF),
                tabs: const [
                  Tab(text: 'Expenses', icon: Icon(Icons.receipt_long)),
                  Tab(text: 'Settlements', icon: Icon(Icons.swap_horiz)),
                  Tab(text: 'Summary', icon: Icon(Icons.analytics)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _expensesTab(),
                    _settlementsTab(),
                    _summaryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // Expenses Tab UI
  // ==========================================================
  Widget _expensesTab() {
    if (_expenseLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_expenses.isEmpty) {
      return const Center(child: Text('No expenses found'));
    }
    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: ListView.builder(
        itemCount: _expenses.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => _buildExpenseCard(_expenses[i]),
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseWithDebts expense) {
    final payer = _getDisplayName(expense.groupKey, expense.payerId);
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Expense'),
            content: Text('Delete "${expense.description}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteExpense(expense),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      expense.description,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D5CFF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Paid by $payer • ${DateFormat('yyyy/MM/dd – HH:mm').format(expense.date)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (expense.debts.isNotEmpty) ...[
                const Divider(height: 20),
                const Text(
                  'Debts:',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: expense.debts.length,
                    itemBuilder: (ctx, idx) {
                      final debt = expense.debts[idx];
                      final debtorName = _getDisplayName(expense.groupKey, debt.debtorId);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '  • $debtorName',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${debt.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // Settlements Tab UI
  // ==========================================================
  Widget _settlementsTab() {
    if (_settlementLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_settlements.isEmpty) {
      return const Center(child: Text('No settlements found'));
    }
    return RefreshIndicator(
      onRefresh: _loadSettlements,
      child: ListView.builder(
        itemCount: _settlements.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => _buildSettlementCard(_settlements[i]),
      ),
    );
  }

  Widget _buildSettlementCard(Map<String, dynamic> settlement) {
    final groupKey = settlement['groupKey']?.toString() ?? '';
    final fromName = _getDisplayName(groupKey, settlement['from']);
    final toName = _getDisplayName(groupKey, settlement['to']);
    final amount = (settlement['amount'] as num?)?.toDouble() ?? 0.0;
    final date = settlement['date'] as DateTime? ?? DateTime.now();
    final method = settlement['paymentMethod']?.toString() ?? '';

    return Dismissible(
      key: Key(settlement['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Settlement'),
            content: const Text('Delete this settlement?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteSettlement(settlement),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: const Icon(Icons.swap_horiz, color: Colors.green),
          ),
          title: Text('$fromName → $toName', overflow: TextOverflow.ellipsis, softWrap: true),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('yyyy/MM/dd – HH:mm').format(date)),
              if (method.isNotEmpty) Text('Method: $method', style: const TextStyle(fontSize: 12)),
            ],
          ),
          trailing: Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D5CFF)),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // Summary Tab UI
  // ==========================================================
  Widget _summaryTab() {
    if (_summaryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_summaries.isEmpty) {
      return const Center(child: Text('No summary found'));
    }
    return RefreshIndicator(
      onRefresh: _loadSummary,
      child: ListView.builder(
        itemCount: _summaries.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) => _buildSummaryCard(_summaries[i]),
      ),
    );
  }

  Widget _buildSummaryCard(GroupSummary summary) {
    final entries = summary.netBalances.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    final visibleEntries = entries.take(5).toList();
    final remainingCount = entries.length - visibleEntries.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.groupName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Total Expenses: \$${summary.totalExpenses.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF1D5CFF), fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('All settled up!', style: TextStyle(color: Colors.green)),
              )
            else ...[
              ...visibleEntries.map((entry) {
                final name = _getDisplayName(summary.groupId, entry.key);
                final amount = entry.value.abs().toStringAsFixed(2);
                final isOwes = entry.value > 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOwes ? 'owes \$$amount' : 'is owed \$$amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isOwes ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (remainingCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupBalanceDetailScreen(
                              groupId: summary.groupId,
                              groupName: summary.groupName,
                              netBalances: summary.netBalances,
                              getDisplayName: (userId) => _getDisplayName(summary.groupId, userId),
                            ),
                          ),
                        );
                        _loadSummary();
                      },
                      icon: const Icon(Icons.people_alt, size: 18),
                      label: Text('Show all $remainingCount members'),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF1D5CFF)),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// Detail Screen
// ==========================================================
class GroupBalanceDetailScreen extends StatelessWidget {
  final String groupId;
  final String groupName;
  final Map<String, double> netBalances;
  final String Function(String userId) getDisplayName;

  const GroupBalanceDetailScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.netBalances,
    required this.getDisplayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entries = netBalances.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(groupName, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: entries.isEmpty
          ? const Center(child: Text('All settled up!'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: entries.length,
        itemBuilder: (ctx, index) {
          final entry = entries[index];
          final name = getDisplayName(entry.key);
          final amount = entry.value.abs().toStringAsFixed(2);
          final isOwes = entry.value > 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isOwes ? Colors.red.shade50 : Colors.green.shade50,
                child: Icon(
                  isOwes ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isOwes ? Colors.red.shade700 : Colors.green.shade700,
                ),
              ),
              title: Text(name, overflow: TextOverflow.ellipsis, softWrap: true),
              trailing: Text(
                isOwes ? 'owes \$$amount' : 'is owed \$$amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isOwes ? Colors.red.shade700 : Colors.green.shade700,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================
// Models
// ==========================================================
class ExpenseWithDebts {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final DateTime date;
  final String payerId;
  final List<Debt> debts;
  final String groupKey;

  ExpenseWithDebts({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.date,
    required this.payerId,
    required this.debts,
    required this.groupKey,
  });
}

class Debt {
  final String debtorId;
  final double amount;
  Debt({required this.debtorId, required this.amount});
}

class GroupSummary {
  final String groupId;
  final String groupName;
  final double totalExpenses;
  final Map<String, double> netBalances;

  GroupSummary({
    required this.groupId,
    required this.groupName,
    required this.totalExpenses,
    required this.netBalances,
  });
}