import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:dio/dio.dart' as dio;
import 'package:taskpro/modules/worker/dashboard/w_dashboard_screen.dart';
import 'package:taskpro/network/api_exception.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'package:taskpro/theme/app_colors.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email.trim());
  }

  void login() async {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter user email',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (!isValidEmail(usernameController.text.trim())) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
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
    if (passwordController.text.trim().length < 8) {
      Get.snackbar(
        'Required',
        'The password must be at least 8 characters.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;
  //   Get.snackbar(
  //     'Success',
  //     'Logged in successfully!',
  //     snackPosition: SnackPosition.BOTTOM,
  //     backgroundColor: AppColors.success,
  //     colorText: Colors.white,
  //     margin: const EdgeInsets.all(16),
  //   );
  //
  //   final storage = SecureStorageService.instance;
  //   await storage.write(StorageKeys.accessToken, "token");
  //   var data = {
  //     "name":"Super Admin",
  //     "role": "Admin",
  //     "email":  "admin@admin.com",
  //   };
  //   await storage.write(StorageKeys.empname, jsonEncode(data));
  //   Get.offAll(() => WorkerDashboardScreen());
  // return;
      var formData = dio.FormData.fromMap({
        'email': usernameController.text,
        'password': passwordController.text,
      });

      final _apiService = ApiService();
      await _apiService.post(ApiRoutes.loginEndpoint, data: formData).then((value) async {
        isLoading.value = false;

        if (value.data['success']) {
          Get.snackbar(
            'Success',
            'Logged in successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );

          final storage = SecureStorageService.instance;
          await storage.write(StorageKeys.accessToken, value.data['token']);
          var data = {
            "name": value.data['user']['name'],
            "role": value.data['user']['roles'][0],
            "email":  value.data['user']['email'],
          };
          await storage.write(StorageKeys.empname, jsonEncode(data));
          Get.offAll(() => WorkerDashboardScreen());
        } else {
          Get.snackbar(
            'Failed',
            value.data['message'],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        }

      }).catchError((error) {
        isLoading.value = false;
        Get.snackbar(
          'Failed',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      });

  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
