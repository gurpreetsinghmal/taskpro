
import 'package:get/get.dart';
import 'package:taskpro/modules/worker/profile/profile_controller.dart';

class WorkerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(WorkerProfileController());
  }
}