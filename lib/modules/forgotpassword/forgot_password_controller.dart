import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/modules/forgotpassword/forgot_password_model.dart';
import 'package:taskpro/modules/login/login_screen.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/theme/app_colors.dart';


class ForgotPasswordController extends GetxController {
  // Reactive State Variables
  final currentStep = ForgotPasswordModel.email.obs;
  final isLoading = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Text Controllers
  final emailController = TextEditingController();
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form Keys
  final emailFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  String reset_token="";
  final _apiService = ApiService();

  void clearOtpFields() {
    for (final controller in otpControllers) {
      controller.clear();
    }

    // Optional: move focus back to first OTP box
    otpFocusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> api_send_Email_OTP() async{
    _apiService.post(ApiRoutes.sendEmailOtp, data: {
      'email': emailController.text,
    }).then((value) async {
      isLoading.value = false;
      if (value.data['success']) {
        Get.snackbar(
          'Success',
          value.data['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        currentStep.value = ForgotPasswordModel.otp;
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

  Future<void> api_Verify_Email_OTP(otp) async{
    _apiService.post(ApiRoutes.verifyEmailOtp, data: {
      'email': emailController.text,
      "otp": otp
    }).then((value) async {
      isLoading.value = false;
      if (value.data['success']) {
        reset_token = value.data['data']['reset_token'].toString();
        Get.snackbar(
          'Success',
          value.data['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        currentStep.value = ForgotPasswordModel.newPassword;
      }
      else{
        clearOtpFields();
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
        'something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    });
  }

  Future<void> api_reset_Password() async{
    _apiService.post(ApiRoutes.resetPassword, data: {
      "reset_token": reset_token,
      "password": newPasswordController.text,
      "password_confirmation": confirmPasswordController.text
    }).then((value) async {
      isLoading.value = false;
      if (value.data['success']) {
        Get.snackbar(
          'Success',
          value.data['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        Get.offAll(() => const LoginScreen());
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

  // Step 1: Submit Email
  Future<void> submitEmail() async {
    if (emailFormKey.currentState!.validate()) {
      isLoading.value = true;
      await api_send_Email_OTP();// Simulate API call

    }
  }

  // Step 2: Submit OTP
  Future<void> submitOtp() async {
    String otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      Get.snackbar(
        'Validation Error',
        'Please enter the complete 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    isLoading.value = true;
    reset_token="";
    await api_Verify_Email_OTP(otp); // Simulate API call

  }

  // Step 3: Reset Password
  Future<void> resetPassword() async {
    if (passwordFormKey.currentState!.validate()) {
      isLoading.value = true;
      await api_reset_Password(); // Simulate API call

    }
  }

  // Handle Back Navigation
  bool handleBackPress() {
    if (currentStep.value == ForgotPasswordModel.otp) {
      currentStep.value = ForgotPasswordModel.email;
      return false;
    } else if (currentStep.value == ForgotPasswordModel.newPassword) {
      currentStep.value = ForgotPasswordModel.otp;
      return false;
    }
    return true; // Pop screen
  }
}