import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../services/local_data_service.dart';
import 'location_service.dart';

class LocationController extends GetxController {
  LocationController({LocalDataService? local})
    : local = local ?? LocalDataService.instance;
  final LocalDataService local;
  final isTracking = false.obs;
  Worker? _ordersWorker;
  Future<void> _trackingUpdates = Future<void>.value();

  @override
  void onInit() {
    super.onInit();
    _ordersWorker = ever(local.workOrders, (_) => _syncTracking());
    _syncTracking();
  }

  void _syncTracking() {
    _trackingUpdates = _trackingUpdates
        .then((_) async {
          final hasActiveSession = local.workOrders.any(
            (order) => order.checkins.any((session) => session.isActive),
          );
          if (hasActiveSession) {
            isTracking.value = await LocationService.start();
          } else {
            await LocationService.stop();
            isTracking.value = false;
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('Unable to update location tracking: $error');
          debugPrintStack(stackTrace: stackTrace);
        });
  }

  Future<void> startLocation() async {
    if (!await LocationService.requestLocationAccess()) {
      Get.snackbar('Location', 'Location permission required');
      return;
    }
    isTracking.value = await LocationService.start();
  }

  Future<void> stopLocation() async {
    await LocationService.stop();

    isTracking.value = false;
  }

  @override
  void onClose() {
    _ordersWorker?.dispose();
    super.onClose();
  }
}
