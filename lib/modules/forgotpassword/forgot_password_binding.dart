
import 'package:get/get.dart';
import 'package:taskpro/modules/forgotpassword/forgot_password_controller.dart';
class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ForgotPasswordController());
  }
}