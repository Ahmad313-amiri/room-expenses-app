import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// Import Data Sources
import '../data/data_sources/group_local_datasource.dart';
import '../data/data_sources/group_remote_datasource.dart';
// Import Repository
import '../data/repository/group_repository_impl.dart';
import '../domain/repositories/group_repository.dart'; // اینترفیس ریپازیتوری
// Import Use Cases
import '../domain/usecases/add_member.dart';
import '../domain/usecases/archive_group.dart';
import '../domain/usecases/create_group.dart';
import '../domain/usecases/get_groups.dart';
import '../domain/usecases/get_members.dart'; // یوزکیس فراموش شده
// Import Controller
import '../presentation/controller/group_controller.dart';

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    // 1. External dependencies
    // نکته: اگر Isar قبلاً در main مقداردهی شده، از getInstance استفاده کنید
    final isar = Isar.getInstance()!;
    final firestore = FirebaseFirestore.instance;

    // 2. Data Sources
    final localDataSource = GroupLocalDataSource(isar);
    final remoteDataSource = GroupRemoteDataSource(firestore);

    // 3. Repository
    // بهتر است ریپازیتوری را با اینترفیس آن تزریق کنید
    final GroupRepository repository = GroupRepositoryImpl(
      local: localDataSource,
      remote: remoteDataSource,
    );

    // 4. Use Cases
    final getGroupsUseCase = GetGroups(repository);
    final createGroupUseCase = CreateGroup(repository);
    final addMemberUseCase = AddMember(repository);
    final archiveGroupUseCase = ArchiveGroup(repository);
    final getMembersUseCase = GetMembers(repository); // اضافه شد

    // 5. Controller
    // تزریق همه وابستگی‌ها به کنترلر
    Get.lazyPut(() => GroupsController(
      getGroupsUseCase: getGroupsUseCase,
      createGroupUseCase: createGroupUseCase,
      addMemberUseCase: addMemberUseCase,
      archiveGroupUseCase: archiveGroupUseCase,
      getMembersUseCase: getMembersUseCase,
    ));
  }

}