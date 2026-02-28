import '../repositories/group_repository.dart';

class ArchiveGroup {
  final GroupRepository repository;

  ArchiveGroup(this.repository);

  Future<void> call(String groupId) async {
    return repository.archiveGroup(groupId);
  }
}
