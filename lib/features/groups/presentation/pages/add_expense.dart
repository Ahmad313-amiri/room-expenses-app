import 'package:flutter/material.dart';

/// Equal Split Content
/// Use this inside your existing tab view for the "Equal" tab
class EqualSplitContent extends StatelessWidget {
  const EqualSplitContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data based on your design
    final List<Map<String, dynamic>> members = [
      {'name': 'Alice Miller', 'role': 'Standard Member', 'initials': 'AM', 'color': const Color(0xFFE3F2FD)},
      {'name': 'Bob Johnson', 'role': 'Payer', 'initials': 'BJ', 'color': const Color(0xFFFFF3E0)},
      {'name': 'Charlie Reed', 'role': 'Standard Member', 'initials': 'CR', 'color': const Color(0xFFE8F5E9)},
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info, color: Color(0xFF1D5CFF), size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Everyone pays an equal share',
                        style: TextStyle(color: Color(0xFF1D5CFF), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'SPLIT DETAILS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'USD',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Member list
                ...members.map((member) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        // Member avatar
                        CircleAvatar(
                          backgroundColor: member['color'],
                          child: Text(
                            member['initials'],
                            style: const TextStyle(color: Color(0xFF1D5CFF), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name and role
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(member['role'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        // Amount box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '\$400.00',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        // Sticky footer
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total summary row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total split amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('TOTAL SPLIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text('\$1,200.00', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
                          SizedBox(width: 6),
                          Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 20),
                        ],
                      ),
                    ],
                  ),
                  // Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('Balanced', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2ECC71))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Text('Confirm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  label: const Icon(Icons.check_circle, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D5CFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
