import 'package:flutter/material.dart';
import 'package:taskpro/modules/app_routes/app_routes.dart';
import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'package:url_launcher/url_launcher.dart';


class SplashController extends GetxController {
  final _storage = SecureStorageService.instance;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 3));

    if (isClosed) return;
    final updateRequired = await _checkForRequiredUpdate();
    if (updateRequired || isClosed) return;


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


    if (loggedIn) {
      Get.offAllNamed(AppRoutes.workerdashboard);
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        if (!isClosed) Get.offAllNamed(AppRoutes.login);
      });
    }
  }

  Future<bool> _checkForRequiredUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await ApiService().get(ApiRoutes.appVersion);
      final data =response.data;
      final latestVersion = data['latest_version']?.toString();
      final bool forceUpdate = data['force_update'].toString()=="true";

      if (latestVersion == null || !_isVersionHigher(latestVersion, packageInfo.version)) {
        return false;
      }


      final bool result=await Get.dialog<bool>(
        PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            elevation: 0,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 390),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF153B82).withValues(alpha:.20),
                    blurRadius: 35,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // PREMIUM GRADIENT HEADER
                    SizedBox(
                      height: 205,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF0B2E78),
                                    Color(0xFF1753CC),
                                    Color(0xFF3789FF),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Decorative circles
                          Positioned(
                            top: -55,
                            left: -55,
                            child: _updateCircle(155, .08),
                          ),
                          Positioned(
                            right: -55,
                            bottom: -75,
                            child: _updateCircle(180, .09),
                          ),
                          Positioned(
                            top: 22,
                            right: 35,
                            child: _updateCircle(22, .16),
                          ),
                          Positioned(
                            bottom: 30,
                            left: 38,
                            child: _updateCircle(14, .25),
                          ),

                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              // Circular logo with outer rings
                              Container(
                                width: 106,
                                height: 106,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha:.13),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha:.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha:.12),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/prosat.gif',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_,_,_) =>
                                      const Icon(
                                        Icons.home_repair_service_rounded,
                                        size: 45,
                                        color: Color(0xFF1753CC),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 13),
                              const Text(
                                'PSN TASK PRO',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.6,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A better experience awaits',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha:.80),
                                ),
                              ),
                            ],
                          ),
                          if (!forceUpdate)
                            Positioned(
                              top: 10,
                              right: 12,
                              child: Material(
                                color: Colors.white.withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Get.back(result: false);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 7,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Skip',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // CONTENT
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        23, 22, 23, 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 15,
                                ),
                                SizedBox(width: 7),
                                Text(
                                  'NEW VERSION AVAILABLE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .7,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Update Required',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF142747),
                              letterSpacing: -.5,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'A newer version of PSN Task Pro is '
                                'ready. Update now to enjoy improved '
                                'performance, enhanced security, and '
                                'the latest features.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: Color(0xFF64748B),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // VERSION INFORMATION
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F7FE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE1EAFA),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0ECFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Latest Version',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF203957),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Version $latestVersion',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // UPDATE BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1645B5),
                                    Color(0xFF2879F4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha:.28),
                                    blurRadius: 15,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius:
                                  BorderRadius.circular(15),
                                  onTap: _openStore,
                                  child: const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                        size: 21,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Update Now',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 13,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Required to continue using the app',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      )??true;



      return result;
    } catch (_) {
      // A failed optional version check should not block normal app startup.
      return false;
    }
  }

  bool _isVersionHigher(String latest, String current) {
    List<int> parse(String value) => value
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final latestParts = parse(latest);
    final currentParts = parse(current);
    for (var i = 0; i < 3; i++) {
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (latestPart != currentPart) return latestPart > currentPart;
    }
    return false;
  }

  Future<void> _openStore() async {
    final storeUrl = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.example.taskpro'
        : 'https://apps.apple.com/app/id0000000000';
    await launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
  }

  // Add this helper method to the same class.
  Widget _updateCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha:opacity),
        border: Border.all(
          color: Colors.white.withValues(alpha:.12),
        ),
      ),
    );
  }
}
