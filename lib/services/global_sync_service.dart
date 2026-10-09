import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:taskpro/services/worker_data_service.dart';

class SyncService extends GetxService with WidgetsBindingObserver {
  SyncService({WorkerDataService? workerDataService})
    : _workerDataService = workerDataService ?? WorkerDataService();

  final WorkerDataService _workerDataService;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;
  bool _syncRequested = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _subscription = Connectivity().onConnectivityChanged.listen(
      (results) {
        if (results.any((result) => result != ConnectivityResult.none)) {
          unawaited(syncData());
        }
      },
      onError: (Object error) {
        debugPrint('Unable to monitor connectivity changes: $error');
      },
    );
    unawaited(checkAndSync());
  }

  Future<void> checkAndSync() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.any((result) => result != ConnectivityResult.none)) {
        await syncData();
      }
    } catch (error) {
      debugPrint('Unable to check connectivity: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(checkAndSync());
    }
  }

  Future<void> syncData() async {
    if (_isSyncing) {
      _syncRequested = true;
      return;
    }

    _isSyncing = true;
    try {
      if (!await _workerDataService.api.checkInternet() ||
          !await _workerDataService.local.storage.isLoggedIn()) {
        return;
      }

      final failures = await _workerDataService.syncPendingOrders();
      if (failures.isNotEmpty) {
        debugPrint('Some pending work orders could not be synced: $failures');
      }
    } catch (error) {
      debugPrint('Sync failed: $error');
    } finally {
      _isSyncing = false;
      if (_syncRequested) {
        _syncRequested = false;
        unawaited(syncData());
      }
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
