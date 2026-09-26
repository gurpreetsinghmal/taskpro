import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/common/models/work_order_status.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_colors.dart';

class WorkerTasksController extends GetxController {
  final storage = SecureStorageService.instance;
  final RxList<WorkOrderModel> workOrderList = <WorkOrderModel>[].obs;
  final RxList<WorkOrderStatusModel> workOrderStatusList = <WorkOrderStatusModel>[].obs;

  final isApiLoading = false.obs;
  final _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    getTasksData();
  }

  Future<void> getTasksData() async {
   await fetchOfflineTasks();
  }

  Future<void> fetchOfflineTasks() async {
    final String? workOrderStatusListString = await storage.read(StorageKeys.workOrderStatusesList);
    if (workOrderStatusListString != null) {
      final workOrderStatusListJson = jsonDecode(workOrderStatusListString.toString());
      workOrderStatusList.value = (workOrderStatusListJson as List)
          .map((item) => WorkOrderStatusModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    final String? workOrderListString = await storage.read(StorageKeys.workOrderList);
    if (workOrderListString != null) {
      final workOrderListJson = jsonDecode(workOrderListString.toString());
      workOrderList.value = (workOrderListJson as List)
          .map((item) => WorkOrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> acceptWorkOrderApi(int workOrderId,String work_order_no) async {
    try {
      final value = await _apiService.post(ApiRoutes.workOrderStatusUpdate,data: {
        "work_order_id": workOrderId,
        "status_id": 59,
      }, isLoaderShow: true);
      final dynamic responseData = value.data;

      if (responseData != null && responseData['status'].toString() == "true") {
        Get.snackbar(
          'Success',
          'WorK Order No. :  $work_order_no Accepted Successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
      else{
        Get.snackbar(
          'Failed',
          responseData['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }


    } catch (error) {
      debugPrint("❌rejectWorkOrderApi Error: $error");

    }
  }

  Future<void> rejectWorkOrderApi(int workOrderId,String work_order_no) async {
    try {
      final value = await _apiService.post(ApiRoutes.workOrderStatusUpdate,data: {
        "work_order_id": workOrderId,
        "status_id": 13,
      }, isLoaderShow: true);
      final dynamic responseData = value.data;

      if (responseData != null && responseData['status'].toString() == "true") {
        Get.snackbar(
          'Success',
          'WorK Order No. :  $work_order_no Rejected Successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
      else{
        Get.snackbar(
          'Failed',
          responseData['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }


    } catch (error) {
      debugPrint("❌acceptWorkOrderApi Error: $error");

    }
  }

  Future<void> loadMap() async {
    const String address = "742 Evergreen Terrace, Springfield, OR 97477";
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );

    // Directly launch without checking canLaunchUrl if you are confident
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  }



}
