import '../entities/group.dart';
import '../repositories/group_repository.dart';

class GetGroups {
  final GroupRepository repository;

  GetGroups(this.repository);

  Future<List<GroupEntity>> call() async {
    return repository.getGroups();
  }
}
