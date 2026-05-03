import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:roomly/core/util/net_work.dart';
import 'package:roomly/core/util/app_logger.dart';

import '../../../../settings/settings_controller.dart';
import '../../../../settings/theme_controller.dart';

import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/data/repository/expense_repository_impl.dart';
import '../../../expenses/domain/repository/expense_repository.dart';
import '../../../expenses/domain/usecases/calculate_setelment_usecase.dart';
import '../../../expenses/domain/usecases/create_expense_usecase.dart';
import '../../../expenses/domain/usecases/delete_expense_usecase.dart';
import '../../../expenses/domain/usecases/update_expense_usecase.dart';
import '../../../expenses/domain/usecases/watch_group_expenses_usecase.dart';

import '../../../groups/data/data_sources/group_remote_datasource.dart';
import '../../../groups/data/repository/group_repository_impl.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../../groups/domain/usecases/add_member.dart';
import '../../../groups/domain/usecases/create_group.dart';
import '../../../groups/domain/usecases/delete_group.dart';
import '../../../groups/domain/usecases/get_groups.dart';
import '../../../groups/domain/usecases/get_members.dart';
import '../../../groups/domain/usecases/get_members_paginated.dart';
import '../../../groups/domain/usecases/search_users_usecase.dart';
import '../../../groups/domain/usecases/update_member_status.dart';
import '../../../groups/presentation/controller/group_controller.dart';

import '../../data/repository/authentication_repository.dart';
import '../../presentations/widgets/login_controller.dart';
import '../../presentations/widgets/sign_up_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    AppLogger.i('🚀 AppBinding initialization started');

    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // ================= CORE =================
    Get.put(NetworkService(), permanent: true);
    AppLogger.i('✅ NetworkService initialized');

    // ================= AUTH (FIXED) =================
    // ❗ مهم: lazyPut به جای put
    Get.lazyPut(() => AuthenticationRepository(), fenix: true);
    AppLogger.i('✅ AuthenticationRepository initialized');

    Get.lazyPut(() => SignInController(), fenix: true);
    Get.lazyPut(() => SignUpController(), fenix: true);
    AppLogger.i('✅ Auth Controllers initialized');

    // ================= GROUPS =================
    final groupRemote = GroupRemoteDataSource(
      firestore: firestore,
      storage: storage,
    );

    Get.put<GroupRemoteDataSource>(groupRemote, permanent: true);

    Get.put<GroupRepository>(
      GroupRepositoryImpl(remote: groupRemote),
      permanent: true,
    );

    Get.put(GetGroups(Get.find()), permanent: true);
    Get.put(CreateGroup(Get.find()), permanent: true);
    Get.put(AddMember(Get.find()), permanent: true);
    Get.put(DeleteGroup(Get.find()), permanent: true);
    Get.put(GetMembers(Get.find()), permanent: true);
    Get.put(SearchUsersUseCase(groupRemote), permanent: true);
    Get.put(UpdateMemberStatus(Get.find()), permanent: true);
    Get.put(GetMembersPaginated(Get.find()), permanent: true);

    Get.put(
      GroupsController(
        searchUsersUseCase: Get.find(),
        getGroupsUseCase: Get.find(),
        createGroupUseCase: Get.find(),
        addMemberUseCase: Get.find(),
        deleteGroupUseCase: Get.find(),
        getMembersUseCase: Get.find(),
        remoteDataSource: groupRemote,
        updateMemberStatusUseCase: Get.find(),
        getMembersPaginatedUseCase: Get.find(),
      ),
      permanent: true,
    );

    // ================= EXPENSE =================
    Get.lazyPut<ExpenseRemoteDataSource>(
          () => ExpenseRemoteDataSource(firestore: firestore),
      fenix: true,
    );

    Get.lazyPut<ExpenseRepository>(
          () => ExpenseRepositoryImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut(() => AddExpenseUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => UpdateExpenseUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => DeleteExpenseUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => WatchGroupExpensesUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CalculateGroupSettlementUseCase(), fenix: true);

    // ================= SETTINGS =================
    Get.put(SettingsController(), permanent: true);
    Get.put(ThemeController(), permanent: true);

    AppLogger.i('🎯 AppBinding initialization completed');
  }
}