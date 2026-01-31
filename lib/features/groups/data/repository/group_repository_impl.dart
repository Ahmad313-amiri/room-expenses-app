import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../data_sources/group_local_datasource.dart';


class GroupRepositoryImpl implements GroupRepository {
  final GroupLocalDataSource local;

  GroupRepositoryImpl(this.local);

  @override
  Future<List<Group>> getGroups() async {
    return local.getGroups();
  }
}
