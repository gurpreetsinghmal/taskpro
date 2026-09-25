import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/modules/worker/profile/profile_model.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'package:taskpro/theme/app_colors.dart';

import '../../../common/helpers/helper_methods.dart';
import '../../../common/models/work_order_status.dart';
import '../../../location/location_service.dart';

class WorkerDashboardController extends GetxController {
  final storage = SecureStorageService.instance;

  final Rxn<WorkerProfileModel> user = Rxn<WorkerProfileModel>();
  final isApiLoading = false.obs;
  final walletBalance = 320.00.obs;

  // Overview Metrics State
  final syncStatus = true.obs;
  final pendingCount = 0.obs;
  final inProgressCount = 0.obs;
  final completedCount = 0.obs;
  final assignedCount = 0.obs;
  final todayCompletedCount = 0.obs;
  final _apiService = ApiService();

  final RxList<WorkOrderModel> workOrderList = <WorkOrderModel>[].obs;
  final RxList<WorkOrderStatusModel> workOrderStatusList = <WorkOrderStatusModel>[].obs;

  void withdrawWallet(double amount) {
    if (walletBalance.value >= amount) {
      walletBalance.value -= amount;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getdata();
  }

  Future<void> getdata() async{
    //await LocationService.start();


    if(await _apiService.checkInternet()){
      await fetchSyncStatus();
      fetchOnlineApis();
    } else {
      fetchOfflineData();
    }
    Common.printAllSecureStorage();
  }

  Future<void> fetchSyncStatus() async {
    print('fetchSyncStatus');
    List<WorkOrderModel>? wlist= await storage.getWorkOrderList();
    //pre check status after sync
    if (wlist != null) {
      syncStatus.value = !wlist.any((e) => e.sync == 0);
    }
    if(await _apiService.checkInternet() && wlist!=null){
      for (final task in wlist) {
        if (task.sync == 0) {
          if(await hitOnlineSyncApi(task))
              {
                task.sync=1;
                await storage.updateWorkOrderData(task);
              }
        }
      }
    }
    //post check status after sync
    if (wlist != null) {
      syncStatus.value = !wlist.any((e) => e.sync == 0);
    }
  }

  Future<bool> hitOnlineSyncApi(WorkOrderModel task) async {
    try {

      final value = await _apiService.post(ApiRoutes.workOrderCheckinSync,data:{
        "checkins":task.checkins.map((e)=>e.toJson()).toList()
      }, isLoaderShow: false);
      final dynamic responseData = value.data;
      if(task.checkins.length==responseData["synced_count"]) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      debugPrint("❌Sync WorkOrder Error: $error");
      return false;
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
      // Executes both API calls InOrder
      await loadWorkOrderStatusListFromApi();
      await loadWorkOrderListFromApi();


    } catch (error) {
      debugPrint("Error fetching initial dashboard data: $error");
    } finally {
      isApiLoading.value = false;
    }
  }

  Future<void> loadProfileFromApi() async {
    try {
      final value = await _apiService.get(ApiRoutes.fetchProfile, isLoaderShow: false);
      final dynamic responseData = value.data;

      if (responseData != null && responseData['user'] != null && responseData['success'].toString()=="true") {
        user.value = WorkerProfileModel.fromJson(responseData['user'] as Map<String, dynamic>);
        await storage.write(StorageKeys.workerProfile, jsonEncode(user.value!.toJson()));
      }

    } catch (error) {
      debugPrint("❌Profile Error: $error");
    }
  }

  Future<void> loadWorkOrderStatusListFromApi() async {
    try {
      final value = await _apiService.post(ApiRoutes.workOrderStatusesList, isLoaderShow: false);
      final dynamic responseData = value.data;
      if (responseData != null && responseData['data'] != null && responseData['status'].toString()=="true") {
        workOrderStatusList.value = (responseData['data'] as List)
            .map((item) => WorkOrderStatusModel.fromJson(item as Map<String, dynamic>))
            .toList();
        await storage.write(StorageKeys.workOrderStatusesList, jsonEncode(
          workOrderStatusList.value
              .map((item) => item.toJson())
              .toList(),
        ));
      }
    } catch (error) {
      debugPrint("❌WorkOrderStatusList Error: $error");
    }
  }

  Future<void> loadWorkOrderListFromApi() async {
    try {
      final value = await _apiService.post(ApiRoutes.workOrderList, isLoaderShow: false);
      final dynamic responseData = value.data;
      if (responseData != null && responseData['data'] != null && responseData['status'].toString()=="success") {
        workOrderList.value = (responseData['data'] as List)
            .map((item) => WorkOrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
        await storage.write(StorageKeys.workOrderList, jsonEncode(
          workOrderList.value.map((item) => item.toJson())
              .toList(),
        ));
      }
    } catch (error,stack) {
      debugPrint("❌WorkOrderList Error: $error $stack");
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
      debugPrint("❌Dashboard Error: $error");
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

    // fetching Status List for Work Order
    final String? statusMaster = await storage.read(StorageKeys.workOrderStatusesList);
    if (statusMaster != null) {
      final data=jsonDecode(statusMaster.toString());
      workOrderStatusList.value = (data as List)
          .map((item) =>
          WorkOrderStatusModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    // fetching Details of All Work Order of Technician
    final String? workOrderListString = await storage.read(StorageKeys.workOrderList);
    if (workOrderListString != null) {
      final workOrderListJson = jsonDecode(workOrderListString.toString());
      workOrderList.value = (workOrderListJson as List)
          .map((item) => WorkOrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }
}
