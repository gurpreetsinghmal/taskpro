import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskpro/network/api_exception.dart';
import 'package:taskpro/network/api_service.dart';
import 'task_completion_models.dart';

class TaskCompletionController extends GetxController {
  TaskCompletionController({
    this.apiEndpoint = 'https://your-domain.com/api/tasks/complete',
    this.bearerToken,
  });

  /// Replace this with your real task-completion API URL, preferably through
  /// an environment/configuration class rather than hard-coding it here.
  final String apiEndpoint;
  final ApiService _apiService = ApiService();
  /// Pass the logged-in user's access token when your API uses JWT auth.
  final String? bearerToken;

  static const int maxPhotos = 4;
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024;

  final ImagePicker _imagePicker = ImagePicker();

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
    ),
    VerificationCheckItem(
      title: 'Air Filters Cleaned & Replaced',
      isChecked: true,
    ),
    VerificationCheckItem(
      title: 'System Pressure & Refrigerant Verified',
    ),
    VerificationCheckItem(
      title: 'Work Area Cleaned & Debris Cleared',
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
  final isSubmitting = false.obs;

  final uploadProgress = 0.0.obs;

  final uploadProgressText = 'Preparing upload...'.obs;

  void toggleChecklist(int index) {
    checklist[index].isChecked = !checklist[index].isChecked;
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
      BuildContext context,
      ImageSource source,
      ) async {
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

      if (!context.mounted) return;

      final bool confirmed = await _showSelectedPhotoPreview(
        context: context,
        file: file,
        fileName: selectedFile.name,
        fileSize: fileSize,
        source: source,
      ) ??
          false;

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
      _showError(
        'Unable to Read Photo',
        error.message,
      );
    } catch (error) {
      _showError(
        'Unable to Add Photo $error',
        'The photo could not be selected. Please try again.',
      );
    } finally {
      isPickingPhoto.value = false;
    }
  }

  Future<bool?> _showSelectedPhotoPreview({
    required BuildContext context,
    required File file,
    required String fileName,
    required int fileSize,
    required ImageSource source,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 28,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Preview Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 430),
                      color: const Color(0xFFF1F5F9),
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image.file(
                          file,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 280,
                              child: Center(
                                child: Text('Unable to preview this photo.'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fileName.isEmpty ? _fileNameFromPath(file.path) : fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${source == ImageSource.camera ? 'Camera' : 'Gallery'} • ${_readableFileSize(fileSize)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Use Photo'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> submitTaskCompletion(
      BuildContext context,
      ) async {
    if (uploadedPhotos.isEmpty) {
      Get.snackbar(
        'Proof Required',
        'Please attach at least one photo as proof of work completion.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      return;
    }

    try {
      isSubmitting.value = true;

      uploadProgress.value = 0.0;
      uploadProgressText.value = 'Preparing upload...';


      // IMPORTANT:
      // Use Dio's FormData explicitly.
      // fromMap({}) works safely across Dio versions.
      final formData = dio.FormData.fromMap({
        'taskId': taskId.value,
        'remarks': notesController.text.trim(),
        'taskCategory': taskCategory.value,
        'taskLocation': taskLocation.value,
      });

      // Add checklist
      formData.fields.add(
        MapEntry(
          'checklist',
          jsonEncode(
            checklist.map(
                  (item) => {
                'title': item.title,
                'isChecked': item.isChecked,
              },
            ).toList(),
          ),
        ),
      );

      // Add photos
      for (final photo in uploadedPhotos) {
        final file = await dio.MultipartFile.fromFile(
          photo.filePath,
          filename: photo.fileName,
        );

        formData.files.add(
          MapEntry(
            'photos',
            file,
          ),
        );
      }

      // Call common API service
      final response = await _apiService.postMultipart(
        '/tasks/complete',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final percentage = ((sent / total) * 100).round();

            uploadProgress.value = percentage / 100;

            uploadProgressText.value =
            'Uploading photos... $percentage%';
          }
        },
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        isSubmitting.value = false;
        uploadProgress.value = 1.0;
        uploadProgressText.value =
        'Upload completed';

        if (context.mounted) {
          _showSuccessDialog(context,"Success with Gurpreet");
        }
      } else {
        throw ApiException(
          message: 'Unable to complete task.',
          statusCode: response.statusCode,
        );
      }
    } on ApiException catch (e) {
      isSubmitting.value = false;

      Get.snackbar(
        'Upload Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on dio.DioException catch (e) {
      isSubmitting.value = false;

      Get.snackbar(
        'Network Error',
        e.message ?? 'Unable to connect to server.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      isSubmitting.value = false;

      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
  String? _readApiMessage(String responseBody) {
    if (responseBody.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ??
            decoded['Message'] ??
            decoded['error'] ??
            decoded['Error'];
        return message?.toString();
      }
    } catch (_) {
      // The endpoint may intentionally return plain text or an empty body.
    }

    return null;
  }

  void _showSuccessDialog(
      BuildContext context,
      String? serverMessage,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2563EB),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Task Completed!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  serverMessage?.trim().isNotEmpty == true
                      ? serverMessage!.trim()
                      : 'Task ${taskId.value} was submitted with ${uploadedPhotos.length} photo proof(s).',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Get.back();
                    },
                    child: const Text(
                      'Return to Dashboard',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  String _readableFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';

    final kilobytes = bytes / 1024;
    if (kilobytes < 1024) {
      return '${kilobytes.toStringAsFixed(1)} KB';
    }

    return '${(kilobytes / 1024).toStringAsFixed(1)} MB';
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}

class _ApiException implements Exception {
  const _ApiException(this.message);

  final String message;
}
