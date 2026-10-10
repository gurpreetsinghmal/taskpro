import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:taskpro/common/helpers/sow_image_compressor.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/common/models/sow_item_response_model.dart';
import 'package:taskpro/common/widgets/sow_item_response_details.dart';
import 'package:taskpro/modules/worker/tasks/w_tasks_screen.dart';
import 'package:taskpro/modules/worker/checkin/checkin_controller.dart';
import 'package:taskpro/modules/worker/checkin/checkin_screen.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_controller.dart';
import 'package:taskpro/modules/worker/profile/profile_controller.dart';
import 'package:taskpro/modules/worker/tasks/w_tasks_controller.dart';
import 'package:taskpro/services/local_data_service.dart';
import 'package:taskpro/services/secure_storage_service.dart';
import 'package:taskpro/services/storage_keys.dart';

class ControlledStorage extends FlutterSecureStorage {
  bool failNextWrite = false;
  Completer<void>? writeGate;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    await writeGate?.future;
    if (failNextWrite) {
      failNextWrite = false;
      throw StateError('disk unavailable');
    }
    await super.write(key: key, value: value);
  }
}

class TestCheckinController extends CheckinController {
  TestCheckinController({required super.task, required super.local});
  @override
  void getPositions() {} // Native location is outside this widget regression.
}

Map<String, dynamic> orderJson(int id, {String title = 'Install equipment'}) =>
    {
      'id': id,
      'work_order_no': 'WO-$id',
      'work_order_title': title,
      'status_id': 13,
      'status_name': 'Assigned',
      'sow_items': [
        {'id': id * 10, 'type': 'pre_install', 'status': 0},
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ControlledStorage platform;
  late SecureStorageService storage;
  late LocalDataService local;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({
      StorageKeys.workOrderList: jsonEncode([orderJson(1), orderJson(2)]),
      StorageKeys.workerProfile: jsonEncode({'id': 1, 'first_name': 'Ana'}),
      StorageKeys.workOrderStatusesList: jsonEncode([
        {'id': 13, 'name': 'Assigned', 'colour': 'Blue'},
      ]),
    });
    platform = ControlledStorage();
    storage = SecureStorageService(storage: platform);
    local = LocalDataService(storage: storage);
    await local.initialize();
  });
  tearDown(() {
    local.onClose();
  });

  test(
    'hydrates typed cache and publishes successful writes before returning',
    () async {
      expect(local.workOrders.length, 2);
      expect(local.profile.value!.firstName, 'Ana');
      expect(local.statuses.single.name, 'Assigned');
      await storage.editWorkOrder(
        1,
        (order) => order.copyWith(workOrderTitle: 'Changed'),
      );
      expect(local.findOrder(1)!.workOrderTitle, 'Changed');
      expect((await storage.findThisWorkOrder(1))!.workOrderTitle, 'Changed');
    },
  );

  test('does not publish a write until persistence succeeds', () async {
    platform.writeGate = Completer<void>();
    final saving = storage.editWorkOrder(1, (order) => order.copyWith(sync: 0));
    await Future<void>.delayed(Duration.zero);
    expect(local.findOrder(1)!.sync, 1);
    platform.writeGate!.complete();
    await saving;
    expect(local.findOrder(1)!.sync, 0);
  });

  test(
    'failed writes leave the cache intact and subsequent writes recover',
    () async {
      platform.failNextWrite = true;
      await expectLater(
        storage.editWorkOrder(1, (order) => order.copyWith(sync: 0)),
        throwsStateError,
      );
      expect(local.findOrder(1)!.sync, 1);
      await storage.editWorkOrder(2, (order) => order.copyWith(sync: 0));
      expect(local.findOrder(2)!.sync, 0);
    },
  );

  test(
    'concurrent edits retain changes to different orders and different fields',
    () async {
      await Future.wait([
        storage.editWorkOrder(
          1,
          (order) => order.copyWith(workOrderTitle: 'Updated'),
        ),
        storage.editWorkOrder(2, (order) => order.copyWith(sync: 0)),
        storage.editWorkOrder(1, (order) => order.copyWith(sync: 0)),
      ]);
      expect(local.findOrder(1)!.workOrderTitle, 'Updated');
      expect(local.findOrder(1)!.sync, 0);
      expect(local.findOrder(2)!.sync, 0);
    },
  );

  test('missing orders are not inserted by edits', () async {
    await storage.editWorkOrder(404, (order) => order.copyWith(sync: 0));
    expect(local.workOrders.length, 2);
    expect(await storage.findThisWorkOrder(404), isNull);
  });

  test(
    'downloads preserve changes made in flight and pending offline work',
    () async {
      await storage.editWorkOrder(
        2,
        (order) => order.copyWith(
          sync: 0,
          sowItems: order.sowItems
              .map(
                (item) => item.copyWith(
                  status: 2,
                  remarks: 'Not applicable at this site.',
                ),
              )
              .toList(),
        ),
      );
      final snapshot = {
        for (final order in local.workOrders)
          order.id: jsonEncode(order.toJson()),
      };
      await storage.editWorkOrder(
        1,
        (order) => order.copyWith(workOrderTitle: 'Local edit'),
      );
      await storage.mergeDownloadedOrders([
        WorkOrderModel.fromJson(orderJson(1, title: 'Old server data')),
        WorkOrderModel.fromJson(orderJson(2, title: 'New server data')),
      ], snapshot: snapshot);
      expect(local.findOrder(1)!.workOrderTitle, 'Local edit');
      expect(local.findOrder(2)!.sync, 0);
      expect(local.findOrder(2)!.workOrderTitle, 'New server data');
      expect(local.findOrder(2)!.sowItems.single.status, 2);
      expect(
        local.findOrder(2)!.sowItems.single.remarks,
        'Not applicable at this site.',
      );
    },
  );

  test(
    'downloads still replace unchanged local orders and remove deleted orders',
    () async {
      final snapshot = {
        for (final order in local.workOrders)
          order.id: jsonEncode(order.toJson()),
      };
      await storage.mergeDownloadedOrders([
        WorkOrderModel.fromJson(orderJson(1, title: 'Server update')),
      ], snapshot: snapshot);
      expect(local.workOrders.single.workOrderTitle, 'Server update');
    },
  );

  test('deletion clears every observed collection and profile', () async {
    await storage.write(
      StorageKeys.dashboardStats,
      '{"assigned_work_orders_count":2}',
    );
    await storage.delete(StorageKeys.workerProfile);
    expect(local.profile.value, isNull);
    await storage.deleteAll();
    expect(local.workOrders, isEmpty);
    expect(local.statuses, isEmpty);
    expect(local.dashboardStats, isEmpty);
  });

  test('malformed cache does not stop other keys from loading', () async {
    await storage.write(StorageKeys.workerProfile, 'invalid json');
    await storage.write(StorageKeys.workOrderList, jsonEncode([orderJson(3)]));
    expect(local.workOrders.single.id, 3);
    expect(local.profile.value!.firstName, 'Ana');
  });

  test('a reload overlapping a write cannot leave stale data', () async {
    await Future.wait([
      local.reload(),
      storage.write(StorageKeys.workerProfile, '{"id":1,"first_name":"New"}'),
    ]);
    expect(local.profile.value!.firstName, 'New');
  });

  test('reload reads changes made outside the foreground service', () async {
    await platform.write(
      key: StorageKeys.workOrderList,
      value: jsonEncode([orderJson(5)]),
    );
    await local.reload();
    expect(local.workOrders.single.id, 5);
  });

  test(
    'tasks and completion controllers observe the same committed edits',
    () async {
      final tasks = WorkerTasksController(local: local)..onInit();
      final completion = TaskCompletionController(
        task: local.findOrder(1)!,
        local: local,
      )..onInit();
      await tasks.getTasksData();
      await completion.saveSowItemResponse(
        const SowItemResponseModel(
          sowItemId: 10,
          status: SowItemResponseStatus.completed,
          comments: 'Installed and tested.',
        ),
      );
      expect(tasks.workOrderList.first.sowItems.first.status, 1);
      expect(
        tasks.workOrderList.first.sowItems.first.remarks,
        'Installed and tested.',
      );
      expect(completion.sowItems.first.status, 1);
      expect(completion.isSowItemResolved(completion.sowItems.first), isTrue);
      expect(tasks.workOrderList.first.sync, 0);
      expect(
        (await storage.findThisWorkOrder(1))!.toJson()['sow_items'],
        isA<List<dynamic>>(),
      );
      await storage.editWorkOrder(
        1,
        (order) => order.copyWith(proposedDatetimeAcceptedByManager: 2),
      );
      expect(tasks.hardStartChangeStatus[1], 2);
      await storage.deleteAll();
      expect(tasks.hardStartChangeStatus, isEmpty);
      expect(tasks.CheckinStatus, isEmpty);
      expect(completion.sowItems, isEmpty);
      tasks.onClose();
      completion.onClose();
    },
  );

  test(
    'SOW submission includes comments and image base64 for completed items',
    () async {
      final completion = TaskCompletionController(
        task: local.findOrder(1)!,
        local: local,
      )..onInit();
      final directory = await Directory.systemTemp.createTemp();
      final image = File('${directory.path}${Platform.pathSeparator}proof.jpg');
      await image.writeAsBytes([1, 2, 3, 4]);

      await completion.saveSowItemResponse(
        SowItemResponseModel(
          sowItemId: 10,
          status: SowItemResponseStatus.completed,
          comments: 'Installed and tested.',
          images: [
            SowAttachmentModel(
              id: 0,
              workOrderId: 0,
              sowItemId: 10,
              disk: 'Gallery',
              filePath: image.path,
              originalName: 'proof.jpg',
              mimeType: '',
              fileSize: 4,
            ),
          ],
        ),
      );

      expect(await completion.buildSowItemsSubmission(), [
        {
          'id': 10,
          'status': 1,
          'comments': 'Installed and tested.',
          'images': [
            base64Encode([1, 2, 3, 4]),
          ],
        },
      ]);
      final savedOrder = await storage.findThisWorkOrder(1);
      expect(savedOrder!.sowItems.single.remarks, 'Installed and tested.');
      expect(
        savedOrder.toJson()['sow_items'][0]['remarks'],
        'Installed and tested.',
      );
      expect(
        savedOrder.sowItems.single.attachments.single.filePath,
        image.path,
      );

      completion.onClose();
      await directory.delete(recursive: true);
    },
  );

  test(
    'not-applicable responses and evidence persist in the work order',
    () async {
      final completion = TaskCompletionController(
        task: local.findOrder(1)!,
        local: local,
      )..onInit();
      await completion.saveSowItemResponse(
        const SowItemResponseModel(
          sowItemId: 10,
          status: SowItemResponseStatus.notApplicable,
          comments: 'This equipment is not installed at this site.',
          images: [
            SowAttachmentModel(
              id: 0,
              workOrderId: 0,
              sowItemId: 10,
              disk: 'Gallery',
              filePath: '/local/evidence.jpg',
              originalName: 'evidence.jpg',
              mimeType: '',
              fileSize: 1024,
            ),
          ],
        ),
      );

      expect(
        completion.isSowItemNotApplicable(completion.sowItems.first),
        isTrue,
      );
      expect(completion.isSowItemResolved(completion.sowItems.first), isTrue);
      expect(await completion.buildSowItemsSubmission(), isEmpty);

      final savedOrder = await storage.findThisWorkOrder(1);
      final saved = savedOrder!.sowItems.single;
      expect(saved.status, 2);
      expect(saved.remarks, 'This equipment is not installed at this site.');
      expect(saved.attachments.single.filePath, '/local/evidence.jpg');
      expect(savedOrder.sync, 0);
      final sowItemJson = savedOrder.toJson()['sow_items'][0];
      expect(sowItemJson['status'], 2);
      expect(
        sowItemJson['remarks'],
        'This equipment is not installed at this site.',
      );
      expect(
        (sowItemJson['attachments'] as List).single['file_path'],
        '/local/evidence.jpg',
      );
      completion.onClose();
    },
  );

  testWidgets('SOW response details render remarks and image labels', (
    tester,
  ) async {
    final item = SowItemModel(
      id: 10,
      workOrderId: 1,
      type: 'pre_install',
      sortOrder: 1,
      description: 'Inspect equipment.',
      status: 2,
      remarks: 'Not present at site.',
      attachments: const [
        SowAttachmentModel(
          id: 1,
          workOrderId: 1,
          sowItemId: 10,
          disk: '',
          filePath: 'AA==',
          originalName: 'evidence.jpg',
          mimeType: 'image/jpeg',
          fileSize: 1,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SowItemResponseDetails(item: item)),
      ),
    );

    expect(find.text('Not present at site.'), findsOneWidget);
    expect(find.text('evidence.jpg'), findsOneWidget);
  });

  test('SOW image compression outputs a valid image no larger than 150 KB', () {
    final random = Random(12);
    final source = img.Image(width: 1024, height: 1024);
    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        source.setPixelRgb(
          x,
          y,
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );
      }
    }
    final sourceBytes = img.encodePng(source);
    expect(sourceBytes.length, greaterThan(maxSowImageBytes));

    final compressed = compressSowImage(sourceBytes);

    expect(compressed.length, lessThanOrEqualTo(maxSowImageBytes));
    expect(img.decodeImage(compressed), isNotNull);
  });

  test('SOW image compression fills transparent pixels with white', () {
    final transparent = img.Image(width: 1, height: 1, numChannels: 4);
    final compressed = compressSowImage(img.encodePng(transparent));
    final pixel = img.decodeImage(compressed)!.getPixel(0, 0);

    expect(pixel.r, greaterThan(240));
    expect(pixel.g, greaterThan(240));
    expect(pixel.b, greaterThan(240));
  });

  test('profile refresh preserves a draft until editing is canceled', () async {
    final profile = WorkerProfileController(local: local)..onInit();
    await profile.loadProfileFromStorage();
    profile.toggleEditMode();
    profile.firstNameController.text = 'Draft';
    await storage.write(
      StorageKeys.workerProfile,
      '{"id":1,"first_name":"Server"}',
    );
    expect(profile.user.value!.firstName, 'Server');
    expect(profile.firstNameController.text, 'Draft');
    profile.toggleEditMode();
    expect(profile.firstNameController.text, 'Server');
    profile.onClose();
  });

  testWidgets('mounted observer refreshes on a local save without navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Obx(() => Text(local.workOrders.first.workOrderTitle)),
        ),
      ),
    );
    final snapshot = {
      for (final order in local.workOrders)
        order.id: jsonEncode(order.toJson()),
    };
    await storage.editWorkOrder(
      1,
      (order) => order.copyWith(workOrderTitle: 'Local edit'),
    );
    expect(find.text('Install equipment'), findsOneWidget);
    await tester.runAsync(
      () => storage.editWorkOrder(
        1,
        (order) => order.copyWith(workOrderTitle: 'Saved locally'),
      ),
    );
    await tester.pump();
    expect(find.text('Saved locally'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tasks screen preserves search and refreshes an existing card', (
    tester,
  ) async {
    Get.testMode = true;
    late WorkerTasksController tasks;
    await tester.runAsync(() async {
      tasks = Get.put(WorkerTasksController(local: local));
      await tasks.getTasksData();
    });
    await tester.pumpWidget(const GetMaterialApp(home: WorkerTasksScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField), 'WO-1');
    await tester.pump();
    expect(tasks.filteredTasks.single.id, 1);
    await tester.runAsync(
      () => storage.editWorkOrder(
        1,
        (order) => order.copyWith(workOrderTitle: 'Changed while viewing'),
      ),
    );
    await tester.pump();
    expect(find.text('Changed while viewing'), findsOneWidget);
    expect(tasks.searchController.text, 'WO-1');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
  });

  testWidgets('open check-in screen follows local order changes', (
    tester,
  ) async {
    Get.testMode = true;
    await tester.runAsync(() async {
      Get.put<CheckinController>(
        TestCheckinController(task: local.findOrder(1)!, local: local),
      );
      await local.initialize();
    });
    await tester.pumpWidget(const GetMaterialApp(home: CheckInScreen()));
    await tester.runAsync(
      () => storage.editWorkOrder(
        1,
        (order) => order.copyWith(workOrderNo: 'WO-UPDATED'),
      ),
    );
    await tester.pump();
    expect(find.text('WO-UPDATED'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.reset();
  });
}
