import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplitMethodScreen extends StatefulWidget {
  const SplitMethodScreen({super.key});

  @override
  State<SplitMethodScreen> createState() => _SplitMethodScreenState();
}

class _SplitMethodScreenState extends State<SplitMethodScreen> with SingleTickerProviderStateMixin {
  // --- Tab controller for syncing tabs and progress dots
  late TabController _tabController;

  // --- Total expense for this split
  final double totalExpense = 1200.0;

  // --- Member data
  final List<Map<String, dynamic>> members = [
    {'id': 'AM', 'name': 'Alice Miller', 'role': 'You', 'color': Color(0xFFE3F2FD)},
    {'id': 'BJ', 'name': 'Bob Johnson', 'role': 'Friend', 'color': Color(0xFFFFF3E0)},
    {'id': 'CR', 'name': 'Charlie Reed', 'role': 'Friend', 'color': Color(0xFFE8F5E9)},
  ];

  // --- Custom tab controllers & state
  late Map<String, TextEditingController> _customControllers;
  double _totalCustom = 800.0; // Initial value as per screenshot

  // --- Percentage tab controllers & state
  late Map<String, TextEditingController> _percentControllers;
  double _totalPercent = 100.0; // Initial value as per screenshot

  @override
  void initState() {
    super.initState();

    // --- Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // update progress dots and footer
      }
    });

    // --- Initialize text controllers with sample values
    _customControllers = {
      'AM': TextEditingController(text: '450.00'),
      'BJ': TextEditingController(text: '350.00'),
      'CR': TextEditingController(text: '0.00'),
    };

    _percentControllers = {
      'AM': TextEditingController(text: '33'),
      'BJ': TextEditingController(text: '34'),
      'CR': TextEditingController(text: '33'),
    };
  }

  // --- Update total for Custom tab
  void _updateCustomTotal() {
    double sum = 0;
    _customControllers.forEach((key, controller) {
      sum += double.tryParse(controller.text) ?? 0;
    });
    setState(() => _totalCustom = sum);
  }

  // --- Update total for Percentage tab
  void _updatePercentTotal() {
    double sum = 0;
    _percentControllers.forEach((key, controller) {
      sum += double.tryParse(controller.text) ?? 0;
    });
    setState(() => _totalPercent = sum);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Split Method', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF1D5CFF), fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1D5CFF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Equal'),
            Tab(text: 'Custom'),
            Tab(text: 'Percentage')
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildProgressDots(), // Animated progress dots
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEqualTab(),      // Equal tab content
                _buildCustomTab(),     // Custom tab content
                _buildPercentageTab()  // Percentage tab content
              ],
            ),
          ),
          _buildDynamicFooter(), // Dynamic footer
        ],
      ),
    );
  }

  // --- Progress Dots Widget
  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = _tabController.index == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1D5CFF) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // --- Equal Tab
  Widget _buildEqualTab() {
    double share = totalExpense / members.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalCard(),
          const SizedBox(height: 24),
          const Text('SPLIT DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...members.map((m) => _buildMemberCard(m, "\$${share.toStringAsFixed(2)}")),
        ],
      ),
    );
  }

  // --- Custom Tab
  Widget _buildCustomTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalCard(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('SPLIT BY MEMBER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
              Text('USD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          ...members.map((m) => _buildInputCard(
            m,
            _customControllers[m['id']]!,
            "\$",
                (v) => _updateCustomTotal(),
          )),
        ],
      ),
    );
  }

  // --- Percentage Tab
  Widget _buildPercentageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPercentageHeaderCard(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Member Shares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('PERCENTAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          ...members.map((m) {
            double p = double.tryParse(_percentControllers[m['id']]!.text) ?? 0;
            String calcAmount = (p / 100 * totalExpense).toStringAsFixed(2);
            return _buildInputCard(
              m,
              _percentControllers[m['id']]!,
              "%",
                  (v) => _updatePercentTotal(),
              subText: "(\$$calcAmount)",
            );
          }),
        ],
      ),
    );
  }

  // --- Total Card Widget
  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TOTAL EXPENSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('\\${totalExpense.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ]),
          const Icon(Icons.receipt_long_outlined, color: Color(0xFF1D5CFF), size: 28)
        ],
      ),
    );
  }

  // --- Percentage header
  Widget _buildPercentageHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Percentage Split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Total: \\${totalExpense.toStringAsFixed(2)} | ${members.length} members', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
            child: const Text('100% total required', style: TextStyle(color: Color(0xFF1D5CFF), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // --- Member Card
  Widget _buildMemberCard(Map<String, dynamic> m, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: m['color'], child: Text(m['id'], style: const TextStyle(color: Color(0xFF1D5CFF), fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold)), Text(m['role'], style: const TextStyle(color: Colors.grey, fontSize: 12))])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(20)),
            child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Input Card for Custom / Percentage
  Widget _buildInputCard(Map<String, dynamic> m, TextEditingController controller, String symbol, Function(String) onChanged, {String? subText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: m['color'], child: Text(m['id'], style: const TextStyle(color: Color(0xFF1D5CFF), fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                if (subText != null) Text(subText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: onChanged,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: symbol == "\$" ? "\$ " : null,
                suffixText: symbol == "%" ? " %" : null,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dynamic Footer
  Widget _buildDynamicFooter() {
    String title = "TOTAL SPLIT";
    String amount = "\$${totalExpense.toStringAsFixed(2)}";
    String btnText = "Confirm Split";
    bool isBalanced = true;
    double remaining = 0;

    if (_tabController.index == 1) {
      // Custom tab
      title = "TOTAL SPECIFIED";
      amount = "\$${_totalCustom.toStringAsFixed(2)}";
      remaining = totalExpense - _totalCustom;
      isBalanced = remaining == 0;
      btnText = "Confirm Custom Split";
    } else if (_tabController.index == 2) {
      // Percentage tab
      title = "TOTAL PERCENTAGE";
      amount = "${_totalPercent.toInt()}%";
      isBalanced = _totalPercent == 100;
      btnText = "Confirm Percentage Split";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade100))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Row(
                  children: [
                    Text(amount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isBalanced ? const Color(0xFF2ECC71) : const Color(0xFF1D5CFF))),
                    if (isBalanced)
                      const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 20)),
                  ],
                ),
              ]),
              if (_tabController.index == 1 && !isBalanced)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('REMAINING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text('\\${remaining.abs().toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: remaining > 0 ? Colors.orange : Colors.red)),
                  ],
                ),
              if (_tabController.index == 0)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: const [
                  Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text('Balanced', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
                ]),
            ],
          ),
          if (_tabController.index == 2)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _totalPercent / 100,
                  backgroundColor: Colors.grey.shade100,
                  color: isBalanced ? const Color(0xFF2ECC71) : const Color(0xFF1D5CFF),
                  minHeight: 6,
                ),
              ),
            ),
          const SizedBox(height: 16),
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
              children: [
                Text(btnText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
