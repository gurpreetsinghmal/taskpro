import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taskpro/modules/forgotpassword/forgot_password_controller.dart';
import 'package:taskpro/modules/forgotpassword/forgot_password_model.dart';
import 'package:taskpro/theme/app_colors.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // scrolledUnderMaterialElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 16,
              ),
            ),
            onPressed: () {
              if (controller.handleBackPress()) {
                Get.back();
              }
            },
          ),
        ),
        actions: [
          // PROSAT Networks Brand Tag in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.cell_tower_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "PROSAT",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Text(
                    " NETWORKS",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Step Tracker
              Obx(() => _buildStepProgressIndicator()),
              const SizedBox(height: 32),

              // Header Section (Icon, Title, Subtitle)
              _buildHeaderSection(),
              const SizedBox(height: 28),

              // Animated Form Step Wrapper
              Obx(
                    () => AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildCurrentStepForm(),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // PROSAT Security Footer Watermark
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Secured by PROSAT Networks",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // =======================================================
  // Header Section with Dynamic Icon & Animated Text
  // =======================================================
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dynamic Badge Icon with Ambient Tint
        Obx(
              () => Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Icon(
              _getHeaderIcon(),
              size: 30,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Animated Title & Subtitle
        Obx(
              () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Column(
              key: ValueKey(controller.currentStep.value),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getHeaderTitle(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getHeaderSubtitle(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =======================================================
  // Sleek Step Progress Indicator
  // =======================================================
  Widget _buildStepProgressIndicator() {
    int currentStepIndex = controller.currentStep.value.index;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          _buildStepItem(
            stepIndex: 0,
            label: "Email",
            isCompleted: currentStepIndex > 0,
            isCurrent: currentStepIndex == 0,
          ),
          _buildStepConnector(isCompleted: currentStepIndex > 0),
          _buildStepItem(
            stepIndex: 1,
            label: "OTP",
            isCompleted: currentStepIndex > 1,
            isCurrent: currentStepIndex == 1,
          ),
          _buildStepConnector(isCompleted: currentStepIndex > 1),
          _buildStepItem(
            stepIndex: 2,
            label: "Reset",
            isCompleted: currentStepIndex == 2,
            isCurrent: currentStepIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepIndex,
    required String label,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : isCurrent
                ? AppColors.primary
                : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isCurrent
                  ? Colors.transparent
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
              Icons.check_rounded,
              color: AppColors.textWhite,
              size: 16,
            )
                : Text(
              "${stepIndex + 1}",
              style: TextStyle(
                color: isCurrent
                    ? AppColors.textWhite
                    : AppColors.textHint,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrent || isCompleted
                ? FontWeight.w600
                : FontWeight.w500,
            color: isCurrent || isCompleted
                ? AppColors.textPrimary
                : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 2,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success : AppColors.border,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // Step Form Switcher
  // =======================================================
  Widget _buildCurrentStepForm() {
    switch (controller.currentStep.value) {
      case ForgotPasswordModel.email:
        return _buildEmailStep();
      case ForgotPasswordModel.otp:
        return _buildOtpStep();
      case ForgotPasswordModel.newPassword:
        return _buildNewPasswordStep();
    }
  }

  // Step 1: Registered Email Form
  Widget _buildEmailStep() {
    return Form(
      key: controller.emailFormKey,
      child: Column(
        key: const ValueKey('emailStep'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Registered Email",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            decoration: _inputDecoration(
              hint: "e.g. alex@prosat.net",
              prefixIcon: Icons.mail_outline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            label: "Send Verification Code",
            onPressed: controller.submitEmail,
          ),
        ],
      ),
    );
  }

  // Step 2: OTP Verification Form
  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey('otpStep'),
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              6,
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 48,
                height: 56,
                child: TextFormField(
                  controller: controller.otpControllers[index],
                  focusNode: controller.otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      controller.otpFocusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      controller.otpFocusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive code? ",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () async {
                controller.clearOtpFields();
                await controller.api_send_Email_OTP();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  "Resend OTP",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          label: "Verify & Proceed",
          onPressed: controller.submitOtp,
        ),
      ],
    );
  }

  // Step 3: Password & Confirm Password Form
  Widget _buildNewPasswordStep() {
    return Form(
      key: controller.passwordFormKey,
      child: Column(
        key: const ValueKey('passwordStep'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "New Password",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
                () => TextFormField(
              controller: controller.newPasswordController,
              obscureText: !controller.isNewPasswordVisible.value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              decoration: _inputDecoration(
                hint: "Create strong password",
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isNewPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: controller.toggleNewPasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters.';
                }
                final passwordRegex = RegExp(
                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~•^%()_+\-=\[\]{};:"\\|,.<>/?]).{8,}$',
                );

                if (!passwordRegex.hasMatch(value)) {
                  if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
                    return 'Must include uppercase and lowercase letters.';
                  }
                  if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                    return 'Must contain at least one number.';
                  }
                  if (!RegExp(r'(?=.*[!@#\$&*~•^%()_+\-=\[\]{};:"\\|,.<>/?])')
                      .hasMatch(value)) {
                    return 'Must contain at least one special character.';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Confirm Password",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
                () => TextFormField(
              controller: controller.confirmPasswordController,
              obscureText: !controller.isConfirmPasswordVisible.value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
              decoration: _inputDecoration(
                hint: "Re-enter new password",
                prefixIcon: Icons.lock_reset_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != controller.newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Dynamic Password Requirements Checklist
          _buildPasswordRequirementsCard(),
          const SizedBox(height: 32),

          _buildActionButton(
            label: "Reset Password",
            onPressed: controller.resetPassword,
          ),
        ],
      ),
    );
  }

  // Live Password Requirement Helper Box
  Widget _buildPasswordRequirementsCard() {
    return ListenableBuilder(
      listenable: controller.newPasswordController,
      builder: (context, _) {
        final text = controller.newPasswordController.text;
        final hasLength = text.length >= 8;
        final hasUpperLower = RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(text);
        final hasNumber = RegExp(r'(?=.*\d)').hasMatch(text);
        final hasSpecial =
        RegExp(r'(?=.*[!@#\$&*~•^%()_+\-=\[\]{};:"\\|,.<>/?])')
            .hasMatch(text);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Password must contain:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildRequirementItem("8+ characters", hasLength),
                  _buildRequirementItem("Upper & Lowercase", hasUpperLower),
                  _buildRequirementItem("At least 1 number", hasNumber),
                  _buildRequirementItem("Special character", hasSpecial),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 14,
          color: isMet ? AppColors.success : AppColors.textHint,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? AppColors.textPrimary : AppColors.textHint,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // =======================================================
  // Helper Widgets (Buttons & Input Decorators)
  // =======================================================
  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Obx(
            () => ElevatedButton(
          onPressed: controller.isLoading.value ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            disabledBackgroundColor:
            AppColors.buttonPrimary.withValues(alpha: 0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: AppColors.textWhite,
              strokeWidth: 2.2,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.textWhite,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.iconSecondary,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  // =======================================================
  // Helper Enums & Strings
  // =======================================================
  IconData _getHeaderIcon() {
    switch (controller.currentStep.value) {
      case ForgotPasswordModel.email:
        return Icons.mark_email_unread_outlined;
      case ForgotPasswordModel.otp:
        return Icons.phonelink_ring_outlined;
      case ForgotPasswordModel.newPassword:
        return Icons.lock_reset_outlined;
    }
  }

  String _getHeaderTitle() {
    switch (controller.currentStep.value) {
      case ForgotPasswordModel.email:
        return "Forgot Password?";
      case ForgotPasswordModel.otp:
        return "Verify Mobile OTP";
      case ForgotPasswordModel.newPassword:
        return "Set New Password";
    }
  }

  String _getHeaderSubtitle() {
    switch (controller.currentStep.value) {
      case ForgotPasswordModel.email:
        return "Enter your registered email address to receive an OTP on your linked mobile number.";
      case ForgotPasswordModel.otp:
        return "Enter the 6-digit verification code sent to your registered mobile number.";
      case ForgotPasswordModel.newPassword:
        return "Create a strong new password for your PROSAT Networks account.";
    }
  }
}