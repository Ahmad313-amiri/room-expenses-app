// import 'package:get/get.dart';
// import 'package:isar/isar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../data/data_sources/group_local_datasource.dart';
// import '../data/data_sources/group_remote_datasource.dart';
// import '../data/repository/group_repository_impl.dart';
// import '../domain/repositories/group_repository.dart';
// import '../domain/usecases/add_member.dart';
// import '../domain/usecases/archive_group.dart';
// import '../domain/usecases/create_group.dart';
// import '../domain/usecases/get_groups.dart';
// import '../domain/usecases/get_members.dart';
// import '../presentation/controller/group_controller.dart';
//
// class GroupBinding extends Bindings {
//   @override
//   void dependencies() {
//     final isar = Get.find<Isar>();
//     final firestore = FirebaseFirestore.instance;
//
//     final localDS = GroupLocalDataSource(isar);
//     final remoteDS = GroupRemoteDataSource(firestore);
//
//     final GroupRepository repo =
//     GroupRepositoryImpl(local: localDS, remote: remoteDS);
//
//     final getGroups = GetGroups(repo);
//     final createGroup = CreateGroup(repo);
//     final addMember = AddMember(repo);
//     final archiveGroup = ArchiveGroup(repo);
//     final getMembers = GetMembers(repo);
//
//     Get.lazyPut<GroupsController>(
//           () => GroupsController(
//         getGroupsUseCase: getGroups,
//         createGroupUseCase: createGroup,
//         addMemberUseCase: addMember,
//         archiveGroupUseCase: archiveGroup,
//         getMembersUseCase: getMembers,
//       ),
//       fenix: true,
//     );
//
//     print("GroupBinding executed");
//   }
// }


import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/data_sources/group_local_datasource.dart';
import '../data/data_sources/group_remote_datasource.dart';
import '../data/repository/group_repository_impl.dart';
import '../domain/repositories/group_repository.dart';
import '../domain/usecases/add_member.dart';
import '../domain/usecases/archive_group.dart';
import '../domain/usecases/create_group.dart';
import '../domain/usecases/get_groups.dart';
import '../domain/usecases/get_members.dart';
import '../presentation/controller/group_controller.dart';

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    final isar = Get.find<Isar>();
    final firestore = FirebaseFirestore.instance;

    final localDS = GroupLocalDataSource(isar);
    final remoteDS = GroupRemoteDataSource(firestore);

    final GroupRepository repo = GroupRepositoryImpl(local: localDS, remote: remoteDS);

    // تزریق مستقیم یوزکیس‌ها برای جلوگیری از خطای Not Found
    Get.put(GetGroups(repo), permanent: true);
    Get.put(CreateGroup(repo), permanent: true);
    Get.put(AddMember(repo), permanent: true);
    Get.put(ArchiveGroup(repo), permanent: true);
    Get.put(GetMembers(repo), permanent: true);

    Get.put<GroupsController>(
      GroupsController(
        getGroupsUseCase: Get.find<GetGroups>(),
        createGroupUseCase: Get.find<CreateGroup>(),
        addMemberUseCase: Get.find<AddMember>(),
        archiveGroupUseCase: Get.find<ArchiveGroup>(),
        getMembersUseCase: Get.find<GetMembers>(),
      ),
      permanent: true,
    );
  }
}