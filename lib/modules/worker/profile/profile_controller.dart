import 'package:taskpro/modules/app_routes/app_routes.dart';
import '../../../services/local_data_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/modules/worker/profile/profile_model.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/theme/app_colors.dart';

class WorkerProfileController extends GetxController {
  final isLoading = false.obs;
  final isEditing = false.obs;
  WorkerProfileController({LocalDataService? local})
    : local = local ?? LocalDataService.instance;
  final LocalDataService local;
  Rxn<WorkerProfileModel> get user => local.profile;
  Worker? _profileWorker;

  // Text Controllers for Editable Fields
  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController otherPhoneController;
  late TextEditingController otherEmailController;

  final profileFormKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _profileWorker = ever(user, (_) {
      if (!isEditing.value) populateControllers();
    });
    loadProfileFromStorage();
  }

  void _initControllers() {
    firstNameController = TextEditingController();
    middleNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    otherPhoneController = TextEditingController();
    otherEmailController = TextEditingController();
  }

  Future<void> loadProfileFromStorage() async {
    await local.initialize();
    if (!isClosed) populateControllers();
  }

  void populateControllers() {
    if (user.value == null) return;
    firstNameController.text = user.value!.firstName;
    middleNameController.text = user.value!.middleName ?? '';
    lastNameController.text = user.value!.lastName;
    phoneController.text = user.value!.phoneNumber;
    otherPhoneController.text = user.value!.otherPhone ?? '';
    otherEmailController.text = user.value!.otherEmail ?? '';
  }

  void toggleEditMode() {
    if (isEditing.value) {
      populateControllers(); // Reset changes if canceled
    }
    isEditing.value = !isEditing.value;
  }

  Future<void> api_SaveProfile() async {
    // Local update simulation
    final updatedUser = WorkerProfileModel(
      id: user.value!.id,
      name:
          "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
      email: user.value!.email,
      firstName: firstNameController.text.trim(),
      middleName: middleNameController.text.trim().isEmpty
          ? null
          : middleNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      otherPhone: otherPhoneController.text.trim().isEmpty
          ? null
          : otherPhoneController.text.trim(),
      otherEmail: otherEmailController.text.trim().isEmpty
          ? null
          : otherEmailController.text.trim(),
      roles: user.value!.roles,
      currentRole: user.value!.currentRole,
      photo: null,
    );

    await _apiService
        .post(ApiRoutes.updateProfile, data: updatedUser.toJson())
        .then((value) async {
          isLoading.value = false;
          isEditing.value = false;
          if (value.data['success']) {
            await local.saveProfile(updatedUser);
            Get.snackbar(
              'Success',
              value.data['message'],
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
            Get.offAllNamed(AppRoutes.workerdashboard);
          } else {
            Get.snackbar(
              'Failed',
              value.data['message'],
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
          }
        })
        .catchError((error) {
          isLoading.value = false;
          isEditing.value = false;
          Get.snackbar(
            'Failed',
            'something went wrong',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        });
  }

  Future<void> saveProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    isLoading.value = true;
    await api_SaveProfile(); // Simulate API payload save
  }

  @override
  void onClose() {
    _profileWorker?.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    otherPhoneController.dispose();
    otherEmailController.dispose();
    super.onClose();
  }
}
