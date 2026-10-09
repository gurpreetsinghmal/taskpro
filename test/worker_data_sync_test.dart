import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/services/local_data_service.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';
import 'package:taskpro/services/worker_data_service.dart';

class OnlineApiService extends ApiService {
  OnlineApiService(Dio dio) : super(dio: dio);

  @override
  Future<bool> checkInternet() async => true;
}

WorkOrderModel _workOrder() => WorkOrderModel.fromJson({
  'id': 42,
  'work_order_no': 'WO-42',
  'work_order_title': 'Install equipment',
  'sow_items': [
    {'id': 420, 'type': 'pre_install', 'status': 1},
  ],
  'checkins': [
    {'id': 7, 'work_order_id': 42, 'checkin_datetime': '2026-10-09T09:00:00'},
  ],
  'sync': 0,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'syncs check-ins, SOW items, and work-order fields in sequence',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            final data = switch (options.path) {
              ApiRoutes.workOrderCheckInSync => {
                'status': true,
                'synced_count': 1,
              },
              _ => {'success': true},
            };
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: data),
            );
          },
        ),
      );
      final service = WorkerDataService(api: ApiService(dio: dio));

      expect(await service.syncOrder(_workOrder()), isTrue);
      expect(requests.map((request) => request.path), [
        ApiRoutes.workOrderCheckInSync,
        ApiRoutes.workOrderSowItemsSync,
        ApiRoutes.workOrderFieldsSync,
      ]);
      expect(requests[0].data['work_order_id'], 42);
      expect(requests[1].data['sow_items'], [
        {'id': 420, 'status': 1},
      ]);
      expect(requests[2].data['work_order_id'], 42);
      expect(requests[2].data['work_order'], isA<Map>());
      expect(requests[2].data['work_order'], isNot(contains('checkins')));
      expect(requests[2].data['work_order'], isNot(contains('sow_items')));
    },
  );

  test('stops sequence and reports failure when a step is rejected', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          final data = options.path == ApiRoutes.workOrderCheckInSync
              ? {'status': true, 'synced_count': 1}
              : {'success': false, 'message': 'SOW endpoint unavailable'};
          handler.resolve(
            Response(requestOptions: options, statusCode: 200, data: data),
          );
        },
      ),
    );
    final service = WorkerDataService(api: ApiService(dio: dio));

    expect(
      await service.syncOrderFailure(_workOrder()),
      'SOW items: SOW endpoint unavailable',
    );
    expect(requests.map((request) => request.path), [
      ApiRoutes.workOrderCheckInSync,
      ApiRoutes.workOrderSowItemsSync,
    ]);
  });

  test(
    'maps validation errors to the failed check-in session reference',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': false,
                  'synced_count': 0,
                  'errors': {
                    'checkins.0.checkin_latitude': ['Latitude is required'],
                  },
                },
              ),
            );
          },
        ),
      );
      final failure = await WorkerDataService(
        api: ApiService(dio: dio),
      ).syncOrderFailure(_workOrder());

      expect(failure, contains('Check-in session #7'));
      expect(failure, contains('checkin_latitude'));
      expect(failure, contains('Latitude is required'));
    },
  );

  test(
    'coalesces concurrent syncs and marks the order synced after success',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final local = LocalDataService(
        storage: SecureStorageService(storage: const FlutterSecureStorage()),
      );
      await local.initialize();
      await local.storage.write(
        StorageKeys.workOrderList,
        jsonEncode([_workOrder().toJson()]),
      );

      final requests = <String>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options.path);
            final data = options.path == ApiRoutes.workOrderCheckInSync
                ? {'status': true, 'synced_count': 1}
                : {'success': true};
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: data),
            );
          },
        ),
      );
      final service = WorkerDataService(
        api: OnlineApiService(dio),
        local: local,
      );

      await Future.wait([
        service.syncPendingOrders(),
        WorkerDataService(
          api: OnlineApiService(dio),
          local: local,
        ).syncPendingOrders(),
      ]);

      expect((await local.storage.findThisWorkOrder(42))?.sync, 1);
      expect(requests, [
        ApiRoutes.workOrderCheckInSync,
        ApiRoutes.workOrderSowItemsSync,
        ApiRoutes.workOrderFieldsSync,
      ]);
      local.onClose();
    },
  );

  test(
    'maps SOW and work-order errors to item and variable references',
    () async {
      final testCases = [
        (
          endpoint: ApiRoutes.workOrderSowItemsSync,
          errors: {
            'sow_items.0.status': ['Status is invalid'],
          },
          reference: 'SOW item #420 (pre_install:',
          reason: 'Status is invalid',
        ),
        (
          endpoint: ApiRoutes.workOrderFieldsSync,
          errors: {
            'work_order.status_id': ['Status is locked'],
          },
          reference: 'Work-order field "status_id"',
          reason: 'Status is locked',
        ),
      ];

      for (final testCase in testCases) {
        final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final data = options.path == ApiRoutes.workOrderCheckInSync
                  ? {'status': true, 'synced_count': 1}
                  : options.path == testCase.endpoint
                  ? {'success': false, 'errors': testCase.errors}
                  : {'success': true};
              handler.resolve(
                Response(requestOptions: options, statusCode: 200, data: data),
              );
            },
          ),
        );

        final failure = await WorkerDataService(
          api: ApiService(dio: dio),
        ).syncOrderFailure(_workOrder());

        expect(failure, contains(testCase.reference));
        expect(failure, contains(testCase.reason));
      }
    },
  );
}
