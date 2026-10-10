import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../common/models/work_order_model.dart';
import 'storage_keys.dart';

/// A committed mutation. A null key means all data was deleted.
class StorageChange {
  const StorageChange(this.key, this.value);
  final String? key;
  final String? value;
}

/// Persistence only; navigation and presentation belong to controllers/screens.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(),
          );
  static final instance = SecureStorageService();
  final FlutterSecureStorage _storage;
  final _changes = StreamController<StorageChange>.broadcast(sync: true);
  Future<void> _pending = Future<void>.value();
  Stream<StorageChange> get changes => _changes.stream;

  // Serialize read/modify/write operations to prevent lost concurrent edits.
  Future<T> _serialized<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<void> _write(String key, String value) async {
    await _storage.write(key: key, value: value);
    _changes.add(StorageChange(key, value));
  }

  Future<void> write(String key, String value) =>
      _serialized(() => _write(key, value));
  Future<String?> read(String key) =>
      _serialized(() => _storage.read(key: key));
  Future<void> delete(String key) => _serialized(() async {
    await _storage.delete(key: key);
    _changes.add(StorageChange(key, null));
  });
  Future<void> deleteAll() => _serialized(() async {
    await _storage.deleteAll();
    _changes.add(const StorageChange(null, null));
  });
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() => read(StorageKeys.accessToken);
  List<WorkOrderModel>? _decodeOrders(String? value) => value == null
      ? null
      : (jsonDecode(value) as List)
            .map(
              (item) => WorkOrderModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
  Future<List<WorkOrderModel>?> getWorkOrderList() async =>
      _decodeOrders(await read(StorageKeys.workOrderList));
  Future<void> updateWorkOrderData(WorkOrderModel order) =>
      editWorkOrder(order.id, (_) => order);

  /// Merge a download without erasing pending sessions or edits made while the
  /// request was in flight. The snapshot contains serialized orders at start.
  Future<void> mergeDownloadedOrders(
    List<WorkOrderModel> downloaded, {
    required Map<int, String> snapshot,
  }) => _serialized(() async {
    final current =
        _decodeOrders(await _storage.read(key: StorageKeys.workOrderList)) ??
        [];
    final byId = {for (final order in current) order.id: order};
    final merged = downloaded.map((remote) {
      final saved = byId.remove(remote.id);
      if (saved == null) return remote;
      if (snapshot[saved.id] != jsonEncode(saved.toJson())) return saved;
      if (saved.sync == 0) {
        return remote.copyWith(
          checkins: saved.checkins,
          sowItems: saved.sowItems,
          sync: 0,
          syncErrors: saved.syncErrors,
        );
      }
      return saved.syncErrors.isEmpty
          ? remote
          : remote.copyWith(syncErrors: saved.syncErrors);
    }).toList();
    merged.addAll(
      byId.values.where(
        (order) =>
            order.sync == 0 || snapshot[order.id] != jsonEncode(order.toJson()),
      ),
    );
    await _write(
      StorageKeys.workOrderList,
      jsonEncode(merged.map((order) => order.toJson()).toList()),
    );
  });

  /// Apply field changes to the latest stored order, not an old screen snapshot.
  Future<void> editWorkOrder(
    int id,
    WorkOrderModel Function(WorkOrderModel) edit,
  ) => _serialized(() async {
    final orders = _decodeOrders(
      await _storage.read(key: StorageKeys.workOrderList),
    );
    if (orders == null) return;
    final index = orders.indexWhere((order) => order.id == id);
    if (index == -1) return;
    orders[index] = edit(orders[index]);
    await _write(
      StorageKeys.workOrderList,
      jsonEncode(orders.map((order) => order.toJson()).toList()),
    );
  });
  Future<WorkOrderModel?> findThisWorkOrder(int id) async {
    for (final order in await getWorkOrderList() ?? <WorkOrderModel>[]) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<int?> isAlreadyCheckIn() async {
    for (final order in await getWorkOrderList() ?? <WorkOrderModel>[]) {
      if (order.checkins.any((session) => session.isActive)) return order.id;
    }
    return null;
  }
}
