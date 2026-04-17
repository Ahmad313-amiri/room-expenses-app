import '../entities/group.dart';
import '../repositories/group_repository.dart';

// create_group.dart (UseCase)
import 'dart:io';

class CreateGroup {
  final GroupRepository repository;
  CreateGroup(this.repository);

  Future<String> call(GroupEntity group, {File? imageFile}) async {
    return await repository.createGroup(group, imageFile: imageFile);
  }
}
