import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_controller.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_screen.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter username number',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter your password',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    // Simulate network authentication API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    Get.snackbar(
      'Success',
      'Logged in successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    final storage = SecureStorageService.instance;
    await storage.write(StorageKeys.accessToken, 'your_access_token');
    var data={"name":usernameController.text,"role":"worker","email":"test@gmail.com"};
    await storage.write(StorageKeys.empname, jsonEncode(data));
    Get.offAll(() => MainLayoutScreen());
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}