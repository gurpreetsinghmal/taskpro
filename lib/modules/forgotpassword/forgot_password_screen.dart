import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taskpro/modules/forgotpassword/forgot_password_controller.dart';
import 'package:taskpro/modules/forgotpassword/forgot_password_model.dart';
import 'package:taskpro/theme/app_colors.dart';


class ForgotPasswordScreen
    extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (controller.handleBackPress()) {
              Get.back();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Progress Indicator
              Obx(() => _buildStepProgressIndicator()),
              const SizedBox(height: 32),
              // Dynamic Header Icon Badge
              Obx(() => Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getHeaderIcon(),
                  size: 36,
                  color: AppColors.primary,
                ),
              )),
              const SizedBox(height: 24),

              // Title & Subtitle
              Obx(() => Text(
                _getHeaderTitle(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              )),
              const SizedBox(height: 8),
              Obx(() => Text(
                _getHeaderSubtitle(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              )),
              const SizedBox(height: 32),

              // Step Form Transition
              Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepForm(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // =======================================================
  // Step Progress Indicator Widget
  // =======================================================
  Widget _buildStepProgressIndicator() {
    int currentStepIndex = controller.currentStep.value.index;

    return Row(
      children: [
        _buildStepCircle(
          stepIndex: 0,
          label: "Email",
          isCompleted: currentStepIndex > 0,
          isCurrent: currentStepIndex == 0,
        ),
        _buildStepConnector(isCompleted: currentStepIndex > 0),
        _buildStepCircle(
          stepIndex: 1,
          label: "OTP",
          isCompleted: currentStepIndex > 1,
          isCurrent: currentStepIndex == 1,
        ),
        _buildStepConnector(isCompleted: currentStepIndex > 1),
        _buildStepCircle(
          stepIndex: 2,
          label: "Reset",
          isCompleted: currentStepIndex == 2,
          isCurrent: currentStepIndex == 2,
        ),
      ],
    );
  }

  Widget _buildStepCircle({
    required int stepIndex,
    required String label,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color circleColor;
    Color textColor;

    if (isCompleted) {
      circleColor = AppColors.success;
      textColor = AppColors.textWhite;
    } else if (isCurrent) {
      circleColor = AppColors.primary;
      textColor = AppColors.textWhite;
    } else {
      circleColor = AppColors.border;
      textColor = AppColors.textHint;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
              Icons.check,
              color: AppColors.textWhite,
              size: 18,
            )
                : Text(
              "${stepIndex + 1}",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
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
        padding: const EdgeInsets.only(bottom: 20.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 3,
          color: isCompleted ? AppColors.success : AppColors.border,
        ),
      ),
    );
  }

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
        return "Create a new strong password for your TaskPro account.";
    }
  }

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
        children: [
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: "Enter registered email",
              prefixIcon: Icons.email_outlined,
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
            label: "Proceed",
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
                (index) => SizedBox(
              width: 45,
              height: 45,
              child: TextFormField(
                controller: controller.otpControllers[index],
                focusNode: controller.otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.infoLight,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
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
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive code? ",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            GestureDetector(
              onTap: () async {
                controller.clearOtpFields();
                await controller.api_send_Email_OTP();
              },
              child: const Text(
                "Resend OTP",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          label: "Verify OTP",
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
        children: [
          Obx(() => TextFormField(
            controller: controller.newPasswordController,
            obscureText: !controller.isNewPasswordVisible.value,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: "New Password",
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isNewPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: controller.toggleNewPasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password length must be 8 characters.';
              }

              // Checks for uppercase, lowercase, number, and symbol in one pass
              final passwordRegex = RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~•^%()_+\-=\[\]{};:"\\|,.<>/?]).{8,}$',
              );

              if (!passwordRegex.hasMatch(value)) {
                if (!RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(value)) {
                  return 'The password must at least one uppercase and one lowercase letter.';
                }
                if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                  return 'The password must contain at least one number.';
                }
                if (!RegExp(r'(?=.*[!@#\$&*~•^%()_+\-=\[\]{};:"\\|,.<>/?])').hasMatch(value)) {
                  return 'The password must contain at least one symbol.';
                }
              }
              return null;
            },
          )),
          const SizedBox(height: 16),
          Obx(() => TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: !controller.isConfirmPasswordVisible.value,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: "Confirm Password",
              prefixIcon: Icons.lock_reset_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Confirm password';
              if (value != controller.newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          )),
          const SizedBox(height: 32),
          _buildActionButton(
            label: "Reset Password",
            onPressed: controller.resetPassword,
          ),
        ],
      ),
    );
  }

  // Action Button
  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          disabledBackgroundColor: AppColors.buttonDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.textWhite,
            strokeWidth: 2.5,
          ),
        )
            : Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
      )),
    );
  }

  // Shared Input Decoration
  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 15),
      prefixIcon: Icon(prefixIcon, color: AppColors.iconSecondary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
}