

import 'package:flutter/material.dart';

import '../../../services/local_data_service.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:taskpro/common/helpers/sow_image_compressor.dart';

import 'package:taskpro/singature/signature_screen.dart';
import 'package:taskpro/theme/app_colors.dart';
import '../../../common/models/work_order_model.dart';
import '../../../common/models/sow_item_response_model.dart';

import '../../../services/secure_storage_service.dart';


import 'task_completion_models.dart';

class TaskCompletionController extends GetxController {
  final WorkOrderModel _initialTask;
  final LocalDataService local;
  WorkOrderModel get task => local.findOrder(_initialTask.id) ?? _initialTask;
  Worker? _ordersWorker;
  final RxList<SowItemModel> sowItems = <SowItemModel>[].obs;
  final sowItemResponses = <int, SowItemResponseModel>{}.obs;
  Future<void> _sowItemResponsesReady = Future<void>.value();

  @override
  void onInit() {
    super.onInit();
    remarksFocusNode.addListener(() {
      if (!remarksFocusNode.hasFocus) {
        // Focus is lost – save text here
        _saveRemarksToLocalStorage(notesController.text);
      }
    });
    taskId.value = task.id.toString();
    uploadedPhotos.assignAll(task.photos ?? const <UploadedPhotoModel>[]);
    _setSowItems(task);
    _ordersWorker = ever(local.workOrders, (_) {
      _setSowItems(local.findOrder(_initialTask.id));
    });
    _sowItemResponsesReady = _loadSowItemResponses();
    notesController.text = task.remarks ?? "";
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


  /// Pass the logged-in user's access token when your API uses JWT auth.

  static const int maxPhotos = 4;
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024;
  static const int maxSowImageSourceBytes = 25 * 1024 * 1024;

  final ImagePicker _imagePicker = ImagePicker();
  SecureStorageService get storage => local.storage;

  // Task info parameters
  final taskId = 'TSK-1024'.obs;
  final taskTitle = 'HVAC Maintenance Unit B'.obs;
  final taskCategory = 'Maintenance'.obs;
  final taskLocation = 'Building A - Roof Level 3'.obs;
  final workerName = 'Alex Morgan'.obs;

  // Photos are cached with their Base64 image data for offline sync.
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
    // 'All filters replaced',
    // 'Safety check passed',
    // 'System pressure optimal',
    // 'Replaced worn belt',
    // 'Client verbal sign-off',
  ];

  // Controllers & Form State
  final notesController = TextEditingController();
  final FocusNode remarksFocusNode = FocusNode();
  final isPickingPhoto = false.obs;
  final isCompressingPhoto = false.obs;
  final isPickingSowImages = false.obs;
  final isSubmitting = false.obs;

  final uploadProgress = 0.0.obs;

  final uploadProgressText = 'Submitting...'.obs;

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

  Future<void> removePhoto(String id) async {
    if (isSubmitting.value) return;
    uploadedPhotos.removeWhere((photo) => photo.id == id);
    await _savePhotosLocally();
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

      late final Uint8List compressedImage;
      try {
        isCompressingPhoto.value = true;
        compressedImage = await compute(
          compressTaskCompletionPhoto,
          await file.readAsBytes(),
        );
      } finally {
        isCompressingPhoto.value = false;
      }
      if (isClosed) return;

      final originalFileName = selectedFile.name.isEmpty
          ? _fileNameFromPath(selectedFile.path)
          : selectedFile.name;
      final photo = UploadedPhotoModel(
        id: 'photo_${DateTime.now().microsecondsSinceEpoch}',
        filePath: selectedFile.path,
        fileName: _jpegFileName(originalFileName),
        fileSizeBytes: compressedImage.lengthInBytes,
        source: source == ImageSource.camera ? 'Camera' : 'Gallery',
        timestamp: _formatDateTime(DateTime.now()),
        caption: 'Task completion proof',
        image: base64Encode(compressedImage),
      );
      uploadedPhotos.add(photo);
      try {
        await _savePhotosLocally();
      } catch (_) {
        uploadedPhotos.removeWhere((item) => item.id == photo.id);
        rethrow;
      }

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

  Future<List<SowAttachmentModel>> pickSowItemImages({
    void Function(List<SowImageProgress> images)? onProgress,
    Future<void> Function(SowAttachmentModel image)? onImageReady,
  }) async {
    if (isPickingSowImages.value || isSubmitting.value) return const [];
    final images = <SowAttachmentModel>[];

    try {
      isPickingSowImages.value = true;
      final selectedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 100,
        maxWidth: 2560,
        maxHeight: 2560,
      );
      final progress = [
        for (final file in selectedFiles)
          SowImageProgress(
            fileName: file.name.isEmpty
                ? _fileNameFromPath(file.path)
                : file.name,
          ),
      ];
      void report(int index, SowImageStage stage, [String? message]) {
        progress[index] = SowImageProgress(
          fileName: progress[index].fileName,
          stage: stage,
          message: message,
        );
        onProgress?.call(List.unmodifiable(progress));
      }

      onProgress?.call(List.unmodifiable(progress));
      for (var index = 0; index < selectedFiles.length; index++) {
        final selectedFile = selectedFiles[index];
        try {
          report(index, SowImageStage.reading);
          final file = File(selectedFile.path);
          if (!await file.exists()) {
            throw const FileSystemException(
              'Selected image file was not found.',
            );
          }
          final size = await file.length();
          if (size <= 0) {
            report(index, SowImageStage.skipped, 'Empty or damaged image');
            continue;
          }
          if (size > maxSowImageSourceBytes) {
            report(index, SowImageStage.skipped, 'Exceeds the 25 MB limit');
            continue;
          }

          final bytes = await file.readAsBytes();
          report(index, SowImageStage.compressing);
          final compressedBytes = await compute(compressSowImage, bytes);
          report(index, SowImageStage.previewing);
          final image = SowAttachmentModel(
            id: 0,
            workOrderId: task.id,
            sowItemId: 0,
            disk: '',
            filePath: base64Encode(compressedBytes),
            originalName: selectedFile.name.isEmpty
                ? _fileNameFromPath(selectedFile.path)
                : selectedFile.name,
            mimeType: 'image/jpeg',
            fileSize: compressedBytes.lengthInBytes,
          );
          await onImageReady?.call(image);
          images.add(image);
          report(index, SowImageStage.ready);
        } catch (error) {
          debugPrint(
            'Unable to prepare SOW image ${selectedFile.name}: $error',
          );
          report(index, SowImageStage.failed, 'Unable to process image');
        }
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

  Future<void> discardSowItemImages(Iterable<SowAttachmentModel> images) async {
    // SOW images are stored as Base64, so there are no local files to remove.
  }

  Future<void> _loadSowItemResponses() async {
    await local.initialize();
    if (!isClosed) {
      final order = local.findOrder(_initialTask.id);
      _setSowItems(order);
      uploadedPhotos.assignAll(order?.photos ?? const <UploadedPhotoModel>[]);
    }
  }

  void _setSowItems(WorkOrderModel? order) {
    final items = order?.sowItems ?? const <SowItemModel>[];
    sowItems.assignAll(items);
    sowItemResponses.assignAll({
      for (final item in items.where((item) => item.isResolved))
        item.id: SowItemResponseModel(
          sowItemId: item.id,
          status: item.isNotApplicable
              ? SowItemResponseStatus.notApplicable
              : SowItemResponseStatus.completed,
          comments: item.notes,
          images: item.attachments,
        ),
    });
  }

  bool isSowItemNotApplicable(SowItemModel item) =>
      sowItemResponses[item.id]?.status ==
          SowItemResponseStatus.notApplicable ||
      item.isNotApplicable;

  bool isSowItemResolved(SowItemModel item) =>
      item.isResolved || sowItemResponses[item.id] != null;

  Future<List<Map<String, dynamic>>> buildSowItemsSubmission() async {
    final payload = <Map<String, dynamic>>[];
    for (final item in sowItems) {
      if (isSowItemNotApplicable(item)) continue;

      final response = sowItemResponses[item.id];
      final images = <String>[];
      for (final image in response?.images ?? const <SowAttachmentModel>[]) {
        final file = image.filePath.length <= 1024
            ? File(image.filePath)
            : null;
        images.add(
          file != null && await file.exists()
              ? base64Encode(await file.readAsBytes())
              : image.filePath,
        );
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
    await _sowItemResponsesReady;
    if (local.findOrder(task.id) == null) {
      throw StateError(
        'Work order ${task.id} is not available in local storage.',
      );
    }
    final previousResponse = sowItemResponses[response.sowItemId];
    final status = response.status == SowItemResponseStatus.completed ? 1 : 2;
    final completedAt = status == 1 ? DateTime.now() : null;

    await storage.editWorkOrder(task.id, (current) {
      if (!current.sowItems.any((item) => item.id == response.sowItemId)) {
        throw StateError(
          'SOW item ${response.sowItemId} is no longer available in this work order.',
        );
      }
      return current.copyWith(
        sowItems: current.sowItems.map((item) {
          if (item.id != response.sowItemId) return item;
          return item.copyWith(
            notes: response.comments,
            attachments: response.images.map(
              (image) {
                final existingAttachments = item.attachments;

                SowAttachmentModel? existing;

                for (final old in existingAttachments) {
                  if (old.fileSize == image.fileSize &&
                      old.originalName == image.originalName) {
                    existing = old;
                    break;
                  }
                }

                // Existing attachment: preserve all its original metadata.
                if (existing != null) {
                  return existing;
                }

                // Newly added image: mark as mobile upload.
                return SowAttachmentModel(
                  id: 0,
                  workOrderId: item.workOrderId,
                  sowItemId: item.id,
                  disk: image.disk,
                  originalName: image.originalName,
                  mimeType: image.mimeType,
                  fileSize: image.fileSize,
                  filePath: image.filePath,
                  isMobileUpload: true,
                );
              },
              // => SowAttachmentModel(
              //       id: 0,
              //       workOrderId: item.workOrderId,
              //       sowItemId: item.id,
              //       disk: '',
              //       originalName: image.originalName,
              //       mimeType: '',
              //       fileSize: image.fileSize,
              //       filePath:  image.filePath,
              //       isMobileUpload: true
              //     ),
            ).toList(),
            status: status,
            completedAt: completedAt,
            clearCompletedAt: status != 1,
          );
        }).toList(),
        sync: 0,
      );
    });

    final retainedPaths = response.images
        .map((image) => image.filePath)
        .toSet();
    for (final image in previousResponse?.images ?? const []) {
      if (retainedPaths.contains(image.filePath)) continue;
      if (image.filePath.length > 1024) continue;
      try {
        final file = File(image.filePath);
        if (await file.exists()) await file.delete();
      } on FileSystemException catch (error) {
        debugPrint('Unable to remove replaced SOW evidence: $error');
      }
    }
  }

  Future<void> submitTaskCompletion({required VoidCallback onResult}) async {
    await _sowItemResponsesReady;
    if (isClosed || isSubmitting.value) return;

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

    // if (uploadedPhotos.isEmpty) {
    //   Get.snackbar(
    //     'Proof Required',
    //     'Please attach at least one work completion photo.',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.red.shade700,
    //     colorText: Colors.white,
    //     margin: const EdgeInsets.all(16),
    //   );
    //
    //   return;
    // }

    // ============================================================
    // 3. SUBMIT
    // ============================================================

    try {
      isSubmitting.value = true;

      uploadProgress.value = 0.0;

      // ==========================================================
      // API
      // ==========================================================

      task.statusId = 18; //submitted
      await local.storage.updateWorkOrderData(task);
      uploadProgress.value = 1.0;
      uploadProgressText.value = 'Work Order Submitted completely';
      onResult();
      Get.snackbar(
        'Success',
        'Work order submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (error) {
      debugPrint("❌SubmitTaskWorkOrderApi Error: $error");
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _savePhotosLocally() => storage.editWorkOrder(
    task.id,
    (current) => current.copyWith(
      photos: uploadedPhotos.toList(growable: false),
      sync: 0,
    ),
  );


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

  String _jpegFileName(String name) {
    final extensionIndex = name.lastIndexOf('.');
    final baseName = extensionIndex <= 0
        ? name
        : name.substring(0, extensionIndex);
    return '$baseName.jpg';
  }

  @override
  void onClose() {
    remarksFocusNode.dispose();
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

  void _saveRemarksToLocalStorage(String text) async {
    task.remarks = text;
    await local.storage.updateWorkOrderData(task);
  }
}
