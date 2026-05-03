import '../entities/group.dart';
import '../repositories/group_repository.dart';

class CreateGroup {
  final GroupRepository repository;
  CreateGroup(this.repository);

  Future<String> call(GroupEntity group) async {
    return await repository.createGroup(group);
  }
}
