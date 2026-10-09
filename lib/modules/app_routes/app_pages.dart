import 'package:get/get.dart';
import '../../common/models/work_order_model.dart';
import '../worker/tasks/w_tasks_screen.dart';
import '../worker/tasks/w_tasks_controller.dart';
import '../worker/checkin/checkin_screen.dart';
import '../worker/checkin/checkin_controller.dart';
import '../worker/photoupload/task_completion_screen.dart';
import '../worker/photoupload/task_completion_controller.dart';
import '../changepassword/change_password_screen.dart';
import '../changepassword/change_password_controller.dart';
import 'package:taskpro/modules/app_routes/app_routes.dart';
import 'package:taskpro/modules/forgotpassword/forgot_password_binding.dart';
import 'package:taskpro/modules/forgotpassword/forgot_password_screen.dart';
import 'package:taskpro/modules/login/login_binding.dart';
import 'package:taskpro/modules/login/login_screen.dart';
import 'package:taskpro/modules/onboarding/onboarding_binding.dart';
import 'package:taskpro/modules/onboarding/onboarding_screen.dart';
import 'package:taskpro/modules/splash/splash_bindings.dart';
import 'package:taskpro/modules/splash/splash_screen.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_binding.dart';
import 'package:taskpro/modules/worker/dashboard/w_dashboard_screen.dart';
import 'package:taskpro/modules/worker/profile/profile_binding.dart';
import 'package:taskpro/modules/worker/profile/profile_screen.dart';

class AppPages {
  static const INITIAL = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.workerTasks,
      page: () => const WorkerTasksScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => WorkerTasksController()),
      ),
    ),
    GetPage(
      name: AppRoutes.checkIn,
      page: () => const CheckInScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => CheckinController(task: Get.arguments as WorkOrderModel),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.taskCompletion,
      page: () => const TaskCompletionScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => TaskCompletionController(task: Get.arguments as WorkOrderModel),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ChangePasswordController()),
      ),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.workerdashboard,
      page: () => WorkerDashboardScreen(),
      binding: WorkerDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.forget_password,
      page: () => ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.workerProfile,
      page: () => WorkerProfileScreen(),
      binding: WorkerProfileBinding(),
    ),
  ];
}
