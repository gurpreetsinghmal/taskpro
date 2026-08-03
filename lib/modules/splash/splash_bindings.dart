import 'package:get/get.dart';
import 'package:taskpro/modules/splash/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}