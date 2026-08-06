import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/app_helper.dart';
import 'package:taskpro/theme/app_colors.dart';
import 'onboarding_controller.dart';
import 'onboarding_model.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSection(),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.pages.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    item: controller.pages[index],
                  );
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
      child: Row(
        children: [
          const _TaskProLogo(),
          const Spacer(),
          Obx(
                () => AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: controller.isLastPage ? 0 : 1,
              child: IgnorePointer(
                ignoring: controller.isLastPage,
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        children: [
          Obx(
                () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.pages.length,
                    (index) {
                  final bool selected =
                      controller.currentPage.value == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFD6E4F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 28),
          Obx(()=>findButton(title: controller.isLastPage
              ? 'Get Started'
              : 'Continue',
              backgroundColor: AppColors.primaryDark,
              onPressed: controller.nextPage,icon:Icon(
            controller.isLastPage
                ? Icons.check_rounded
                : Icons.arrow_forward_rounded,
                color: AppColors.textWhite,
          ) )),

        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingModel item;

  const _OnboardingPage({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 245,
            height: 245,
            decoration: BoxDecoration(
              color: item.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 30,
                  right: 34,
                  child: _DecorationCircle(
                    size: 22,
                    color: item.iconColor.withValues(alpha: 0.12),
                  ),
                ),
                Positioned(
                  bottom: 42,
                  left: 30,
                  child: _DecorationCircle(
                    size: 34,
                    color: item.iconColor.withValues(alpha: 0.10),
                  ),
                ),
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: item.iconColor.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    size: 70,
                    color: item.iconColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF172B4D),
              fontSize: 27,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 410,
            ),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7C93),
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskProLogo extends StatelessWidget {
  const _TaskProLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.task_alt_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'TaskPro',
          style: TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DecorationCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorationCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}