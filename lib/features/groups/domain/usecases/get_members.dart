import '../entities/member_entity.dart';
import '../repositories/group_repository.dart';

class GetMembers {
  final GroupRepository repository;

  GetMembers(this.repository);

  /// این متد لیست اعضای یک گروه خاص را بر اساس [groupId] فراخوانی می‌کند
  Future<List<MemberEntity>> call(String groupId) async {
    return await repository.getMembers(groupId);
  }
}