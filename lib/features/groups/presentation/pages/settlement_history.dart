import 'package:flutter/material.dart';

// ---------------------------
// Model: Settlement Record
// ---------------------------
class SettlementRecord {
  final String title;
  final String amount; // Stored as string, but can parse to number for sorting
  final String date;   // Format: 'Oct 28, 2023'
  final String status; // 'verified', 'pending', 'rejected'

  SettlementRecord({
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });
}

// ---------------------------
// Main Stateful Widget
// ---------------------------
class SortableSearchableHistoryPage extends StatefulWidget {
  const SortableSearchableHistoryPage({super.key});

  @override
  State<SortableSearchableHistoryPage> createState() =>
      _SortableSearchableHistoryPageState();
}

class _SortableSearchableHistoryPageState
    extends State<SortableSearchableHistoryPage> {
  // ---------------------------
  // State variables
  // ---------------------------
  String _searchQuery = ''; // Text search query
  String _selectedFilter = 'All'; // Status filter
  String _sortBy = 'Date'; // Current sort field: 'Date' or 'Amount'
  bool _ascending = false; // Sort order: true = ascending

  // ---------------------------
  // Sample Data
  // ---------------------------
  final List<SettlementRecord> _allRecords = [
    SettlementRecord(
        title: 'Dinner at Restaurant',
        amount: '2,500',
        date: 'Oct 28, 2023',
        status: 'verified'),
    SettlementRecord(
        title: 'Internet Share',
        amount: '800',
        date: 'Oct 26, 2023',
        status: 'rejected'),
    SettlementRecord(
        title: 'Taxi to Office',
        amount: '500',
        date: 'Oct 25, 2023',
        status: 'pending'),
    SettlementRecord(
        title: 'Office Groceries',
        amount: '4,000',
        date: 'Oct 20, 2023',
        status: 'verified'),
  ];

  // ---------------------------
  // Combined filter + search + sort logic
  // ---------------------------
  List<SettlementRecord> get _filteredRecords {
    // 1. Filter by status
    List<SettlementRecord> filtered = _allRecords.where((record) {
      final matchesStatus =
          _selectedFilter == 'All' || record.status == _selectedFilter.toLowerCase();
      final matchesSearch =
      record.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    // 2. Sort filtered list
    filtered.sort((a, b) {
      if (_sortBy == 'Date') {
        // Convert string to DateTime
        DateTime dateA = DateTime.parse(_convertToDate(a.date));
        DateTime dateB = DateTime.parse(_convertToDate(b.date));
        return _ascending
            ? dateA.compareTo(dateB)
            : dateB.compareTo(dateA);
      } else {
        // Sort by amount (numeric)
        int amtA = int.tryParse(a.amount.replaceAll(',', '')) ?? 0;
        int amtB = int.tryParse(b.amount.replaceAll(',', '')) ?? 0;
        return _ascending ? amtA.compareTo(amtB) : amtB.compareTo(amtA);
      }
    });

    return filtered;
  }

  // Helper to convert date string like 'Oct 28, 2023' to 'YYYY-MM-DD'
  String _convertToDate(String input) {
    final months = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'May': '05',
      'Jun': '06',
      'Jul': '07',
      'Aug': '08',
      'Sep': '09',
      'Oct': '10',
      'Nov': '11',
      'Dec': '12'
    };
    final parts = input.split(' ');
    final month = months[parts[0]] ?? '01';
    final day = parts[1].replaceAll(',', '');
    final year = parts[2];
    return '$year-$month-${day.padLeft(2, '0')}';
  }

  // ---------------------------
  // Build UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settlement History',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ---------------------------
          // Search bar
          // ---------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ---------------------------
          // Status filter chips
          // ---------------------------
          _buildFilterBar(),

          // ---------------------------
          // Sorting row
          // ---------------------------
          _buildSortBar(),

          // ---------------------------
          // Transaction list
          // ---------------------------
          Expanded(
            child: _filteredRecords.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) =>
                  _buildCard(_filteredRecords[index]),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Filter Chips (Status)
  // ---------------------------
  Widget _buildFilterBar() {
    final filters = ['All', 'Verified', 'Pending', 'Rejected'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(filter,
                  style: TextStyle(
                      fontSize: 12,
                      color: _selectedFilter == filter
                          ? Colors.white
                          : Colors.black)),
              selected: _selectedFilter == filter,
              selectedColor: Colors.blue,
              backgroundColor: Colors.grey[100],
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
            ),
          );
        },
      ),
    );
  }

  // ---------------------------
  // Sort Bar
  // ---------------------------
  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text('Sort by:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortBy,
            items: ['Date', 'Amount']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _sortBy = value);
            },
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
                _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 20),
            onPressed: () => setState(() => _ascending = !_ascending),
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Transaction Card
  // ---------------------------
  Widget _buildCard(SettlementRecord record) {
    Color statusColor = record.status == 'verified'
        ? Colors.green
        : record.status == 'rejected'
        ? Colors.red
        : Colors.orange;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[100]!),
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(record.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(record.date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(record.amount,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(record.status.toUpperCase(),
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // Empty State
  // ---------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('No $_selectedFilter transactions found',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
