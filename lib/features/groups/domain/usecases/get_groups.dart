import '../entities/group.dart';
import '../repositories/group_repository.dart';

class GetGroups {
  final GroupRepository repository;

  GetGroups(this.repository);

  Future<List<GroupEntity>> call(String userId) async {
    return repository.getGroups(userId: userId);
  }
}
