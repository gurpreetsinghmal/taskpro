import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../common/models/work_order_model.dart';
import '../common/models/work_order_status.dart';
import '../modules/worker/profile/profile_model.dart';
import 'secure_storage_service.dart';
import 'storage_keys.dart';

/// Shared local source of truth. Observers update after persistence succeeds,
/// before the write future completes; no network call or polling is required.
class LocalDataService extends GetxService with WidgetsBindingObserver {
  LocalDataService({SecureStorageService? storage})
    : storage = storage ?? SecureStorageService.instance;
  static final instance = LocalDataService();
  final SecureStorageService storage;
  final workOrders = <WorkOrderModel>[].obs;
  final statuses = <WorkOrderStatusModel>[].obs;
  final profile = Rxn<WorkerProfileModel>();
  final dashboardStats = <String, dynamic>{}.obs;
  final _revisions = <String, int>{};
  StreamSubscription<StorageChange>? _subscription;
  Future<void>? _initialization;
  bool _closed = false;
  static const _keys = [
    StorageKeys.workOrderList,
    StorageKeys.workOrderStatusesList,
    StorageKeys.workerProfile,
    StorageKeys.dashboardStats,
  ];

  Future<void> initialize() => _initialization ??= _initialize();
  Future<void> _initialize() async {
    _subscription = storage.changes.listen((change) {
      final keys = change.key == null ? _keys : [change.key!];
      for (final key in keys) {
        _revisions[key] = (_revisions[key] ?? 0) + 1;
        _apply(key, change.value);
      }
    });
    WidgetsBinding.instance.addObserver(this);
    await reload();
  }

  Future<void> reload() async {
    for (final key in _keys) {
      final revision = _revisions[key] ?? 0;
      final value = await storage.read(key);
      if (!_closed && revision == (_revisions[key] ?? 0)) _apply(key, value);
    }
  }

  void _apply(String key, String? value) {
    try {
      switch (key) {
        case StorageKeys.workOrderList:
          workOrders.assignAll(
            value == null
                ? <WorkOrderModel>[]
                : (jsonDecode(value) as List)
                      .map(
                        (item) => WorkOrderModel.fromJson(
                          item as Map<String, dynamic>,
                        ),
                      )
                      .toList(),
          );
        case StorageKeys.workOrderStatusesList:
          statuses.assignAll(
            value == null
                ? <WorkOrderStatusModel>[]
                : (jsonDecode(value) as List)
                      .map(
                        (item) => WorkOrderStatusModel.fromJson(
                          item as Map<String, dynamic>,
                        ),
                      )
                      .toList(),
          );
        case StorageKeys.workerProfile:
          profile.value = value == null
              ? null
              : WorkerProfileModel.fromJson(
                  jsonDecode(value) as Map<String, dynamic>,
                );
        case StorageKeys.dashboardStats:
          dashboardStats.assignAll(
            value == null
                ? <String, dynamic>{}
                : jsonDecode(value) as Map<String, dynamic>,
          );
      }
    } catch (error) {
      debugPrint('Unable to decode local $key: $error');
    }
  }

  WorkOrderModel? findOrder(int id) {
    for (final order in workOrders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> saveProfile(WorkerProfileModel value) =>
      storage.write(StorageKeys.workerProfile, jsonEncode(value.toJson()));
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        reload().catchError((Object error) {
          debugPrint('Unable to reload local data: $error');
        }),
      );
    }
  }

  @override
  void onClose() {
    _closed = true;
    _subscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
