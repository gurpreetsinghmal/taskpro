import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/theme/app_colors.dart';
import 'change_password_controller.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                // Header Card
                _buildHeaderCard(),
                const SizedBox(height: 24),

                _buildSectionHeader("Security Credentials"),
                const SizedBox(height: 12),

                // Current Password
                Obx(() => _buildPasswordField(
                  label: "Current Password",
                  controller: controller.oldPasswordController,
                  icon: Icons.lock_outline,
                  isVisible: controller.isOldPasswordVisible.value,
                  onToggleVisibility: controller.toggleOldPasswordVisibility,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Current password is required";
                    }
                    if (!controller.isPasswordPolicyValid) {
                      return "Password does not meet Policy Standards";
                    }
                    return null;
                  },
                )),

                const SizedBox(height: 12),

                // New Password
                Obx(() => _buildPasswordField(
                  label: "New Password",
                  controller: controller.newPasswordController,
                  icon: Icons.lock_reset,
                  isVisible: controller.isNewPasswordVisible.value,
                  onToggleVisibility: controller.toggleNewPasswordVisibility,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "New password is required";
                    }
                    if (!controller.isPasswordPolicyValid) {
                      return "Password does not meet requirements";
                    }
                    if (val == controller.oldPasswordController.text) {
                      return "New password cannot match current password";
                    }
                    return null;
                  },
                )),

                const SizedBox(height: 16),

                // Password Policy Card Widget
                _buildPasswordPolicyCard(),

                const SizedBox(height: 16),

                // Confirm Password
                Obx(() => _buildPasswordField(
                  label: "Confirm New Password",
                  controller: controller.confirmPasswordController,
                  icon: Icons.check_circle_outline,
                  isVisible: controller.isConfirmPasswordVisible.value,
                  onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please confirm your password";
                    }
                    if (val != controller.newPasswordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                )),

                const SizedBox(height: 32),

                // Submit Button
                Obx(
                      () => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textWhite,
                        ),
                      )
                          : const Text(
                        "Update Password",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.infoLight,
            child: Icon(
              Icons.shield_outlined,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Account Security",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Update your password to keep your account secure",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordPolicyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password Requirements:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => _buildPolicyRule("At least 8 characters", controller.hasMinLength.value)),
          const SizedBox(height: 6),
          Obx(() => _buildPolicyRule("One uppercase letter (A-Z)", controller.hasUppercase.value)),
          const SizedBox(height: 6),
          Obx(() => _buildPolicyRule("One lowercase letter (a-z)", controller.hasLowercase.value)),
          const SizedBox(height: 6),
          Obx(() => _buildPolicyRule("One numeric digit (0-9)", controller.hasNumber.value)),
          const SizedBox(height: 6),
          Obx(() => _buildPolicyRule("One special character (@, #, \$, etc.)", controller.hasSpecialChar.value)),
        ],
      ),
    );
  }

  Widget _buildPolicyRule(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: isMet ? Colors.green : AppColors.iconSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.iconPrimary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.iconSecondary,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}