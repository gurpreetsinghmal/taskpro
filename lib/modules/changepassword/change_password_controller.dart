import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_screen.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/theme/app_colors.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isOldPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  // Password Policy Reactive Tracking
  final ohasMinLength = false.obs;
  final ohasUppercase = false.obs;
  final ohasLowercase = false.obs;
  final ohasNumber = false.obs;
  final ohasSpecialChar = false.obs;

  final hasMinLength = false.obs;
  final hasUppercase = false.obs;
  final hasLowercase = false.obs;
  final hasNumber = false.obs;
  final hasSpecialChar = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to new password changes for real-time policy checks
    oldPasswordController.addListener(_validateOldPasswordPolicy);
    newPasswordController.addListener(_validateNewPasswordPolicy);
  }

  void _validateOldPasswordPolicy() {
    final text = oldPasswordController.text;
    ohasMinLength.value = text.length >= 8;
    ohasUppercase.value = text.contains(RegExp(r'[A-Z]'));
    ohasLowercase.value = text.contains(RegExp(r'[a-z]'));
    ohasNumber.value = text.contains(RegExp(r'[0-9]'));
    ohasSpecialChar.value = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }
  void _validateNewPasswordPolicy() {
    final text = newPasswordController.text;
    hasMinLength.value = text.length >= 8;
    hasUppercase.value = text.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = text.contains(RegExp(r'[a-z]'));
    hasNumber.value = text.contains(RegExp(r'[0-9]'));
    hasSpecialChar.value = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool get isOldPasswordPolicyValid =>
      ohasMinLength.value &&
          ohasUppercase.value &&
          ohasLowercase.value &&
          ohasNumber.value &&
          ohasSpecialChar.value;

  bool get isPasswordPolicyValid =>
      hasMinLength.value &&
          hasUppercase.value &&
          hasLowercase.value &&
          hasNumber.value &&
          hasSpecialChar.value;

  void toggleOldPasswordVisibility() => isOldPasswordVisible.toggle();
  void toggleNewPasswordVisibility() => isNewPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      await api_ChangePassword();
    } catch (error) {
      _clearForm();
      Get.snackbar(
        'Failed',
        'Failed to change password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> api_ChangePassword() async{
    final _apiService = ApiService();

    final Map<String, dynamic> payload = {
      "password": oldPasswordController.text,
      "new_password": newPasswordController.text,
      "confirm_password": confirmPasswordController.text,
    };

    _apiService.post(ApiRoutes.changePassword, data: payload).then((value) async {
      isLoading.value = false;
      if (value.data['success']) {
        Get.snackbar(
          'Success',
          value.data['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: AppColors.textWhite,
          margin: const EdgeInsets.all(16),
        );


        Get.offAll(()=>WorkerDashboardScreen());
      }
      else{
        Get.snackbar(
          'Failed',
          value.data['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
      _clearForm();
    }).catchError((error) {
      isLoading.value = false;
      Get.snackbar(
        'Failed',
        'something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  void _clearForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    oldPasswordController.removeListener(_validateOldPasswordPolicy);
    newPasswordController.removeListener(_validateNewPasswordPolicy);
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}