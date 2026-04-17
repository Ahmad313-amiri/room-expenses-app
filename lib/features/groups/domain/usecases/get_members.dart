import '../entities/member_entity.dart';
import '../repositories/group_repository.dart';

class GetMembers {
  final GroupRepository repository;
  GetMembers(this.repository);
  Future<List<MemberEntity>> call(String groupId) async {
    return await repository.getMembers(groupId);
  }
}