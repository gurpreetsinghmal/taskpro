
import 'package:taskpro/modules/worker/dashboard/w_dashboard_controller.dart';
import 'package:get/get.dart';
class WorkerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkerDashboardController>(
          () => WorkerDashboardController(),
    );
  }
}