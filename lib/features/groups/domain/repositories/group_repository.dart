import '../entities/group.dart';

abstract class GroupRepository {
  Future<List<Group>> getGroups();
}
