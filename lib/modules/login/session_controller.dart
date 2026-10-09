import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../app_routes/app_routes.dart';

class SessionController extends GetxController {
  bool _loggingOut = false;
  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      await SessionService().clearSession();
      Get.snackbar(
        'Logged Out',
        'Successfully logged out.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.login);
    } finally {
      _loggingOut = false;
    }
  }
}
