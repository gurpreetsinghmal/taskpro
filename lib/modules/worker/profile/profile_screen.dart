import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/modules/worker/profile/profile_controller.dart';
import 'package:taskpro/modules/worker/profile/profile_model.dart';
import 'package:taskpro/theme/app_colors.dart';


class WorkerProfileScreen extends GetView<WorkerProfileController> {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WorkerProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Obx(() => TextButton.icon(
            onPressed: controller.toggleEditMode,
            icon: Icon(
              controller.isEditing.value ? Icons.cancel_outlined : Icons.edit_outlined,
              color: AppColors.primary,
            ),
            label: Text(
              controller.isEditing.value ? "Cancel" : "Edit",
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          )),
        ],
      ),
      body: Obx(() {
        final userData = controller.user.value;
        if (userData == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: controller.profileFormKey,
              child: Column(
                children: [
                  // Avatar Header Card
                  _buildHeaderCard(userData),
                  const SizedBox(height: 24),

                  // Personal Information Section
                  _buildSectionHeader("Personal Details"),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "First Name",
                    controller: controller.firstNameController,
                    icon: Icons.person_outline,
                    isEditable: controller.isEditing.value,
                    validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Middle Name",
                    controller: controller.middleNameController,
                    icon: Icons.person_outline,
                    isEditable: controller.isEditing.value,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Last Name",
                    controller: controller.lastNameController,
                    icon: Icons.person_outline,
                    isEditable: controller.isEditing.value,
                    validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 24),

                  // Contact Details Section
                  _buildSectionHeader("Contact Details"),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Primary Email (Read-Only)",
                    initialValue: userData.email,
                    icon: Icons.email_outlined,
                    isEditable: false,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Primary Phone",
                    controller: controller.phoneController,
                    icon: Icons.phone_outlined,
                    isEditable: controller.isEditing.value,
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Other Email",
                    controller: controller.otherEmailController,
                    icon: Icons.mark_email_read_outlined,
                    isEditable: controller.isEditing.value,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val != null && val.isNotEmpty && !GetUtils.isEmail(val)) {
                        return "Invalid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: "Other Phone",
                    controller: controller.otherPhoneController,
                    icon: Icons.phone_android_outlined,
                    isEditable: controller.isEditing.value,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 32),

                  // Action Button on Edit Mode
                  if (controller.isEditing.value)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: AppColors.textWhite)
                            : const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard(WorkerProfileModel userData) {
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
          // 1. Avatar with Reactive Null Check
          Obx(() {
            final user = controller.user.value;

            if (user == null) {
              return const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.infoLight,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            final initial = user.firstName.isNotEmpty
                ? user.firstName[0].toUpperCase()
                : '?';
            final hasPhoto = user.photo != null && user.photo!.isNotEmpty;

            return CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.infoLight,
              backgroundImage: hasPhoto ? NetworkImage(user.photo!) : null,
              child: !hasPhoto
                  ? Text(
                initial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
                  : null,
            );
          }),
          const SizedBox(height: 12),
          Text(
            userData.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            userData.email,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              userData.currentRole,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    required IconData icon,
    required bool isEditable,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      enabled: isEditable,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isEditable ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: isEditable ? FontWeight.normal : FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: isEditable ? AppColors.iconPrimary : AppColors.iconSecondary, size: 20),
        filled: true,
        fillColor: isEditable ? AppColors.surface : AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      validator: validator,
    );
  }
}