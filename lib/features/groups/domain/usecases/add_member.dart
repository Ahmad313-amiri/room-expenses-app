import '../entities/member_entity.dart';
import '../repositories/group_repository.dart';

class AddMember {
  final GroupRepository repository;

  AddMember(this.repository);

  Future<void> call(String groupId, MemberEntity member) async {
    return repository.addMember(groupId, member);
  }
}
