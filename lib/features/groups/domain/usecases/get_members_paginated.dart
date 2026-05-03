import 'package:cloud_firestore/cloud_firestore.dart';
import '../entities/member_entity.dart';
import '../repositories/group_repository.dart';

class GetMembersPaginated {
  final GroupRepository repository;

  GetMembersPaginated(this.repository);

  Future<(List<MemberEntity>, DocumentSnapshot?, bool)> call(
      String groupId, {
        required int limit,
        DocumentSnapshot? startAfter,
      }) {
    return repository.getMembersPaginated(
      groupId,
      limit: limit,
      startAfter: startAfter,
    );
  }
}