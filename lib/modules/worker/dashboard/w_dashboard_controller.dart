import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:taskpro/common/models/task_model.dart';
import 'package:taskpro/common/models/worker_model.dart';
import 'package:taskpro/network/api_service.dart';

import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'package:dio/dio.dart' as dio;
import 'package:taskpro/theme/app_colors.dart';

class WorkerDashboardController extends GetxController {
  final storage = SecureStorageService.instance;

  RxString name = "".obs;
  RxString role = "".obs;
  RxString email = "".obs;
  RxString accesstoken = "".obs;

  final selectedIndex = 0.obs;
  final walletBalance = 320.00.obs;

  // Overview Metrics State
  final pendingCount = 0.obs;
  final inProgressCount = 0.obs;
  final completedCount = 0.obs;
  final assignedCount = 0.obs;
  final todayCompletedCount = 7.obs;

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
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getprofile();
    getDashboardData();
  }

  getDashboardData() async {
    final _apiService = ApiService();
    await _apiService
        .get('auth/dashboard')
        .then((value) async {
          if (value.data['success']) {
            Get.snackbar(
              'Success',
              value.data['message'],
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );

            final stats = value.data['data'];

            completedCount.value = stats["completed_work_orders_count"];
            assignedCount.value = stats["assigned_work_orders_count"];
            inProgressCount.value = stats["in_progress_work_orders_count"];
            pendingCount.value = stats["pending_approval_count"];

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
          Get.snackbar(
            'Failed',
            "Something Went Wrong",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        });
  }

  getprofile() async {
    storage.read(StorageKeys.empname).then((value) {
      var x = jsonDecode(value!);
      name.value = x["name"];
      role.value = x["role"];
      email.value = x["email"];
    });

    storage.read(StorageKeys.accessToken).then((v) {
      accesstoken.value = v!;
    });
  }
}
