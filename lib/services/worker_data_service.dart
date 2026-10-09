import 'dart:convert';
import '../common/helpers/api_routes.dart';
import '../common/models/work_order_model.dart';
import '../network/api_exception.dart';
import '../network/api_service.dart';
import 'local_data_service.dart';
import 'storage_keys.dart';

/// API-to-cache coordination. Controllers own loading state and messages.
class WorkerDataService {
  WorkerDataService({ApiService? api, LocalDataService? local})
    : api = api ?? ApiService(),
      local = local ?? LocalDataService.instance;
  static Future<Map<int, String>>? _pendingSync;

  final ApiService api;
  final LocalDataService local;

  Future<void> loadProfile() async {
    final response = await api.get(ApiRoutes.fetchProfile);
    final data = response.data;
    if (data != null &&
        data['user'] != null &&
        data['success'].toString() == 'true') {
      await local.storage.write(
        StorageKeys.workerProfile,
        jsonEncode(data['user']),
      );
    }
  }

  Future<void> loadStatuses() async {
    final response = await api.post(ApiRoutes.workOrderStatusesList);
    final data = response.data;
    if (data != null &&
        data['data'] != null &&
        data['status'].toString() == 'true') {
      await local.storage.write(
        StorageKeys.workOrderStatusesList,
        jsonEncode(data['data']),
      );
    }
  }

  Future<void> loadOrders() async {
    final snapshot = {
      for (final order in local.workOrders)
        order.id: jsonEncode(order.toJson()),
    };
    final response = await api.post(ApiRoutes.workOrderList);
    final data = response.data;
    if (data != null &&
        data['data'] != null &&
        data['status'].toString() == 'success') {
      await local.storage.mergeDownloadedOrders(
        (data['data'] as List)
            .map(
              (item) => WorkOrderModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        snapshot: snapshot,
      );
    }
  }

  Future<String?> loadDashboardStats() async {
    final response = await api.get(ApiRoutes.dashboardStats);
    if (response.data['success'] != true) {
      return response.data['message'] ?? 'Unknown error';
    }
    final stats = response.data['data'];
    if (stats != null) {
      await local.storage.write(StorageKeys.dashboardStats, jsonEncode(stats));
    }
    return null;
  }

  Future<bool> syncOrder(WorkOrderModel task) async {
    return await syncOrderFailure(task) == null;
  }

  Future<String?> syncOrderFailure(WorkOrderModel task) async {
    try {
      final checkinsResponse = await api.post(
        ApiRoutes.workOrderCheckInSync,
        data: {
          'work_order_id': task.id,
          'checkins': task.checkins.map((item) => item.toJson()).toList(),
        },
      );
      final syncedCount = checkinsResponse.data is Map
          ? int.tryParse(
              checkinsResponse.data['synced_count']?.toString() ?? '',
            )
          : null;
      final hasCheckinResult =
          checkinsResponse.data is Map &&
          (checkinsResponse.data.containsKey('success') ||
              checkinsResponse.data.containsKey('status'));
      final checkinsSucceeded = hasCheckinResult
          ? _successful(checkinsResponse.data)
          : syncedCount == task.checkins.length;
      if (!checkinsSucceeded || syncedCount != task.checkins.length) {
        final details = _formatCheckinErrors(
          checkinsResponse.data,
          task.checkins,
        );
        if (details.isNotEmpty) return details.join('\n');
        final reference = task.checkins.isEmpty
            ? 'No local check-in sessions were available.'
            : 'The server did not identify which session failed. '
                  'Pending session references: ${task.checkins.map(_sessionReference).join('; ')}.';
        return 'Check-ins: ${_responseMessage(checkinsResponse.data) ?? 'The server synced ${syncedCount ?? 0} of ${task.checkins.length} updates.'} $reference';
      }
    } on ApiException catch (error) {
      final details = _formatCheckinErrors(error.data, task.checkins);
      return details.isNotEmpty
          ? details.join('\n')
          : 'Check-ins: ${error.message}. ${task.checkins.map(_sessionReference).join('; ')}';
    } on Exception catch (error) {
      return 'Check-ins: $error';
    }

    try {
      final sowResponse = await api.post(
        ApiRoutes.workOrderSowItemsSync,
        data: {
          'work_order_id': task.id,
          'sow_items': task.sowItems
              .map((item) => {'id': item.id, 'status': item.status})
              .toList(),
        },
      );
      if (!_successful(sowResponse.data)) {
        final details = _formatSowErrors(sowResponse.data, task);
        if (details.isNotEmpty) return details.join('\n');
        return 'SOW items: ${_responseMessage(sowResponse.data) ?? 'The server rejected the update.'}';
      }
    } on ApiException catch (error) {
      final details = _formatSowErrors(error.data, task);
      return details.isNotEmpty
          ? details.join('\n')
          : 'SOW items: ${error.message}';
    } on Exception catch (error) {
      return 'SOW items: $error';
    }

    try {
      final workOrderFields = task.toJson()
        ..remove('checkins')
        ..remove('sow_items')
        ..remove('sync')
        ..remove('id');
      final fieldsResponse = await api.post(
        ApiRoutes.workOrderFieldsSync,
        data: {'work_order_id': task.id, 'work_order': workOrderFields},
      );
      if (!_successful(fieldsResponse.data)) {
        final details = _formatFieldErrors(fieldsResponse.data);
        if (details.isNotEmpty) return details.join('\n');
        return 'Work-order details: ${_responseMessage(fieldsResponse.data) ?? 'The server rejected the update.'}';
      }
    } on ApiException catch (error) {
      final details = _formatFieldErrors(error.data);
      return details.isNotEmpty
          ? details.join('\n')
          : 'Work-order details: ${error.message}';
    } on Exception catch (error) {
      return 'Work-order details: $error';
    }
    return null;
  }

  Future<Map<int, String>> syncPendingOrders() async {
    final activeSync = _pendingSync;
    if (activeSync != null) return activeSync;

    final sync = _syncPendingOrders();
    _pendingSync = sync;
    try {
      return await sync;
    } finally {
      if (identical(_pendingSync, sync)) _pendingSync = null;
    }
  }

  Future<Map<int, String>> _syncPendingOrders() async {
    final orders = await local.storage.getWorkOrderList();
    if (orders == null) return {};
    final pendingOrders = orders.where((order) => order.sync == 0);
    if (!await api.checkInternet()) {
      final failures = <int, String>{};
      for (final order in pendingOrders) {
        const failure = 'No internet connection. The order is waiting to sync.';
        failures[order.id] = failure;
        await _saveSyncFailure(order.id, failure);
      }
      return failures;
    }

    final failures = <int, String>{};
    for (final task in pendingOrders) {
      final failure = await syncOrderFailure(task);
      if (failure == null) {
        await local.storage.editWorkOrder(task.id, (current) {
          if (jsonEncode(_syncData(current)) != jsonEncode(_syncData(task))) {
            return current;
          }
          return current.copyWith(
            sync: 1,
            syncErrors: current.syncErrors
                .where((error) => error.startsWith('Photo upload:'))
                .toList(),
          );
        });
      } else {
        failures[task.id] = failure;
        await _saveSyncFailure(task.id, failure);
      }
    }
    return failures;
  }

  String? _responseMessage(dynamic response) {
    if (response is! Map) return null;
    final message = response['message'] ?? response['error'];
    if (message == null || message.toString().trim().isEmpty) return null;
    return message.toString();
  }

  Future<void> savePhotoUploadFailure(int workOrderId, String failure) =>
      local.storage.editWorkOrder(workOrderId, (current) {
        final retained = current.syncErrors
            .where((error) => !error.startsWith('Photo upload:'))
            .toList();
        return current.copyWith(syncErrors: [...retained, failure]);
      });

  Future<void> clearPhotoUploadFailures(int workOrderId) =>
      local.storage.editWorkOrder(workOrderId, (current) {
        return current.copyWith(
          syncErrors: current.syncErrors
              .where((error) => !error.startsWith('Photo upload:'))
              .toList(),
        );
      });

  Future<void> _saveSyncFailure(int workOrderId, String failure) =>
      local.storage.editWorkOrder(workOrderId, (current) {
        final retained = current.syncErrors
            .where((error) => error.startsWith('Photo upload:'))
            .toList();
        return current.copyWith(syncErrors: [...retained, failure]);
      });

  Map<String, dynamic> _syncData(WorkOrderModel order) => order.toJson()
    ..remove('sync')
    ..remove('sync_errors');

  List<String> _formatCheckinErrors(dynamic response, List<dynamic> sessions) {
    final errors = _validationErrors(response);
    final details = <String>[];
    final indexedKey = RegExp(r'^checkins?(?:\.|\[)(\d+)(?:\]|\.)?\.?(.*)$');
    for (final entry in errors.entries) {
      final match = indexedKey.firstMatch(entry.key);
      if (match == null) continue;
      final index = int.tryParse(match.group(1)!);
      final session = index != null && index >= 0 && index < sessions.length
          ? sessions[index]
          : null;
      final field = match.group(2)?.replaceAll('].', '.') ?? '';
      final category =
          field.toLowerCase().startsWith('checkout') ||
              field.toLowerCase().startsWith('check_out')
          ? 'Check-out'
          : 'Check-in';
      final reference = session == null
          ? 'session index ${index ?? match.group(1)}'
          : _sessionReference(session);
      details.add(
        '$category $reference${field.isEmpty ? '' : ' · $field'}: ${entry.value}',
      );
    }
    return details;
  }

  List<String> _formatSowErrors(dynamic response, WorkOrderModel task) {
    final errors = _validationErrors(response);
    final details = <String>[];
    final indexedKey = RegExp(r'^sow_items?(?:\.|\[)(\d+)(?:\]|\.)?\.?(.*)$');
    for (final entry in errors.entries) {
      final match = indexedKey.firstMatch(entry.key);
      if (match == null) continue;
      final index = int.tryParse(match.group(1)!);
      final item = index != null && index >= 0 && index < task.sowItems.length
          ? task.sowItems[index]
          : null;
      final reference = item == null
          ? 'SOW item index ${index ?? match.group(1)}'
          : 'SOW item #${item.id} (${item.type}: ${item.description})';
      final field = match.group(2)?.replaceAll('].', '.') ?? '';
      details.add(
        '$reference${field.isEmpty ? '' : ' · $field'}: ${entry.value}',
      );
    }
    return details;
  }

  List<String> _formatFieldErrors(dynamic response) {
    return _validationErrors(response).entries.map((entry) {
      final field = entry.key.replaceFirst(
        RegExp(r'^(work_order|workOrder)\.'),
        '',
      );
      return 'Work-order field "$field": ${entry.value}';
    }).toList();
  }

  Map<String, String> _validationErrors(dynamic response) {
    if (response is! Map) return const {};
    dynamic errors = response['errors'];
    if (errors is! Map && response['data'] is Map) {
      errors = response['data']['errors'];
    }
    if (errors is! Map) return const {};
    return {
      for (final entry in errors.entries)
        entry.key.toString(): _errorText(entry.value),
    };
  }

  String _errorText(dynamic value) {
    if (value is List) return value.map(_errorText).join('; ');
    if (value is Map) {
      return value.entries
          .map((entry) => '${entry.key}: ${_errorText(entry.value)}')
          .join('; ');
    }
    return value?.toString() ?? 'Rejected by the server';
  }

  String _sessionReference(dynamic session) {
    final id = session.id == null ? 'local session' : 'session #${session.id}';
    final date = session.checkOutDateTime ?? session.checkInDateTime;
    return '$id${date == null ? '' : ' (${date.toIso8601String()})'}';
  }

  bool _successful(dynamic response) {
    if (response is! Map) return false;
    final success = response['success'] ?? response['status'];
    if (success == null) return false;
    return success == true ||
        success.toString().toLowerCase() == 'true' ||
        success.toString().toLowerCase() == 'success';
  }
}
