
import 'package:get/get_navigation/src/routes/get_route.dart';
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
    GetPage(name: AppRoutes.splash, page: () => SplashScreen(), binding: SplashBinding()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen(), binding: LoginBinding()),
    GetPage(name: AppRoutes.workerdashboard, page: () => WorkerDashboardScreen(), binding: WorkerDashboardBinding()),
    GetPage(name: AppRoutes.onboarding, page: () => OnboardingScreen(), binding: OnboardingBinding()),
    GetPage(name: AppRoutes.forget_password, page: () => ForgotPasswordScreen(), binding: ForgotPasswordBinding()),
    GetPage(name: AppRoutes.workerProfile, page: () => WorkerProfileScreen(), binding: WorkerProfileBinding()),
  ];
}
