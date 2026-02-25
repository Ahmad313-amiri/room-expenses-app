import 'package:isar/isar.dart';
import '../../domain/entities/member_entity.dart';

part 'members_model.g.dart';

@Collection()
class MemberModel {
  Id id = Isar.autoIncrement;
  late String firestoreId;
  late String groupId;
  late String userId;
  late String role;
  DateTime joinedAt = DateTime.now();
  String invitationStatus = 'pending';
  String? invitedBy;
  bool isSynced = false;

  // تبدیل مدل دیتابیس به انتیتی لایه دومین
  MemberEntity toEntity() {
    return MemberEntity(
      id: id.toString(),
      firestoreId: firestoreId,
      groupId: groupId,
      userId: userId,
      role: role,
      joinedAt: joinedAt,
      invitationStatus: invitationStatus,
      invitedBy: invitedBy,
      isSynced: isSynced,
    );
  }

  // ایجاد مدل از روی انتیتی
  static MemberModel fromEntity(MemberEntity entity) {
    return MemberModel()
      ..firestoreId = entity.firestoreId
      ..groupId = entity.groupId
      ..userId = entity.userId
      ..role = entity.role
      ..joinedAt = entity.joinedAt
      ..invitationStatus = entity.invitationStatus
      ..invitedBy = entity.invitedBy
      ..isSynced = entity.isSynced;
  }
}