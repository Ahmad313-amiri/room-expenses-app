import 'package:get/get.dart';

import '../../data/repository/authentication_repository.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthenticationRepository(), permanent: true);
  }
}
