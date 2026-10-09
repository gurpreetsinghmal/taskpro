import 'package:flutter/services.dart';
import '../../../services/local_data_service.dart';
import '../../../common/helpers/helper_methods.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/common/models/work_order_status.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../theme/app_colors.dart';

class WorkerTasksController extends GetxController {
  WorkerTasksController({LocalDataService? local})
    : local = local ?? LocalDataService.instance;
  final LocalDataService local;
  SecureStorageService get storage => local.storage;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;
  Worker? _ordersWorker;

  RxList<WorkOrderModel> get workOrderList => local.workOrders;
  RxList<WorkOrderStatusModel> get workOrderStatusList => local.statuses;

  final isApiLoading = false.obs;
  final RxMap<int, int> hardStartChangeStatus = <int, int>{}.obs;
  final RxMap<int, String> CheckinStatus = <int, String>{}.obs;
  String proposedTimeFor(int id) =>
      local.findOrder(id)?.proposedDatetime?.toString() ?? '';
  final _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _ordersWorker = ever(workOrderList, (_) => _updateTaskState());
    _updateTaskState();
    getTasksData();
  }

  Future<void> getTasksData() async {
    await fetchOfflineTasks();
  }

  Future<void> fetchOfflineTasks() async {
    await local.initialize();
    await local.reload();
  }

  void _onSearchChanged() => searchQuery.value = searchController.text;
  void _updateTaskState() {
    hardStartChangeStatus.assignAll({
      for (final task in workOrderList)
        task.id: task.proposedDatetimeAcceptedByManager ?? 0,
    });
    int? activeId;
    for (final task in workOrderList) {
      if (task.checkins.any((session) => session.isActive)) {
        activeId = task.id;
        break;
      }
    }
    CheckinStatus.assignAll({
      for (final task in workOrderList)
        task.id: task.id == activeId ? 'Checked' : 'Not Checked',
    });
  }

  List<WorkOrderModel> get filteredTasks {
    final query = searchQuery.value.trim().toLowerCase();

    return workOrderList.where((task) {
      final matchesSearch =
          query.isEmpty ||
          task.workOrderTitle.toLowerCase().contains(query) ||
          task.workOrderNo.toString().toLowerCase().contains(query) ||
          task.serviceTypeName.toLowerCase().contains(query) ||
          "${task.managerFirstName} ${task.managerLastName}"
              .toLowerCase()
              .contains(query);

      if (!matchesSearch) {
        return false;
      }

      if (selectedFilter.value == "All") {
        return true;
      }

      if (selectedFilter.value == task.statusName?.toString()) {
        return true;
      }

      final statusText = Common.getStatusText(
        task.statusId,
        workOrderStatusList,
      );

      return statusText.toLowerCase() == selectedFilter.value.toLowerCase();
    }).toList();
  }

  @override
  void onClose() {
    _ordersWorker?.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> acceptWorkOrderApi(int workOrderId, String wno) async {
    try {
      final value = await _apiService.post(
        ApiRoutes.workOrderStatusUpdate,
        data: {"work_order_id": workOrderId, "status_id": 59},
        isLoaderShow: true,
      );
      final dynamic responseData = value.data;

      if (responseData != null && responseData['status'].toString() == "true") {
        await _saveStatus(workOrderId, 59);
        Get.snackbar(
          'Success',
          'WorK Order No. :  $wno Accepted Successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
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

  Future<void> rejectWorkOrderApi(
    int workOrderId,
    String wno,
    String remarks,
  ) async {
    try {
      final value = await _apiService.post(
        ApiRoutes.workOrderStatusUpdate,
        data: {
          "work_order_id": workOrderId,
          "status_id": 61,
          "remarks": remarks,
        },
        isLoaderShow: true,
      );
      final dynamic responseData = value.data;

      if (responseData != null && responseData['status'].toString() == "true") {
        await _saveStatus(workOrderId, 61);
        Get.snackbar(
          'Success',
          'WorK Order No. :  $wno Rejected Successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
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

  Future<void> proposeChangeScheduleTimeApi(
    DateTime newSchedule,
    WorkOrderModel task,
  ) async {
    try {
      final value = await _apiService.post(
        ApiRoutes.workOrderProposedDatetimeUpdate,
        data: {
          "work_order_id": task.id,
          "proposed_datetime": newSchedule.toString(),
          "proposed_reason":
              'Technician requested a change in hard start time.',
        },
        isLoaderShow: true,
      );
      final dynamic responseData = value.data;

      if (responseData != null &&
          responseData['success'].toString() == "true") {
        await storage.editWorkOrder(
          task.id,
          (current) => current.copyWith(
            id: task.id,
            proposedDatetime: newSchedule,
            proposedDatetimeAcceptedByManager: 1,
            requestedAt: DateTime.now(),
            requestedBy: int.tryParse(task.technicianId),
            approvedAt: null,
            approvedBy: null,
            proposedReason: 'Technician requested a change in hard start time.',
          ),
        );
        hardStartChangeStatus[task.id] = 1;
        Get.snackbar(
          'Success',
          responseData['message'].toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'Failed',
          responseData['message'].toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (error) {
      debugPrint("❌ProposedScheduleApi Error: $error");
    }
  }

  Future<bool> areYouCheckedIn(int id) async {
    int? cid = await storage.isAlreadyCheckIn();
    if (cid != null && cid == id) {
      return true;
    }
    return false;
  }

  Future<void> _saveStatus(int id, int statusId) =>
      storage.editWorkOrder(id, (order) {
        String? name;
        for (final status in workOrderStatusList) {
          if (status.id == statusId) name = status.name;
        }
        return order.copyWith(statusId: statusId, statusName: name);
      });

  Future<void> loadMap(String? loc) async {
    const String address = "742 Evergreen Terrace, Springfield, OR 97477";
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );

    // Directly launch without checking canLaunchUrl if you are confident
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  }

  void copyManagerContact(WorkOrderModel task) {
    final contact = [
      if (task.managerEmail?.isNotEmpty == true) task.managerEmail!,
      if (task.managerPhoneNumber?.isNotEmpty == true) task.managerPhoneNumber!,
    ].join("\n");

    if (contact.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: contact));

      Get.snackbar(
        "Copied",
        "Manager contact copied",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.chartPurple,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
    }
  }

  bool validateProposedTime(DateTime proposedDateTime, DateTime now) {
    if (!proposedDateTime.isAfter(now)) {
      Get.snackbar(
        'Invalid Time',
        'Proposed Hard Start Time must be in the future.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
