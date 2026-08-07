import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskpro/modules/app_routes/app_routes.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'onboarding_model.dart';

class OnboardingController extends GetxController {


  final PageController pageController = PageController();

  final RxInt currentPage = 0.obs;
  final RxBool isSaving = false.obs;

  final List<OnboardingModel> pages = const [
    OnboardingModel(
      title: 'Report and Track Work',
      description:
          'Citizens can submit work requests, provide details and track their progress from one simple platform.',
      icon: Icons.assignment_outlined,
      backgroundColor: Color(0xFFEAF3FF),
      iconColor: Color(0xFF1565D8),
    ),
    OnboardingModel(
      title: 'Assign and Manage Tasks',
      description:
          'Managers can review requests, assign work to the right worker and monitor every task until completion.',
      icon: Icons.manage_accounts_outlined,
      backgroundColor: Color(0xFFE8F1FF),
      iconColor: Color(0xFF0D47A1),
    ),
    OnboardingModel(
      title: 'Complete Work with Proof',
      description:
          'Workers complete assigned tasks by uploading work images. Managers verify the work and mark it complete.',
      icon: Icons.task_alt_rounded,
      backgroundColor: Color(0xFFE6F4FF),
      iconColor: Color(0xFF1976D2),
    ),
  ];

  bool get isLastPage => currentPage.value == pages.length - 1;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> nextPage() async {
    if (isLastPage) {
      await completeOnboarding();
      return;
    }

    await pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> skipOnboarding() async {
    await completeOnboarding();
  }

  Future<void> completeOnboarding() async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final preferences = await SharedPreferences.getInstance();

      await preferences.setBool(StorageKeys.taskpro_onboarding_completed,true);

      // Remove onboarding from navigation history.
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      Get.snackbar(
        'Unable to continue',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
