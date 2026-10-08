import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/network/api_service.dart';

class SyncService extends GetxService {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();

    _subscription = Connectivity().onConnectivityChanged.listen(
          (List<ConnectivityResult> results) async {
        final hasNetwork = results.any(
              (result) => result != ConnectivityResult.none,
        );

        if (hasNetwork) {
          await syncData();
        }
      },
    );

    // Also check when service starts
    checkAndSync();
  }

  Future<void> checkAndSync() async {
    final results = await Connectivity().checkConnectivity();

    final hasNetwork = results.any(
          (result) => result != ConnectivityResult.none,
    );

    if (hasNetwork) {
      await syncData();
    }
  }

  Future<bool> isServerAvailable() async {
    try {
      final api=ApiService();
      final response = await api.get(
        ApiRoutes.dashboardStats,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncData() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      if (!await isServerAvailable()) {
        return;
      }
      print("Internet available. Starting sync...");

      // 1. First upload pending offline data
      await uploadPendingData();

      // 2. Then download latest server data
      await downloadLatestData();

      print("Sync completed successfully.");
    } catch (e) {
      print("Sync failed: $e");
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> uploadPendingData() async {
    // Upload:
    // pending check-ins
    // pending check-outs
    // pending installation completion
    // pending photos
    // pending status changes
  }

  Future<void> downloadLatestData() async {
    // Call API
    // Save response to local storage
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}