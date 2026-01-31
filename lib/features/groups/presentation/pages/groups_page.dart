import 'package:flutter/material.dart';
import 'package:roomly/features/groups/presentation/pages/create_group.dart';
import 'package:roomly/features/groups/presentation/pages/groups_details_page.dart';
import '../../data/data_sources/group_local_datasource.dart';
import '../../data/repository/group_repository_impl.dart';
import '../../domain/entities/group.dart';
import '../../domain/usecases/get_groups.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late final GetGroups getGroups;
  List<Group> groups = [];

  @override
  void initState() {
    super.initState();
    getGroups = GetGroups(GroupRepositoryImpl(GroupLocalDataSource()));
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final result = await getGroups();
    setState(() => groups = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Groups'),
        actions:  [
          IconButton(

          icon:Icon(Icons.add,size: 30,),
        onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>CreateGroupScreen()));
        },
          ),
          SizedBox(width: 20),
        ],
       backgroundColor: Colors.grey.shade200,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              elevation: WidgetStatePropertyAll(0),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              hintText: 'Search your groups',
              leading: const Icon(Icons.search),
              backgroundColor: const WidgetStatePropertyAll(Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return GroupCard(group: groups[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// 🟦 GROUP CARD
/// =======================================================
class GroupCard extends StatelessWidget {
  final Group group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    // Fake number of members (later from API)
    final int membersCount = 6;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE =================
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: Image.asset(
                  'assets/pexels.jpg',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Category on image
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Travel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ================= AVATARS + TITLE =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                MembersAvatars(count: membersCount),
              ],
            ),
          ),

          // ================= AMOUNT + ACTION =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${group.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: group.amount > 0 ? Colors.redAccent : Colors.green,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>GroupDetailScreen()));
                  },
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// 👥 MEMBERS AVATARS WITH +N
/// =======================================================
class MembersAvatars extends StatelessWidget {
  final int count;

  const MembersAvatars({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final visibleCount = count > 3 ? 3 : count;

    return SizedBox(
      width: 24.0 * (visibleCount + 1),
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * 20,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
          if (count > 3)
            Positioned(
              left: visibleCount * 20,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal,
                child: Text(
                  '+${count - 3}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
