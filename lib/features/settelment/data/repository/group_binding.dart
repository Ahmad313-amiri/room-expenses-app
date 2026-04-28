import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../groups/data/data_sources/group_remote_datasource.dart';
import '../../../groups/data/repository/group_repository_impl.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../../groups/domain/usecases/add_member.dart';
import '../../../groups/domain/usecases/create_group.dart';
import '../../../groups/domain/usecases/delete_group.dart';
import '../../../groups/domain/usecases/get_groups.dart';
import '../../../groups/domain/usecases/get_members.dart';
import '../../../groups/domain/usecases/search_users_usecase.dart';
import '../../../groups/domain/usecases/update_member_status.dart';
import '../../../groups/presentation/controller/group_controller.dart';

/// Dependency Injection binding for Groups feature
/// Registers all repositories, use cases, and controllers
class GroupBinding extends Bindings {
  @override
  void dependencies() {
    // ========== Get Firestore and Isar instances ==========
       final firestore = FirebaseFirestore.instance;
       final storage = FirebaseStorage.instance;
    // ========== Register Data Sources ==========
    final remoteDS = GroupRemoteDataSource( firestore: firestore,storage:storage );

    // Register for dependency injection
    Get.put<GroupRemoteDataSource>(remoteDS, permanent: true);

    // ========== Register Repository ==========
    final GroupRepository repo = GroupRepositoryImpl(
      remote: remoteDS,
    );
    Get.put<GroupRepository>(repo, permanent: true);

    // ========== Register Use Cases ==========
    Get.put(GetGroups(repo), permanent: true);
    Get.put(CreateGroup(repo), permanent: true);
    Get.put(AddMember(repo), permanent: true);
    Get.put(DeleteGroup(repo), permanent: true);
    Get.put(GetMembers(repo), permanent: true);
    Get.put(SearchUsersUseCase(remoteDS), permanent: true);
    Get.put(UpdateMemberStatus(repo), permanent: true);


    // ========== Register Controller ==========
    Get.put<GroupsController>(
      GroupsController(
        searchUsersUseCase: Get.find<SearchUsersUseCase>(),
        getGroupsUseCase: Get.find<GetGroups>(),
        createGroupUseCase: Get.find<CreateGroup>(),
        addMemberUseCase: Get.find<AddMember>(),
        deleteGroupUseCase: Get.find<DeleteGroup>(),
        getMembersUseCase: Get.find<GetMembers>(),
        remoteDataSource: remoteDS,
           updateMemberStatusUseCase: Get.find<UpdateMemberStatus>(),
      ),
      permanent: true,
    );
  }
}