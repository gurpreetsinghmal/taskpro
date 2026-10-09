import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/widgets/loading_dialog.dart';

class LoadingService {
  static void show([String? message]) {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      AppLoadingDialog(message: message),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
    );
  }

  static void hide() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
