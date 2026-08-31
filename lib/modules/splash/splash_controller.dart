import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpro/location/location_screen.dart';
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
    final pref=await SharedPreferences.getInstance();
    final  bool onboardingCompleted = await pref.getBool(StorageKeys.onboardingCompleted)??false;
    if(!onboardingCompleted){
      Get.offAll(()=>OnboardingScreen());
      return;
    }
    //Check Location service screen
    // Get.offAll(() => LocationScreen());
    // return;
    if (loggedIn) {
      Get.offAll(() => WorkerDashboardScreen());
    } else {
      Get.offAll(() => LoginScreen());
    }

  }
}