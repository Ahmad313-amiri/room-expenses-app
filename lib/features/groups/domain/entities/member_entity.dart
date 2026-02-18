class GroupMemberEntity {
  final String userId;
  final String role;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final String invitationStatus;
  final String? invitedBy;

  GroupMemberEntity({
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.leftAt,
    required this.invitationStatus,
    this.invitedBy,
  });
}
