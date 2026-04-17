import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/data/repository/expense_repository_impl.dart';
import '../../../expenses/domain/repository/expense_repository.dart';
import '../../../expenses/domain/usecases/calculate_setelment_usecase.dart';
import '../../../expenses/domain/usecases/create_expense_usecase.dart';
import '../../../expenses/domain/usecases/delete_expense_usecase.dart';
import '../../../expenses/domain/usecases/update_expense_usecase.dart';
import '../../../expenses/domain/usecases/watch_group_expenses_usecase.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    final firestore = FirebaseFirestore.instance;

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
    Get.lazyPut(() => WatchGroupExpensesUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => CalculateGroupSettlementUseCase(), fenix: true);
  }
}