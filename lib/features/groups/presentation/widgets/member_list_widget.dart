import 'package:flutter/material.dart';
import '../../domain/entities/member_entity.dart';

class MembersListWidget extends StatelessWidget {
  final List<MemberEntity> members;
  final bool Function(MemberEntity member) canRemoveMember;
  final Function(MemberEntity member) onRemoveMember;
  final VoidCallback onAddMember;

  const MembersListWidget({
    super.key,
    required this.members,
    required this.canRemoveMember,
    required this.onRemoveMember,
    required this.onAddMember,
  });

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
                onPressed: onAddMember,
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        if (members.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No members yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
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
              if (canRemoveMember(member))
                GestureDetector(
                  onTap: () => onRemoveMember(member),
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