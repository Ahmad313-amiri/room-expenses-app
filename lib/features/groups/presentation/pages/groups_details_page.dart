import 'package:flutter/material.dart';
import 'package:roomly/features/groups/presentation/pages/add_expense.dart';

import 'advance_settle_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.grey.shade200,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        // Back navigation button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),

        // Group title
        title: const Text(
          'Ski Trip 2024',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        // Settings action
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ===== Group image section =====
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=400',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Group icon overlay
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== Financial summary section =====
            const Text(
              'GROUP BALANCE',
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are owed \$150.00',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Text(
              'Created 2 weeks ago • 6 members',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 24),

            // ===== Primary action buttons =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>AdvancedSettleUpScreen()));
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Settle Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Share button
      // ===== button for adding expenses =====
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>AddExpenseScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10,),
                          Icon(Icons.add),

                          Expanded(
                            child: const Text(
                              'Add Expense ',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== Group members section =====
            _buildSectionHeader('Group Members', 'Manage'),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                return _buildMemberTile(members[index]);
              },
            ),

            const SizedBox(height: 24),

            // ===== Recent activity section =====
            _buildSectionHeader('Recent Activity', 'See All'),
            _buildActivityCard(),

            const SizedBox(height: 100), // Extra space for FAB
          ],
        ),
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ===== Section header widget =====
  Widget _buildSectionHeader(String title, String actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            actionText,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Single group member tile =====
  Widget _buildMemberTile(Member member) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(member.avatar)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  member.lastActivity,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // Member balance status
          Text(
            member.status,
            style: TextStyle(
              color: member.status.contains('Owes you')
                  ? Colors.green
                  : (member.status.contains('You owe')
                  ? Colors.red
                  : Colors.grey),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Recent activity card =====
  Widget _buildActivityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dinner at Alpine Lodge',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Paid by You • \$124.50',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== Data model for group members =====
class Member {
  final String name;
  final String avatar;
  final String lastActivity;
  final String status;

  Member({
    required this.name,
    required this.avatar,
    required this.lastActivity,
    required this.status,
  });
}

// ===== Sample mock data =====
final List<Member> members = [
  Member(
    name: 'Sarah Jenkins',
    avatar: 'https://i.pravatar.cc/150?u=1',
    lastActivity: 'Last activity 2 days ago',
    status: 'Owes you \$85.00',
  ),
  Member(
    name: 'Mark Thompson',
    avatar: 'https://i.pravatar.cc/150?u=2',
    lastActivity: 'Last activity 1 hour ago',
    status: 'You owe \$15.00',
  ),
  Member(
    name: 'Jessica Wu',
    avatar: 'https://i.pravatar.cc/150?u=3',
    lastActivity: 'Joined yesterday',
    status: 'Owes you \$80.00',
  ),
  Member(
    name: 'David Miller',
    avatar: 'https://i.pravatar.cc/150?u=4',
    lastActivity: 'Settled 3 days ago',
    status: 'Settled',
  ),
];
