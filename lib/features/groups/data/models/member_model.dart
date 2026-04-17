import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/member_entity.dart';

class MemberModel {
  final String firestoreId;
  final String groupId;
  final String userId;
  final String name;
  final String role;
  final DateTime joinedAt;
  final String invitationStatus;
  final String? invitedBy;
  final bool isAppUser;

  const MemberModel({
    required this.firestoreId,
    required this.groupId,
    required this.userId,
    required this.name,
    required this.role,
    required this.joinedAt,
    required this.invitationStatus,
    this.invitedBy,
    this.isAppUser = false,
  });


  MemberModel copyWith({
    String? firestoreId,
    String? groupId,
    String? userId,
    String? name,
    String? role,
    DateTime? joinedAt,
    String? invitationStatus,
    String? invitedBy,
    bool? isAppUser,
  }) {
    return MemberModel(
      firestoreId: firestoreId ?? this.firestoreId,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      invitationStatus: invitationStatus ?? this.invitationStatus,
      invitedBy: invitedBy ?? this.invitedBy,
      isAppUser: isAppUser ?? this.isAppUser,
    );
  }

  // Entity → Model
  factory MemberModel.fromEntity(MemberEntity entity) {
    return MemberModel(
      firestoreId: entity.firestoreId,
      groupId: entity.groupId,
      userId: entity.userId,
      name: entity.name,
      role: entity.role,
      joinedAt: entity.joinedAt,
      invitationStatus: entity.invitationStatus,
      invitedBy: entity.invitedBy,
      isAppUser: entity.isAppUser,
    );
  }

  // Firestore → Model
  factory MemberModel.fromMap(
      Map<String, dynamic> map,
      String docId,
      ) {
    return MemberModel(
      firestoreId: docId,
      groupId: map['groupId'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'member',
      joinedAt: map['joinedAt'] is Timestamp
          ? (map['joinedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['joinedAt'] ?? '') ?? DateTime.now(),
      invitationStatus: map['invitationStatus'] ?? 'pending',
      invitedBy: map['invitedBy'],
      isAppUser: map['isAppUser'] ?? false,
    );
  }

  // Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'userId': userId,
      'name': name,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'invitationStatus': invitationStatus,
      'invitedBy': invitedBy,
      'isAppUser': isAppUser,
    };
  }

  // Model → Entity
  MemberEntity toEntity() {
    return MemberEntity(
      firestoreId: firestoreId,
      groupId: groupId,
      userId: userId,
      name: name,
      role: role,
      joinedAt: joinedAt,
      invitationStatus: invitationStatus,
      invitedBy: invitedBy,
      isAppUser: isAppUser,
    );
  }
}