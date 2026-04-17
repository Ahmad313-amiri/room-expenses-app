import '../repositories/group_repository.dart';

class UpdateMemberStatus {
  final GroupRepository repository;

  UpdateMemberStatus(this.repository);

  Future<void> call(String groupId, String userId, String status) async {
    return await repository.updateMemberStatus(groupId, userId, status);
  }
}