import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taskpro/modules/login/login_controller.dart';

import 'package:taskpro/theme/app_colors.dart';





class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller dynamically
    final controller = Get.put(LoginController());

    // Configure top status bar appearance
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Login to continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 36),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Mobile Number Input Field
                    _buildTextField(
                      controller: controller.usernameController,
                      hintText: 'User Email',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    // Password Input Field with Visibility Toggle
                    Obx(
                          () => _buildTextField(
                        controller: controller.passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isObscure: !controller.isPasswordVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       Get.snackbar(
                    //         'Reset Password',
                    //         'New Password will sent to registered email.',
                    //         snackPosition: SnackPosition.BOTTOM,
                    //         margin: const EdgeInsets.all(16),
                    //       );
                    //     },
                    //     child: const Text(
                    //       'Forget Password?',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w600,
                    //         color: AppColors.primary,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                    controller.isLoading.value ? null : controller.login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text(
              //       "Don't have an account? ",
              //       style: TextStyle(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w500,
              //         color: AppColors.textSecondary,
              //       ),
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         // Navigate to Sign Up Screen
              //       },
              //       child: const Text(
              //         'Sign Up',
              //         style: TextStyle(
              //           fontSize: 14,
              //           fontWeight: FontWeight.bold,
              //           color: AppColors.primary,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}