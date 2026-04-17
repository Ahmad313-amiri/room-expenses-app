import '../../data/data_sources/group_remote_datasource.dart';

class SearchUsersUseCase {
  final GroupRemoteDataSource remoteDataSource;

  SearchUsersUseCase(this.remoteDataSource);

  Future<List<Map<String, dynamic>>> call(String query) async {
    return await remoteDataSource.searchUsers(query);
  }
}