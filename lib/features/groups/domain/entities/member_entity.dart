class MemberEntity {
  final String firestoreId;
  final String groupId;
  final String userId;
  final String name;
  final String role;
  final DateTime joinedAt;
  final String invitationStatus;
  final String? invitedBy;
  // final bool isAppUser;
  final String? photoUrl;

  MemberEntity({
    required this.firestoreId,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.invitationStatus,
    this.invitedBy,
    required this.name,
    // this.isAppUser = false,
    this.photoUrl
  });
}