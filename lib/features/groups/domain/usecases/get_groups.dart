import '../entities/group.dart';
import '../repositories/group_repository.dart';

class GetGroups {
  final GroupRepository repository;

  GetGroups(this.repository);

  Future<List<Group>> call() {
    return repository.getGroups();
  }
}
