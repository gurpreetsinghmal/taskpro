import '../../../common/models/work_order_status.dart';
import '../profile/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/models/work_order_model.dart';
import '../../../services/local_data_service.dart';
import '../../../services/worker_data_service.dart';
import '../../../theme/app_colors.dart';
import '../../login/session_controller.dart';

class WorkerDashboardController extends GetxController {
  WorkerDashboardController({LocalDataService? local, WorkerDataService? data})
    : local = local ?? LocalDataService.instance,
      _data = data ?? WorkerDataService(local: local);
  final LocalDataService local;
  final WorkerDataService _data;
  final isApiLoading = false.obs;
  final walletBalance = 320.00.obs;
  final syncStatus = true.obs;
  final syncFailures = <int, String>{}.obs;
  final pendingCount = 0.obs;
  final inProgressCount = 0.obs;
  final completedCount = 0.obs;
  final assignedCount = 0.obs;
  final todayCompletedCount = 0.obs;
  final List<Worker> _workers = [];
  Future<void>? _refresh;

  Rxn<WorkerProfileModel> get user => local.profile;
  RxList<WorkOrderModel> get workOrderList => local.workOrders;
  RxList<WorkOrderStatusModel> get workOrderStatusList => local.statuses;

  void withdrawWallet(double amount) {
    if (walletBalance.value >= amount) walletBalance.value -= amount;
  }

  Future<void> logout() => Get.find<SessionController>().logout();

  @override
  void onInit() {
    super.onInit();
    _workers.add(ever(local.workOrders, (_) => _updateSyncStatus()));
    _workers.add(ever(local.dashboardStats, (_) => _updateStats()));
    _updateStats();
    _updateSyncStatus();
    getdata();
  }

  void _updateSyncStatus() {
    syncStatus.value = !local.workOrders.any(
      (order) => order.sync == 0 || order.syncErrors.isNotEmpty,
    );
  }

  void _updateStats() {
    final stats = local.dashboardStats;
    completedCount.value = stats['completed_work_orders_count'] ?? 0;
    assignedCount.value = stats['assigned_work_orders_count'] ?? 0;
    inProgressCount.value = stats['in_progress_work_orders_count'] ?? 0;
    pendingCount.value = stats['pending_approval_count'] ?? 0;
  }

  Future<void> getdata() =>
      _refresh ??= _load().whenComplete(() => _refresh = null);
  Future<void> _load() async {
    // Render cached data before checking connectivity or making API requests.
    await local.initialize();
    await fetchOfflineData();
    await fetchSyncStatus();
    if (await _data.api.checkInternet()) await fetchOnlineApis();
  }

  Future<void> fetchSyncStatus() async {
    try {
      syncFailures.assignAll(await _data.syncPendingOrders());
    } catch (error) {
      debugPrint('Unable to sync pending work orders: $error');
      syncFailures.assignAll({
        for (final order in local.workOrders.where((order) => order.sync == 0))
          order.id: 'Unable to sync this work order: $error',
      });
    }
    _updateSyncStatus();
  }

  Future<bool> hitOnlineSyncApi(WorkOrderModel task) async {
    try {
      return await _data.syncOrder(task);
    } catch (error) {
      debugPrint('Sync WorkOrder Error: $error');
      return false;
    }
  }

  Future<void> fetchOnlineApis() async {
    isApiLoading.value = true;
    try {
      await Future.wait([loadProfileFromApi(), getDashboardData()]);
      await loadWorkOrderStatusListFromApi();
      await loadWorkOrderListFromApi();
    } finally {
      isApiLoading.value = false;
    }
  }

  Future<void> _safely(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('Worker data error: $error');
    }
  }

  Future<void> loadProfileFromApi() => _safely(_data.loadProfile);
  Future<void> loadWorkOrderStatusListFromApi() => _safely(_data.loadStatuses);
  Future<void> loadWorkOrderListFromApi() => _safely(_data.loadOrders);
  Future<void> getDashboardData() => _safely(() async {
    final message = await _data.loadDashboardStats();
    if (message != null) {
      Get.snackbar(
        'Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  });
  Future<void> fetchOfflineData() => local.reload();
  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }
}
