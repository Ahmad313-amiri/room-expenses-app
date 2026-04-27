import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final GetStorage _box = GetStorage();
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read('isDarkMode') ?? false;
    _applyTheme();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write('isDarkMode', isDarkMode.value);
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}