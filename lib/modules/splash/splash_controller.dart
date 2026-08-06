import 'package:get/get.dart';
import 'package:taskpro/modules/onboarding/onboarding_screen.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_screen.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';

import '../login/login_screen.dart';

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

    final loggedIn = await _storage.isLoggedIn();
    final  String onboardingCompleted = await _storage.read(StorageKeys.taskpro_onboarding_completed) ?? "";
    if(onboardingCompleted.isEmpty){
      Get.offAll(()=>OnboardingScreen());
      return;
    }
    if (loggedIn) {
      Get.offAll(() => WorkerDashboardScreen());
    } else {
      Get.offAll(() => LoginScreen());
    }

  }
}