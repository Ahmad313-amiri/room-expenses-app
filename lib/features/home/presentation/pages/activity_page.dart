import 'package:flutter/material.dart';
import '../../../groups/presentation/pages/settlement_verification_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  // All activities tab content
  Widget _buildAllActivityList() {
    // نمایش لودینگ در صورتی که isLoading true باشد
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF2ECC71),
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const Text(
            'Today',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildSettlementRequestCard(
            context: context,
            title: 'Settlement Request: \$45.00',
            subtitle: 'James wants to settle for \'Beach Trip\'',
            image:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
            isActive: true,
          ),

          _buildActivityTile(
            name: 'Sarah',
            action: 'added \'Grocery...\'',
            details: 'Total: \$124.50 • Your share: \$12.50',
            time: '2h ago',
            avatar: 'https://i.pravatar.cc/150?u=sarah',
            hasUnreadDot: true,
          ),

          const SizedBox(height: 24),

          const Text(
            'Yesterday',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildVerifiedTile(
            title: 'Settlement Verified',
            desc: 'You confirmed Mike\'s \$20.00 payment',
          ),

          _buildActivityTile(
            name: 'Mark',
            action: 'added \'Fuel for...\'',
            details: 'Your share: \$18.75',
            time: 'Yesterday',
            avatar: 'https://i.pravatar.cc/150?u=mark',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
          title: const Text(
            'Activity',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2ECC71),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2ECC71),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Expenses'),
              Tab(text: 'Settlements'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllActivityList(),
            const Center(child: Text('Expenses List')),
            const Center(child: Text('Settlements List')),
          ],
        ),
      ),
    );
  }
}

// همان متدهای کمکی UI شما بدون تغییر
Widget _buildSettlementRequestCard({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String image,
  required bool isActive,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isActive)
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isActive)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFF2ECC71),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              isActive
                  ? ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>SettlementVerificationScreen()));
                },
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Verify Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              )
                  : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(image, width: 80, height: 80, fit: BoxFit.cover),
        ),
      ],
    ),
  );
}

Widget _buildActivityTile({
  required String name,
  required String action,
  required String details,
  required String time,
  required String avatar,
  bool hasUnreadDot = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(avatar), radius: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: '$name ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: action),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                details,
                style: const TextStyle(
                  color: Color(0xFF2ECC71),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            if (hasUnreadDot)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFF2ECC71),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildVerifiedTile({required String title, required String desc}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFE8F8EF),
          child: Icon(Icons.handshake, color: Color(0xFF2ECC71), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const Text(
          'Yesterday',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    ),
  );
}