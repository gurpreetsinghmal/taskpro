import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/location/location_controller.dart';
import 'package:taskpro/location/location_service.dart';
import 'package:taskpro/modules/app_routes/app_pages.dart';
import 'package:taskpro/modules/app_routes/app_routes.dart';
import 'package:taskpro/modules/splash/splash_bindings.dart';
import 'package:taskpro/modules/splash/splash_screen.dart';
import 'package:taskpro/theme/app_colors.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await LocationService.initialize();

  Get.put(LocationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes,
      initialBinding: SplashBinding(),
      initialRoute: AppRoutes.splash,
      title: 'Task Pro',
      theme: ThemeData(colorSchemeSeed: AppColors.primaryDark),
      home: const SplashScreen(),
    );
  }
}
