import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import '../app_routes/app_routes.dart';

class SessionController extends GetxController {
  bool _loggingOut = false;
  Future<void> logout({bool confirm = true}) async {
    if (_loggingOut) return;
    _loggingOut = true;

    try {
      if (confirm) {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Log Out?'),
            content: const Text(
              'Logging out clears locally saved app data. Any work sessions, '
              'task updates, photos, or documents that have not synced will '
              'be lost. Sync your pending work before logging out.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Log Out'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        if (confirmed != true) return;
      }

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
