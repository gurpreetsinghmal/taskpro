import 'package:taskpro/modules/app_routes/app_routes.dart';
import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';

class SplashController extends GetxController {
  final _storage = SecureStorageService.instance;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 3));

    // TODO:
    // Check Login Token
    // Check User Role
    // Load Master Data

    if (isClosed) return;
    final loggedIn = await _storage.isLoggedIn();
    final pref = await SharedPreferences.getInstance();
    final bool onboardingCompleted =
        pref.getBool(StorageKeys.onboardingCompleted) ?? false;
    if (isClosed) return;
    if (!onboardingCompleted) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    //Check Location service screen
    // Get.offAll(() => LocationScreen());
    // return;
    if (loggedIn) {
      Get.offAllNamed(AppRoutes.workerdashboard);
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        if (!isClosed) Get.offAllNamed(AppRoutes.login);
      });
    }
  }
}
