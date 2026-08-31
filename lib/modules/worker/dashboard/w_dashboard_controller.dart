import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/common/models/task_model.dart';
import 'package:taskpro/common/models/worker_model.dart';
import 'package:taskpro/location/location_service.dart';
import 'package:taskpro/modules/worker/profile/profile_model.dart';

import 'package:taskpro/network/api_service.dart';

import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'package:taskpro/theme/app_colors.dart';

class WorkerDashboardController extends GetxController {
  final storage = SecureStorageService.instance;

  final Rxn<WorkerProfileModel> user = Rxn<WorkerProfileModel>();

  final selectedIndex = 0.obs;
  final isApiLoading = false.obs;
  final walletBalance = 320.00.obs;

  // Overview Metrics State
  final pendingCount = 0.obs;
  final inProgressCount = 0.obs;
  final completedCount = 0.obs;
  final assignedCount = 0.obs;
  final todayCompletedCount = 7.obs;
  final _apiService = ApiService();

  // Tasks List State
  final tasks = <TaskModel>[
    TaskModel(
      id: '1',
      title: 'HVAC Maintenance Unit B',
      category: 'Maintenance',
      status: 'In Progress',
      priority: 'High',
      worker: 'Alex Morgan',
    ),
    TaskModel(
      id: '2',
      title: 'Electrical Safety Inspection',
      category: 'Inspection',
      status: 'Pending',
      priority: 'Medium',
      worker: 'Alex Morgan',
    ),
    TaskModel(
      id: '3',
      title: 'Plumbing System Leak Repair',
      category: 'Plumbing',
      status: 'Completed',
      priority: 'Urgent',
      worker: 'David Chen',
    ),
    TaskModel(
      id: '4',
      title: 'Solar Panel Array Cleaning',
      category: 'Cleaning',
      status: 'Pending',
      priority: 'Low',
      worker: 'Sarah Jenkins',
    ),
  ].obs;

  // Workers List State
  final workers = <WorkerModel>[
    WorkerModel(
      name: 'Alex Morgan',
      role: 'Senior Technician',
      status: 'On Field',
      activeTasks: 4,
    ),
    WorkerModel(
      name: 'David Chen',
      role: 'Electrical Specialist',
      status: 'Available',
      activeTasks: 2,
    ),
    WorkerModel(
      name: 'Sarah Jenkins',
      role: 'Safety Inspector',
      status: 'On Break',
      activeTasks: 1,
    ),
    WorkerModel(
      name: 'Robert Fox',
      role: 'HVAC Specialist',
      status: 'On Field',
      activeTasks: 5,
    ),
  ].obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void addTask(String title, String category) {
    if (title.trim().isEmpty) return;
    tasks.insert(
      0,
      TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        category: category,
        status: 'Pending',
        priority: 'Medium',
        worker: 'Alex Morgan',
      ),
    );
    pendingCount.value++;
    assignedCount.value++;
  }

  void withdrawWallet(double amount) {
    if (walletBalance.value >= amount) {
      walletBalance.value -= amount;
    }
  }

  @override
  onInit()  {
    super.onInit();

   getdata();
  }

  Future<void> getdata() async{
    await LocationService.start();
    if(await _apiService.checkInternet()){
      fetchOnlineApis();
    }
    else{
      fetchOfflineData();
    }
  }

  Future<void> fetchOnlineApis() async {
    debugPrint("Fetching Online data...");
    isApiLoading.value = true;
    try {
      // Executes both API calls simultaneously
      await Future.wait([
        loadProfileFromApi(),
        getDashboardData(),
      ]);
    } catch (error) {
      debugPrint("Error fetching initial data: $error");
    }
    finally {
      isApiLoading.value = false;
    }
  }

  Future<void> loadProfileFromApi() async {
    try {
      final value = await _apiService.get(ApiRoutes.fetchProfile, isLoaderShow: false);
      
      // Dio's response data is already parsed if it's JSON
      final dynamic responseData = value.data;
      
      // Save to storage as a string
      await storage.write(StorageKeys.workerProfile, jsonEncode(responseData["user"]));
      
      if (responseData != null && responseData['user'] != null) {
        user.value = WorkerProfileModel.fromJson(responseData['user'] as Map<String, dynamic>);
       }
    } catch (error) {
      debugPrint("Profile Error: $error");
      Get.snackbar(
        'Failed',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> getDashboardData() async {
    try {
      final value = await _apiService.get('auth/dashboard');
      
      if (value.data['success'] == true) {
        final stats = value.data['data'];
        if (stats != null) {
          completedCount.value = stats["completed_work_orders_count"] ?? 0;
          assignedCount.value = stats["assigned_work_orders_count"] ?? 0;
          inProgressCount.value = stats["in_progress_work_orders_count"] ?? 0;
          pendingCount.value = stats["pending_approval_count"] ?? 0;
        }
      } else {
        Get.snackbar(
          'Failed',
          value.data['message'] ?? "Unknown error",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (error) {
      debugPrint("Dashboard Error: $error");
      Get.snackbar(
        'Failed',
        "Something Went Wrong",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> fetchOfflineData() async {
    debugPrint("⚠ Fetching offline data...");
    final String? profileData = await storage.read(StorageKeys.workerProfile);
    if (profileData != null) {
      final userjson=jsonDecode(profileData.toString());
      //forcefully remove pic for offline
      userjson["photo"]=null;
      await storage.write(StorageKeys.workerProfile, jsonEncode(userjson));
      user.value = WorkerProfileModel.fromJson(userjson);
    }
  }
}
