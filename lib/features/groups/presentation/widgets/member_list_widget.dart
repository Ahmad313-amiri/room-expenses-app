import 'package:flutter/material.dart';
import '../../domain/entities/member_entity.dart';

class MembersListWidget extends StatefulWidget {
  final List<MemberEntity> members;
  final bool Function(MemberEntity member) canRemoveMember;
  final Function(MemberEntity member) onRemoveMember;
  final VoidCallback onAddMember;
  final bool hasMore;         // Whether more members can be loaded
  final Future<void> Function() onLoadMore; // Callback to load next page

  const MembersListWidget({
    super.key,
    required this.members,
    required this.canRemoveMember,
    required this.onRemoveMember,
    required this.onAddMember,
    this.hasMore = false,
    required this.onLoadMore,
  });

  @override
  State<MembersListWidget> createState() => _MembersListWidgetState();
}

class _MembersListWidgetState extends State<MembersListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Trigger load more when scrolled near the bottom (100px threshold)
  void _onScroll() {
    if (_isLoadingMore) return;
    if (!widget.hasMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 100) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await widget.onLoadMore();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Group Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: widget.onAddMember,
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        if (widget.members.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No members yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.members.length + (widget.hasMore ? 1 : 0), // +1 for loading indicator
            itemBuilder: (context, index) {
              if (index == widget.members.length) {
                // Show loading indicator at the bottom if more data exists
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final member = widget.members[index];
              return _buildMemberCard(member, index);
            },
          ),
      ],
    );
  }

  Widget _buildMemberCard(MemberEntity member, int index) {
    Color _getMemberAvatarColor(int idx) {
      final colors = [
        Colors.blue, Colors.purple, Colors.green, Colors.orange, Colors.red, Colors.teal,
      ];
      return colors[idx % colors.length];
    }

    Widget _buildStatusBadge(String status) {
      Color statusColor;
      String displayStatus;

      switch (status.toLowerCase()) {
        case 'accepted':
          statusColor = Colors.green;
          displayStatus = 'Active';
          break;
        case 'pending':
          statusColor = Colors.orange;
          displayStatus = 'Pending';
          break;
        case 'declined':
          statusColor = Colors.red;
          displayStatus = 'Declined';
          break;
        default:
          statusColor = Colors.grey;
          displayStatus = status;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          displayStatus,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getMemberAvatarColor(index),
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  member.role,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusBadge(member.invitationStatus),
              const SizedBox(height: 4),
              if (widget.canRemoveMember(member))
                GestureDetector(
                  onTap: () => widget.onRemoveMember(member),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('Remove',
                      style: TextStyle(
                        color: Colors.red, fontSize: 11, decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}