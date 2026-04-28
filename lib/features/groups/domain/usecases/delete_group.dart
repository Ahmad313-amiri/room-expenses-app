import '../repositories/group_repository.dart';

class DeleteGroup {
  final GroupRepository repository;

  DeleteGroup(this.repository);

  Future<void> call(String groupId) async {
    return repository.deleteGroup(groupId);
  }
}
