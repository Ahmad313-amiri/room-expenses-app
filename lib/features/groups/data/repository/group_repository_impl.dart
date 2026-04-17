import 'dart:io';
import '../../domain/entities/group.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../data_sources/group_remote_datasource.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remote;

  GroupRepositoryImpl({required this.remote});

  @override
  Future<List<GroupEntity>> getGroups({String? userId}) async {
    if (userId == null) return [];
    try {
      final models = await remote.getGroups(userId);
      return models;
    } catch (e) {
      print("Error in getGroups: $e");
      return [];
    }
  }

  @override
  Future<GroupEntity?> getGroupById(String id) async {
    try {
      final doc = await remote.firestore.collection('groups').doc(id).get();
      if (!doc.exists) return null;
      return GroupModel.fromMap(doc.data()!);
    } catch (e) {
      print("Error in getGroupById: $e");
      return null;
    }
  }

  @override
  Future<String> createGroup(GroupEntity group, {File? imageFile}) async {
  var model = GroupModel.fromEntity(group);
    String? imageUrl;
  if (imageFile != null) {
    final imageUrl = await remote.uploadGroupImage(
      imageFile,
      "${group.createdBy}_${DateTime.now().millisecondsSinceEpoch}",
    );

    model = model.copyWith(coverImageUrl: imageUrl);
  }
    final remoteId = await remote.addGroup(model);

    // add creator as admin member
    final adminMember = MemberModel(
      groupId: remoteId,
      userId: group.createdBy,
      name: 'You',
      role: 'admin',
      joinedAt: DateTime.now(),
      invitationStatus: 'accepted',
      isAppUser: true,
      firestoreId: '',
    );
    await remote.addMemberToFirestore(remoteId, adminMember);

    return remoteId;
  }

  @override
  Future<void> updateGroup(GroupEntity group) async {
    final model = GroupModel.fromEntity(group);
    await remote.updateGroup(model);
  }

  @override
  Future<void> archiveGroup(String groupId) async {
    await remote.archiveGroup(groupId);
  }

  @override
  Future<void> addMember(String groupId, MemberEntity member) async {
    final model = MemberModel.fromEntity(member);
    await remote.addMemberToFirestore(groupId, model);
  }

  @override
  Future<List<MemberEntity>> getMembers(String groupId) async {
    final models = await remote.getMembers(groupId);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> removeMember(String groupId, String userId) async {
    await remote.removeMember(groupId, userId);
  }

  @override
  Future<void> updateMemberStatus(String groupId, String userId, String status) async {
    await remote.updateMemberStatus(groupId, userId, status);
  }
}