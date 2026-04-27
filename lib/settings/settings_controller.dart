import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final GetStorage _box = GetStorage();
  final RxString primaryCurrency = 'USD (\$)'.obs;

  @override
  void onInit() {
    super.onInit();
    primaryCurrency.value = _box.read('primaryCurrency') ?? 'USD (\$)';
  }

  void setPrimaryCurrency(String currency) {
    primaryCurrency.value = currency;
    _box.write('primaryCurrency', currency);
  }
}