import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_controller.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_models.dart';
import 'package:taskpro/services/local_data_service.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const pickerChannel = MethodChannel('plugins.flutter.io/image_picker');
  late Directory directory;
  late TaskCompletionController controller;
  late LocalDataService local;
  late List<String> selectedPaths;

  setUp(() async {
    directory = await Directory.current.createTemp('.sow_progress_test_');
    local = LocalDataService();
    controller = TaskCompletionController(
      task: WorkOrderModel.fromJson({'id': 42}),
      local: local,
    );
    selectedPaths = [];
    binding.defaultBinaryMessenger.setMockMethodCallHandler(pickerChannel, (
      call,
    ) async {
      expect(call.method, 'pickMultiImage');
      return selectedPaths;
    });
  });

  tearDown(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pickerChannel,
      null,
    );
    controller.onClose();
    local.onClose();
    await for (final file in directory.list()) {
      await file.delete();
    }
    await directory.delete();
  });

  Future<String> addImage(String name) async {
    final file = File('${directory.path}${Platform.pathSeparator}$name');
    await file.writeAsBytes(img.encodePng(img.Image(width: 2, height: 2)));
    selectedPaths.add(file.path);
    return file.path;
  }

  test('each image waits for its preview before reporting ready', () async {
    await addImage('first.png');
    await addImage('second.png');
    final previewStarted = Completer<void>();
    final releasePreview = Completer<void>();
    final snapshots = <List<SowImageProgress>>[];
    final readyNames = <String>[];

    final result = controller.pickSowItemImages(
      onProgress: snapshots.add,
      onImageReady: (image) async {
        if (readyNames.isEmpty) {
          previewStarted.complete();
          await releasePreview.future;
        }
        readyNames.add(image.originalName);
      },
    );
    await previewStarted.future;
    expect(
      snapshots.first.every((p) => p.stage == SowImageStage.queued),
      isTrue,
    );
    expect(snapshots.last.first.stage, SowImageStage.previewing);
    expect(snapshots.last.first.progress, lessThan(1));
    expect(snapshots.last.last.stage, SowImageStage.queued);
    expect(controller.isPickingSowImages.value, isTrue);
    expect(await controller.pickSowItemImages(), isEmpty);

    releasePreview.complete();
    expect(await result, hasLength(2));
    expect(readyNames, ['first.png', 'second.png']);
    expect(snapshots.last.every((p) => p.progress == 1), isTrue);
    expect(controller.isPickingSowImages.value, isFalse);
  });

  test('failed and empty images do not discard valid previews', () async {
    final broken = File('${directory.path}${Platform.pathSeparator}broken.png');
    await broken.writeAsString('invalid image');
    final empty = File('${directory.path}${Platform.pathSeparator}empty.png');
    await empty.create();
    selectedPaths.addAll([broken.path, empty.path]);
    await addImage('valid.png');
    var progress = <SowImageProgress>[];

    final images = await controller.pickSowItemImages(
      onProgress: (value) => progress = value,
    );

    expect(images.single.originalName, 'valid.png');
    expect(progress.map((p) => p.stage), [
      SowImageStage.failed,
      SowImageStage.skipped,
      SowImageStage.ready,
    ]);
    expect(controller.isPickingSowImages.value, isFalse);
  });

  test(
    'canceling selection clears busy state and allows another selection',
    () async {
      expect(await controller.pickSowItemImages(), isEmpty);
      expect(controller.isPickingSowImages.value, isFalse);
      await addImage('next.png');
      expect(await controller.pickSowItemImages(), hasLength(1));
    },
  );
}
