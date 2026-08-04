import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_models.dart';

class TaskCompletionController extends GetxController {
  // Task info parameters
  final taskId = 'TSK-1024'.obs;
  final taskTitle = 'HVAC Maintenance Unit B'.obs;
  final taskCategory = 'Maintenance'.obs;
  final taskLocation = 'Building A - Roof Level 3'.obs;
  final workerName = 'Alex Morgan'.obs;

  // Image Upload State
  final uploadedPhotos = <UploadedPhotoModel>[
    UploadedPhotoModel(
      id: 'photo_1',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&q=80&w=600',
      timestamp: 'Today, 02:14 PM',
      gpsLocation: '37.7749° N, 122.4194° W',
      caption: 'Initial inspection of compressor unit',
    ),
  ].obs;

  // Verification Checklist State
  final checklist = <VerificationCheckItem>[
    VerificationCheckItem(title: 'Safety Lockout/Tagout Removed', isChecked: true),
    VerificationCheckItem(title: 'Air Filters Cleaned & Replaced', isChecked: true),
    VerificationCheckItem(title: 'System Pressure & Refrigerant Verified', isChecked: false),
    VerificationCheckItem(title: 'Work Area Cleaned & Debris Cleared', isChecked: false),
  ].obs;

  // Quick Note Chips
  final quickNotes = [
    'All filters replaced',
    'Safety check passed',
    'System pressure optimal',
    'Replaced worn belt',
    'Client verbal sign-off',
  ];

  // Controllers & Form State
  final notesController = TextEditingController();
  final isSubmitting = false.obs;
  final requiresSupervisorSignoff = false.obs;
  final isSigned = false.obs;

  void toggleChecklist(int index) {
    checklist[index].isChecked = !checklist[index].isChecked;
    checklist.refresh();
  }

  void addQuickNote(String note) {
    if (notesController.text.contains(note)) return;
    if (notesController.text.isNotEmpty) {
      notesController.text += ', $note';
    } else {
      notesController.text = note;
    }
  }

  void removePhoto(String id) {
    uploadedPhotos.removeWhere((p) => p.id == id);
  }

  void simulateAddPhoto(String sourceType) {
    if (uploadedPhotos.length >= 4) {
      Get.snackbar(
        'Limit Reached',
        'Maximum 4 photos allowed per completion report.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // Curated high quality maintenance/field photos
    final samplePhotos = [
      'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&q=80&w=600',
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&q=80&w=600',
      'https://images.unsplash.com/photo-1581092335397-9583fe92d232?auto=format&fit=crop&q=80&w=600',
    ];

    final newPhoto = UploadedPhotoModel(
      id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: samplePhotos[uploadedPhotos.length % samplePhotos.length],
      timestamp: 'Today, 02:40 PM',
      gpsLocation: '37.7751° N, 122.4192° W',
      caption: 'Completed servicing & coil check ($sourceType)',
    );

    uploadedPhotos.add(newPhoto);

    Get.snackbar(
      'Photo Attached',
      'Photo added via $sourceType with GPS location tag.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.amber.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  void submitTaskCompletion(BuildContext context) async {
    if (uploadedPhotos.isEmpty) {
      Get.snackbar(
        'Proof Required',
        'Please attach at least 1 photo as proof of work completion.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isSubmitting.value = true;

    // Simulate API submission delay
    await Future.delayed(const Duration(seconds: 2));

    isSubmitting.value = false;

    // Show Success Modal Sheet
    if (context.mounted) {
      _showSuccessDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.amber,
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
                'Task ${taskId.value} has been marked as complete with ${uploadedPhotos.length} photo proofs attached.',
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    Get.back(); // Return to previous screen/dashboard
                  },
                  child: const Text(
                    'Return to Dashboard',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}