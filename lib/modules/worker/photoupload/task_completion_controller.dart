import '../../../services/local_data_service.dart';
import 'dart:convert';

import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskpro/common/helpers/api_routes.dart';
import 'package:taskpro/network/api_exception.dart';
import 'package:taskpro/network/api_service.dart';
import 'package:taskpro/singature/signature_screen.dart';
import 'package:taskpro/theme/app_colors.dart';
import '../../../common/models/work_order_model.dart';
import '../../../common/models/sow_item_response_model.dart';

import '../../../services/secure_storage_service.dart';
import '../../../services/worker_data_service.dart';
import 'task_completion_models.dart';

class TaskCompletionController extends GetxController {
  final WorkOrderModel _initialTask;
  final LocalDataService local;
  WorkOrderModel get task => local.findOrder(_initialTask.id) ?? _initialTask;
  Worker? _ordersWorker;
  final RxList<SowItemModel> sowItems = <SowItemModel>[].obs;
  final sowItemResponses = <int, SowItemResponseModel>{}.obs;
  Future<void> _sowItemResponsesReady = Future<void>.value();

  void setSowItems(WorkOrderModel task) {
    sowItems.assignAll(task.sowItems);
  }

  @override
  void onInit() {
    super.onInit();
    taskId.value = task.id.toString();
    setSowItems(task);
    _ordersWorker = ever(local.workOrders, (_) {
      sowItems.assignAll(local.findOrder(_initialTask.id)?.sowItems ?? []);
    });
    local.initialize();
    _sowItemResponsesReady = _loadSowItemResponses();
  }

  TaskCompletionController({
    required WorkOrderModel task,
    LocalDataService? local,
  }) : _initialTask = task,
       local = local ?? LocalDataService.instance;

  /// Base64 encoded PNG signature.
  final RxnString signatureBase64 = RxnString();

  /// Opens the signature screen and receives
  /// the Base64 encoded signature image.
  Future<void> captureSignature() async {
    final String? result = await Get.to<String>(() => const SignatureScreen());

    if (result == null || result.isEmpty) {
      signatureBase64.value = "";
      return;
    }
    if (result.isNotEmpty) {
      signatureBase64.value = result;
    }

    update();

    Get.snackbar(
      'Signature Added',
      'Customer signature has been captured successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  /// Replace this with your real task-completion API URL, preferably through
  /// an environment/configuration class rather than hard-coding it here.

  final ApiService _apiService = ApiService();

  /// Pass the logged-in user's access token when your API uses JWT auth.

  static const int maxPhotos = 4;
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024;

  final ImagePicker _imagePicker = ImagePicker();
  SecureStorageService get storage => local.storage;

  // Task info parameters
  final taskId = 'TSK-1024'.obs;
  final taskTitle = 'HVAC Maintenance Unit B'.obs;
  final taskCategory = 'Maintenance'.obs;
  final taskLocation = 'Building A - Roof Level 3'.obs;
  final workerName = 'Alex Morgan'.obs;

  // Local images are stored here and uploaded only after Submit is pressed.
  final uploadedPhotos = <UploadedPhotoModel>[].obs;

  // Verification Checklist State
  final checklist = <VerificationCheckItem>[
    VerificationCheckItem(
      title: 'Safety Lockout/Tagout Removed',
      isChecked: true,
      quantity: 1,
    ),
    VerificationCheckItem(
      title: 'Air Filters Cleaned & Replaced',
      isChecked: true,
      quantity: 2,
    ),
    VerificationCheckItem(
      title: 'System Pressure & Refrigerant Verified',
      quantity: 1,
    ),
    VerificationCheckItem(
      title: 'Work Area Cleaned & Debris Cleared',
      quantity: 1,
    ),
  ].obs;

  // Quick Note Chips
  final quickNotes = <String>[
    'All filters replaced',
    'Safety check passed',
    'System pressure optimal',
    'Replaced worn belt',
    'Client verbal sign-off',
  ];

  // Controllers & Form State
  final notesController = TextEditingController();
  final isPickingPhoto = false.obs;
  final isPickingSowImages = false.obs;
  final isSubmitting = false.obs;

  final uploadProgress = 0.0.obs;

  final uploadProgressText = 'Preparing upload...'.obs;

  void toggleChecklist(int index) {
    final item = checklist[index];

    item.isChecked = !item.isChecked;

    item.markFromTechnician = item.isChecked ? 1 : 0;

    checklist.refresh();
  }

  void increaseQuantity(int index) {
    checklist[index].quantity++;
    checklist.refresh();
  }

  void decreaseQuantity(int index) {
    if (checklist[index].quantity <= 1) return;

    checklist[index].quantity--;
    checklist.refresh();
  }

  void addQuickNote(String note) {
    if (notesController.text.contains(note)) return;

    if (notesController.text.trim().isNotEmpty) {
      notesController.text = '${notesController.text.trim()}, $note';
    } else {
      notesController.text = note;
    }

    notesController.selection = TextSelection.collapsed(
      offset: notesController.text.length,
    );
  }

  void removePhoto(String id) {
    if (isSubmitting.value) return;
    uploadedPhotos.removeWhere((photo) => photo.id == id);
  }

  Future<void> pickPhoto(
    ImageSource source, {
    required Future<bool> Function(File file, String name, int size)
    confirmPhoto,
  }) async {
    if (isPickingPhoto.value || isSubmitting.value) return;

    if (uploadedPhotos.length >= maxPhotos) {
      _showError(
        'Limit Reached',
        'Maximum $maxPhotos photos are allowed per completion report.',
      );
      return;
    }

    try {
      isPickingPhoto.value = true;

      final XFile? selectedFile = await _imagePicker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 82,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (selectedFile == null) return;

      final file = File(selectedFile.path);
      if (!await file.exists()) {
        throw const FileSystemException('Selected image file was not found.');
      }

      final int fileSize = await file.length();
      if (fileSize <= 0) {
        _showError('Invalid Photo', 'The selected photo is empty or damaged.');
        return;
      }

      if (fileSize > maxPhotoSizeBytes) {
        _showError(
          'Photo Too Large',
          'Please select a photo smaller than 5 MB.',
        );
        return;
      }

      final confirmed = await confirmPhoto(file, selectedFile.name, fileSize);
      if (isClosed) return;

      if (!confirmed) return;

      uploadedPhotos.add(
        UploadedPhotoModel(
          id: 'photo_${DateTime.now().microsecondsSinceEpoch}',
          filePath: selectedFile.path,
          fileName: selectedFile.name.isEmpty
              ? _fileNameFromPath(selectedFile.path)
              : selectedFile.name,
          fileSizeBytes: fileSize,
          source: source == ImageSource.camera ? 'Camera' : 'Gallery',
          timestamp: _formatDateTime(DateTime.now()),
          caption: 'Task completion proof',
        ),
      );

      Get.snackbar(
        'Photo Attached',
        'The photo is ready and will upload when you submit the task.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2563EB),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } on PlatformException catch (error) {
      _showError(
        'Permission Required',
        error.message ??
            'Camera or photo-library permission could not be granted.',
      );
    } on FileSystemException catch (error) {
      _showError('Unable to Read Photo', error.message);
    } catch (error) {
      _showError(
        'Unable to Add Photo $error',
        'The photo could not be selected. Please try again.',
      );
    } finally {
      isPickingPhoto.value = false;
    }
  }

  Future<List<SowItemEvidenceModel>> pickSowItemImages() async {
    if (isPickingSowImages.value || isSubmitting.value) return const [];
    final images = <SowItemEvidenceModel>[];

    try {
      isPickingSowImages.value = true;
      final selectedFiles = await _imagePicker.pickMultiImage();
      final appDirectory = await getApplicationDocumentsDirectory();
      final evidenceDirectory = Directory(
        '${appDirectory.path}${Platform.pathSeparator}'
        '${SowItemResponseModel.evidenceDirectoryName}'
        '${Platform.pathSeparator}${task.id}',
      );
      await evidenceDirectory.create(recursive: true);

      for (final selectedFile in selectedFiles) {
        final file = File(selectedFile.path);
        if (!await file.exists()) {
          throw const FileSystemException('Selected image file was not found.');
        }
        final size = await file.length();
        if (size <= 0) {
          _showError('Invalid Photo', 'A selected image is empty or damaged.');
          continue;
        }
        if (size > maxPhotoSizeBytes) {
          _showError(
            'Photo Too Large',
            '${selectedFile.name} exceeds the 5 MB per-image limit.',
          );
          continue;
        }

        final safeName = selectedFile.name.replaceAll(
          RegExp(r'[^A-Za-z0-9._-]'),
          '_',
        );
        final savedFile = await file.copy(
          '${evidenceDirectory.path}${Platform.pathSeparator}'
          '${DateTime.now().microsecondsSinceEpoch}_$safeName',
        );
        images.add(
          SowItemEvidenceModel(
            filePath: savedFile.path,
            fileName: selectedFile.name.isEmpty
                ? _fileNameFromPath(selectedFile.path)
                : selectedFile.name,
            fileSizeBytes: size,
            source: 'Gallery',
            timestamp: _formatDateTime(DateTime.now()),
          ),
        );
      }
      return images;
    } on PlatformException catch (error) {
      await discardSowItemImages(images);
      _showError(
        'Permission Required',
        error.message ?? 'Photo-library permission could not be granted.',
      );
      return const [];
    } on FileSystemException catch (error) {
      await discardSowItemImages(images);
      _showError('Unable to Read Photo', error.message);
      return const [];
    } catch (error) {
      await discardSowItemImages(images);
      _showError(
        'Unable to Add Photos',
        'The selected images could not be read: $error',
      );
      return const [];
    } finally {
      isPickingSowImages.value = false;
    }
  }

  Future<void> discardSowItemImages(
    Iterable<SowItemEvidenceModel> images,
  ) async {
    for (final image in images) {
      try {
        final file = File(image.filePath);
        if (await file.exists()) await file.delete();
      } on FileSystemException catch (error) {
        debugPrint('Unable to remove unsaved SOW evidence: $error');
      }
    }
  }

  Future<void> _loadSowItemResponses() async {
    try {
      final value = await storage.read(
        SowItemResponseModel.storageKey(task.id),
      );
      if (!isClosed) {
        sowItemResponses.assignAll(SowItemResponseModel.decodeStorage(value));
      }
    } catch (error) {
      debugPrint('Unable to load saved SOW responses: $error');
    }
  }

  bool isSowItemNotApplicable(SowItemModel item) =>
      sowItemResponses[item.id]?.status ==
      SowItemResponseStatus.notApplicable;

  bool isSowItemResolved(SowItemModel item) =>
      item.status == 1 || sowItemResponses[item.id] != null;

  Future<List<Map<String, dynamic>>> buildSowItemsSubmission() async {
    final payload = <Map<String, dynamic>>[];
    for (final item in sowItems) {
      if (isSowItemNotApplicable(item)) continue;

      final response = sowItemResponses[item.id];
      final images = <String>[];
      for (final image in response?.images ?? const <SowItemEvidenceModel>[]) {
        images.add(base64Encode(await File(image.filePath).readAsBytes()));
      }

      payload.add({
        'id': item.id,
        'status': item.status,
        'comments': response?.comments ?? '',
        'images': images,
      });
    }
    return payload;
  }

  Future<void> saveSowItemResponse(SowItemResponseModel response) async {
    final previousResponse = sowItemResponses[response.sowItemId];
    final updatedResponses = Map<int, SowItemResponseModel>.from(
      sowItemResponses,
    )..[response.sowItemId] = response;
    final status = response.status == SowItemResponseStatus.completed ? 1 : 0;

    await storage.editWorkOrder(task.id, (current) {
      return current.copyWith(
        sowItems: current.sowItems.map((item) {
          if (item.id != response.sowItemId) return item;
          return item.copyWith(
            status: status,
            completedAt: status == 1 ? DateTime.now() : null,
          );
        }).toList(),
        sync: response.status == SowItemResponseStatus.completed
            ? 0
            : current.sync,
      );
    });
    await storage.write(
      SowItemResponseModel.storageKey(task.id),
      SowItemResponseModel.encodeStorage(updatedResponses),
    );
    sowItemResponses.assignAll(updatedResponses);

    final retainedPaths = response.images.map((image) => image.filePath).toSet();
    for (final image in previousResponse?.images ?? const []) {
      if (retainedPaths.contains(image.filePath)) continue;
      try {
        final file = File(image.filePath);
        if (await file.exists()) await file.delete();
      } on FileSystemException catch (error) {
        debugPrint('Unable to remove replaced SOW evidence: $error');
      }
    }
  }

  Future<void> submitTaskCompletion({required VoidCallback onSuccess}) async {
    await _sowItemResponsesReady;

    // 1. PRE-INSTALLATION MUST BE COMPLETED FIRST
    final pendingPreInstall = sowItems
        .where((item) => item.type == 'pre_install' && !isSowItemResolved(item))
        .toList();

    if (pendingPreInstall.isNotEmpty) {
      Get.snackbar(
        'Pre-Installation Incomplete',
        '${pendingPreInstall.length} pre-installation item(s) are still pending. '
            'Complete all pre-installation checks before proceeding.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.assignment_late_outlined, color: Colors.white),
      );

      return;
    }

    // 2. INSTALLATION MUST BE COMPLETED
    final pendingInstall = sowItems
        .where((item) => item.type == 'install' && !isSowItemResolved(item))
        .toList();

    if (pendingInstall.isNotEmpty) {
      Get.snackbar(
        'Installation Incomplete',
        '${pendingInstall.length} installation & testing item(s) are still pending. '
            'Complete them before submitting the work order.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.handyman_outlined, color: Colors.white),
      );

      return;
    }

    // ============================================================
    // 2. VALIDATE PHOTO
    // ============================================================

    if (uploadedPhotos.isEmpty) {
      Get.snackbar(
        'Proof Required',
        'Please attach at least one work completion photo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      return;
    }

    // ============================================================
    // 3. SUBMIT
    // ============================================================

    try {
      isSubmitting.value = true;

      uploadProgress.value = 0.0;
      uploadProgressText.value = 'Preparing upload...';

      final formData = dio.FormData.fromMap({
        'taskId': taskId.value,
        'remarks': notesController.text.trim(),
        'taskCategory': taskCategory.value,
        'taskLocation': taskLocation.value,
      });

      // ==========================================================
      // ADD SOW CHECKLIST
      // ==========================================================

      formData.fields.add(
        MapEntry(
          'sow_items',
          jsonEncode(await buildSowItemsSubmission()),
        ),
      );

      // ==========================================================
      // ADD PHOTOS
      // ==========================================================

      for (final photo in uploadedPhotos) {
        final file = await dio.MultipartFile.fromFile(
          photo.filePath,
          filename: photo.fileName,
        );

        formData.files.add(MapEntry('photos', file));
      }

      // ==========================================================
      // API
      // ==========================================================

      final response = await _apiService.postMultipart(
        ApiRoutes.taskSubmitted,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final percentage = ((sent / total) * 100).round();

            uploadProgress.value = percentage / 100;

            uploadProgressText.value = 'Uploading photos... $percentage%';
          }
        },
      );

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          !_hasRejectedResponse(response.data)) {
        uploadProgress.value = 1.0;
        uploadProgressText.value = 'Upload completed';

        try {
          await WorkerDataService(
            api: _apiService,
            local: local,
          ).clearPhotoUploadFailures(task.id);
        } catch (error) {
          debugPrint('Unable to clear previous photo upload failure: $error');
        }
        if (!isClosed) onSuccess();
      } else {
        throw ApiException(
          message:
              _responseMessage(response.data) ?? 'Unable to complete task.',
          statusCode: response.statusCode,
          data: response.data,
        );
      }
    }
    // ============================================================
    // API ERROR
    // ============================================================
    on ApiException catch (e) {
      final photoFailures = _photoUploadFailures(e.data, e.message);
      await _recordPhotoUploadFailures(photoFailures);
      Get.snackbar(
        'Upload Failed',
        photoFailures.join('\n'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
    // ============================================================
    // NETWORK ERROR
    // ============================================================
    on dio.DioException catch (e) {
      final photoFailures = _photoUploadFailures(
        e.response?.data,
        e.message ?? 'Unable to connect to server.',
      );
      await _recordPhotoUploadFailures(photoFailures);
      Get.snackbar(
        'Network Error',
        photoFailures.join('\n'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
    // ============================================================
    // UNKNOWN ERROR
    // ============================================================
    catch (e) {
      final photoFailures = _photoUploadFailures(null, e.toString());
      await _recordPhotoUploadFailures(photoFailures);
      Get.snackbar(
        'Error',
        photoFailures.join('\n'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
    // ============================================================
    // ALWAYS RESET
    // ============================================================
    finally {
      isSubmitting.value = false;
    }
  }

  List<String> _photoUploadFailures(dynamic response, String message) {
    final errors = response is Map
        ? response['errors'] ??
              (response['data'] is Map ? response['data']['errors'] : null)
        : null;
    final failures = <String>[];
    if (errors is Map) {
      final indexedPhotoError = RegExp(
        r'^photos?(?:\.|\[)(\d+)(?:\]|\.)?\.?(.*)$',
      );
      for (final entry in errors.entries) {
        final match = indexedPhotoError.firstMatch(entry.key.toString());
        if (match == null) continue;
        final index = int.tryParse(match.group(1)!);
        final photo =
            index != null && index >= 0 && index < uploadedPhotos.length
            ? uploadedPhotos[index]
            : null;
        final reference = photo == null
            ? 'photo index ${index ?? match.group(1)}'
            : '"${photo.fileName}"';
        final field = match.group(2);
        final detail = _errorText(entry.value);
        failures.add(
          'Photo upload failed for $reference'
          '${field == null || field.isEmpty ? '' : ' ($field)'}: $detail',
        );
      }
    }
    if (failures.isNotEmpty) return failures;

    final photoNames = uploadedPhotos
        .asMap()
        .entries
        .map((entry) => '#${entry.key + 1} "${entry.value.fileName}"')
        .join(', ');
    return [
      'Photo upload failed for $photoNames. '
          'The server did not identify an individual file: $message',
    ];
  }

  bool _hasRejectedResponse(dynamic response) {
    if (response is! Map) return false;
    final status = response['success'] ?? response['status'];
    if (status == null) return false;
    return status == false ||
        status.toString().toLowerCase() == 'false' ||
        status.toString().toLowerCase() == 'error' ||
        status.toString().toLowerCase() == 'failed';
  }

  String? _responseMessage(dynamic response) {
    if (response is! Map) return null;
    final message = response['message'] ?? response['error'];
    if (message == null || message.toString().trim().isEmpty) return null;
    return message.toString();
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

  Future<void> _recordPhotoUploadFailures(List<String> failures) async {
    try {
      for (final failure in failures) {
        await WorkerDataService(
          api: _apiService,
          local: local,
        ).savePhotoUploadFailure(task.id, 'Photo upload: $failure');
      }
    } catch (error) {
      debugPrint('Unable to save photo upload failure: $error');
    }
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  String _formatDateTime(DateTime value) {
    final hour = value.hour == 0
        ? 12
        : value.hour > 12
        ? value.hour - 12
        : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return 'Today, ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _fileNameFromPath(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  @override
  void onClose() {
    _ordersWorker?.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<bool> canOpenSowItem(SowItemModel item) async {
    await _sowItemResponsesReady;
    // ------------------------------------------------------------
    // If technician is trying to update an INSTALL item,
    // first verify that ALL PRE-INSTALL items are completed.
    // ------------------------------------------------------------
    if (item.type == 'install') {
      final pendingPreInstall = sowItems
          .where((e) => e.type == 'pre_install' && !isSowItemResolved(e))
          .toList();

      if (pendingPreInstall.isNotEmpty) {
        Get.snackbar(
          'Complete Pre-Installation First',
          '${pendingPreInstall.length} pre-installation item(s) are still pending. '
              'Complete all pre-installation checks before starting installation.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.lock_outline_rounded, color: Colors.white),
        );

        return false;
      }
    }
    return true;
  }

  bool get isPreInstallationCompleted {
    final preInstallItems = sowItems
        .where((e) => e.type == 'pre_install')
        .toList();

    // If there are no pre-install items, don't block installation.
    if (preInstallItems.isEmpty) {
      return true;
    }

    return preInstallItems.every(isSowItemResolved);
  }
}
