class MemberEntity {
  final String? id; // برای Isar
  final String firestoreId;
  final String groupId;
  final String userId;
  final String role;
  final DateTime joinedAt;
  final String invitationStatus;
  final String? invitedBy;
  final bool isSynced;

  MemberEntity({
    this.id,
    required this.firestoreId,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.invitationStatus,
    this.invitedBy,
    this.isSynced = false,
  });
}