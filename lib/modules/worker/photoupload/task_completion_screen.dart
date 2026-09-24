import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_controller.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_models.dart';
import 'package:taskpro/theme/app_colors.dart';

import '../../../common/helpers/helper_methods.dart';
import '../../../common/models/work_session_model.dart';
import '../tasks/w_tasks_controller.dart';

class TaskCompletionScreen extends StatelessWidget {
  final WorkOrderModel task;
  const TaskCompletionScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final submitFinalcontroller = Get.put(TaskCompletionController(task: task));
    final WorkerTasksController controller = Get.put(WorkerTasksController());
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      appBar: AppBar(
        backgroundColor: AppColors.textWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.secondary,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Complete Work Order",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "WO No: ${task.workOrderNo}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            _CheckInOutCard(
              task: task,
            ),

            const SizedBox(height: 15),

            Obx(
              () => submitFinalcontroller.isCheckedIn
                  ? Column(
                      children: [
                        _buildTaskSummaryCard(submitFinalcontroller),
                        const SizedBox(height: 20),

                        _buildImageUploadSection(
                          context,
                          submitFinalcontroller,
                        ),
                        const SizedBox(height: 24),

                        _buildChecklistSection(submitFinalcontroller),
                        const SizedBox(height: 24),

                        _buildNotesSection(submitFinalcontroller),
                        const SizedBox(height: 24),

                        _buildSubmitButton(context, submitFinalcontroller),
                        const SizedBox(height: 24),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSummaryCard(TaskCompletionController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textWhite),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    controller.taskTitle.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'In Progress',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Obx(
                  () => Text(
                    controller.taskLocation.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Obx(
                () => Text(
                  "Assigned to: ${controller.workerName.value}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(
    BuildContext context,
    TaskCompletionController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Text(
                  "Proof of Work (Photos)",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Obx(
              () => Text(
                "${controller.uploadedPhotos.length} / 4 Photos",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Photo Grid Layout
        Obx(
          () => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount:
                controller.uploadedPhotos.length +
                (controller.uploadedPhotos.length < 4 ? 1 : 0),
            itemBuilder: (context, index) {
              // Add Photo Picker Button Tile
              if (index == controller.uploadedPhotos.length) {
                return _buildAddPhotoButton(context, controller);
              }

              final photo = controller.uploadedPhotos[index];
              return _buildPhotoTile(context, photo, controller);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(
    BuildContext context,
    TaskCompletionController controller,
  ) {
    return InkWell(
      onTap: () => _showPhotoPickerSourceSheet(context, controller),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.add_a_photo_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Add Photo",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Camera or Gallery",
              style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile(
    BuildContext context,
    UploadedPhotoModel photo,
    TaskCompletionController controller,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAttachedPhotoPreview(context, photo),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(photo.filePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE2E8F0),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF64748B),
                    size: 32,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
            const Center(
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black45,
                child: Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => controller.removePhoto(photo.id),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        photo.source == 'Camera'
                            ? Icons.camera_alt_rounded
                            : Icons.photo_library_rounded,
                        color: Colors.amber,
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${photo.source} • ${photo.readableFileSize}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    photo.timestamp,
                    style: const TextStyle(fontSize: 8, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAttachedPhotoPreview(
    BuildContext context,
    UploadedPhotoModel photo,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.82,
                  minHeight: 320,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: Center(
                      child: Image.file(
                        File(photo.filePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Unable to preview this photo.',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton.filled(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${photo.source} • ${photo.readableFileSize} • ${photo.timestamp}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoPickerSourceSheet(
    BuildContext context,
    TaskCompletionController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Photo Proof',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You can preview and confirm the photo before it is attached. It will upload only after you submit the task.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: const Text(
                      'Take Photo with Camera',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Capture a new work-completion photo',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await controller.pickPhoto(
                        context,
                        ImageSource.camera,
                      );
                    },
                  ),
                ),
                const Divider(),
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: Colors.purple,
                      ),
                    ),
                    title: const Text(
                      'Choose Image from Device',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Select an existing image from the gallery',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await controller.pickPhoto(
                        context,
                        ImageSource.gallery,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChecklistSection(TaskCompletionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.fact_check_outlined, size: 18, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              "Completion Checklist",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Container(
        //   decoration: BoxDecoration(
        //     // color: Colors.white,
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(color: AppColors.textWhite),
        //   ),
        //   child: Obx(
        //     () => ListView.separated(
        //       shrinkWrap: true,
        //       physics: const NeverScrollableScrollPhysics(),
        //       itemCount: controller.checklist.length,
        //       separatorBuilder: (context, index) =>
        //           const Divider(height: 1, color: AppColors.textWhite),
        //       itemBuilder: (context, index) {
        //         final item = controller.checklist[index];
        //         return CheckboxListTile(
        //           value: item.isChecked,
        //           activeColor: AppColors.primary,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(6),
        //           ),
        //           title: Text(
        //             item.title,
        //             style: TextStyle(
        //               fontSize: 13,
        //               fontWeight: FontWeight.w600,
        //               color: item.isChecked
        //                   ? AppColors.primary
        //                   : AppColors.textSecondary,
        //               decoration: item.isChecked ? TextDecoration.none : null,
        //             ),
        //           ),
        //           onChanged: (val) => controller.toggleChecklist(index),
        //         );
        //       },
        //     ),
        //   ),
        // ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.textWhite),
          ),
          child: Material(
            color: Colors.transparent,
            child: Obx(
                  () => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.checklist.length,
                separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.textWhite),
                itemBuilder: (context, index) {
                  final item = controller.checklist[index];
                  return CheckboxListTile(
                    value: item.isChecked,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: item.isChecked
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        decoration: item.isChecked ? TextDecoration.none : null,
                      ),
                    ),
                    onChanged: (val) => controller.toggleChecklist(index),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(TaskCompletionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              "Resolution Remarks & Notes",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Quick Note Preset Chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.quickNotes.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final note = controller.quickNotes[index];
              return ActionChip(
                label: Text(note),
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () => controller.addQuickNote(note),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Notes Input Field
        TextField(
          controller: controller.notesController,
          maxLines: 3,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText:
                "Enter summary of work performed, tools used, or client notes...",
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.textWhite),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.textWhite),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    TaskCompletionController controller,
  ) {
    return Obx(
      () => Column(
        children: [
          if (controller.isSubmitting.value) ...[
            LinearProgressIndicator(
              value: controller.uploadProgress.value,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: Text(
                controller.uploadProgressText.value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () => controller.submitTaskCompletion(context),
              icon: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                controller.isSubmitting.value
                    ? 'Uploading Report...'
                    : 'Submit Task Completion',
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _CheckInOutCard extends StatelessWidget {
  final WorkOrderModel task;

  const _CheckInOutCard({
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskCompletionController>();

    return Obx(() {
      final sessions = controller.workSessions;
      final activeSession = controller.activeSession;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // HEADER
              // --------------------------------------------------
          
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Colors.blue,
                    ),
                  ),
          
                  const SizedBox(width: 12),
          
                  const Expanded(
                    child: Text(
                      'Work Sessions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          
                  if (activeSession != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: Colors.green,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          
              const SizedBox(height: 18),
          
              // --------------------------------------------------
              // SUMMARY
              // --------------------------------------------------
          
              Row(
                children: [
                  Expanded(
                    child: _SessionSummaryItem(
                      icon: Icons.layers_outlined,
                      title: 'Sessions',
                      value: '${controller.totalSessions}',
                    ),
                  ),
          
                  Expanded(
                    child: _SessionSummaryItem(
                      icon: Icons.check_circle_outline,
                      title: 'Completed',
                      value: '${controller.completedSessions}',
                    ),
                  ),
          
                  Expanded(
                    child: _SessionSummaryItem(
                      icon: Icons.timer_outlined,
                      title: 'Total Time',
                      value: _formatDuration(
                        controller.totalWorkedDuration,
                      ),
                    ),
                  ),
                ],
              ),
          
              const SizedBox(height: 18),
          
              // --------------------------------------------------
              // ACTIVE SESSION
              // --------------------------------------------------
          
              if (activeSession != null)
                _ActiveSessionCard(
                  session: activeSession,
                  onCheckOut: () {
                    _confirmCheckOut(
                      context,
                      controller,
                    );
                  },
                ),
          
              // --------------------------------------------------
              // SESSION HISTORY
              // --------------------------------------------------
          
              if (sessions.any(
                    (session) => session.checkOutDateTime != null,
              ))
                _SessionHistory(
                  sessions: sessions
                      .where(
                        (session) => session.checkOutDateTime != null,
                  )
                      .toList(),
                ),
          
              const SizedBox(height: 16),
          
              // --------------------------------------------------
              // CHECK IN / START NEW SESSION
              // --------------------------------------------------
          
              if (activeSession == null)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _confirmCheckIn(
                        context,
                        controller,
                      );
                    },
                    icon: const Icon(
                      Icons.login_rounded,
                    ),
                    label: Text(
                      sessions.isEmpty
                          ? 'Check In'
                          : 'Start New Session',
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  // ============================================================
  // CHECK-IN CONFIRMATION
  // ============================================================

  void _confirmCheckIn(
      BuildContext context,
      TaskCompletionController controller,
      ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Check-In'),
        content: const Text(
          'Are you sure you want to check in as the technician?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text('Check In'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.checkIn();
    }
  }

  // ============================================================
  // CHECK-OUT CONFIRMATION
  // ============================================================

  void _confirmCheckOut(
      BuildContext context,
      TaskCompletionController controller,
      ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Check-Out'),
        content: const Text(
          'Are you sure you want to check out from this session?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text('Check Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.checkOut();
    }
  }

  // ============================================================
  // DURATION FORMAT
  // ============================================================

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }
}

class _SessionSummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SessionSummaryItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 21,
          color: Colors.blueGrey,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _SessionTime extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SessionTime({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE9EEF5)),
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSessionCard extends StatelessWidget {
  final WorkSessionModel session;
  final VoidCallback onCheckOut;

  const _ActiveSessionCard({
    required this.session,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.green.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Current Session',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _formatDateTime(
                  session.checkInDateTime,
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.login_rounded,
                size: 18,
                color: Colors.green,
              ),
              const SizedBox(width: 6),
              Text(
                'Checked in at ${_formatTime(session.checkInDateTime)}',
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onCheckOut,
              icon: const Icon(
                Icons.logout_rounded,
              ),
              label: const Text(
                'Check Out',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(
                  color: Colors.red,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--';

    return DateFormat(
      'hh:mm a',
    ).format(dateTime);
  }

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';

    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(dateTime);
  }
}

class _SessionHistory extends StatelessWidget {
  final List<WorkSessionModel> sessions;

  const _SessionHistory({
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: true,
        title: const Text(
          'Session History',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        children: [
          ...sessions.asMap().entries.map(
                (entry) {
              final index = entry.key;
              final session = entry.value;

              return _SessionHistoryItem(
                sessionNumber: index + 1,
                session: session,
              );
            },
          ),
        ],
      ),
    );
  }
}
class _SessionHistoryItem extends StatelessWidget {
  final int sessionNumber;
  final WorkSessionModel session;

  const _SessionHistoryItem({
    required this.sessionNumber,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = session.isActive;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withOpacity(0.12)
                  : Colors.blue.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$sessionNumber',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Session $sessionNumber',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (isActive)
                      const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDateTime(
                        session.checkInDateTime,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 15,
                      color: isActive
                          ? Colors.grey
                          : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isActive
                          ? 'Still working'
                          : _formatDateTime(
                        session.checkOutDateTime,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive
                            ? Colors.green
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                if (!isActive && session.duration != null) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Duration: ${_formatDuration(session.duration!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';

    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(dateTime);
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }
}

//class _CheckInOutCardx extends StatelessWidget {
//   final WorkOrderModel task;
//   final TaskCompletionController completionController;
//
//   const _CheckInOutCard({
//     required this.task,
//     required this.completionController,
//   });
//
//   String _getDuration(DateTime? checkIn, DateTime? checkOut) {
//     if (checkIn == null) return "-";
//
//     final endTime = checkOut ?? DateTime.now();
//     final duration = endTime.difference(checkIn);
//
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//
//     if (hours > 0) {
//       return "${hours}h ${minutes}m";
//     }
//
//     return "${minutes}m";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final checkIn = completionController.checkInTime.value;
//       final checkOut = completionController.checkOutTime.value;
//
//       final isCheckedIn = checkIn != null;
//       final isCheckedOut = checkOut != null;
//
//       final statusColor = isCheckedOut
//           ? Colors.green
//           : isCheckedIn
//           ? Colors.orange
//           : AppColors.primary;
//
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: statusColor.withOpacity(.06),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: statusColor.withOpacity(.14)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Container(
//                   height: 42,
//                   width: 42,
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(.12),
//                     borderRadius: BorderRadius.circular(13),
//                   ),
//                   child: Icon(
//                     isCheckedOut
//                         ? Icons.task_alt_rounded
//                         : isCheckedIn
//                         ? Icons.timer_rounded
//                         : Icons.access_time_rounded,
//                     color: statusColor,
//                     size: 21,
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Work Session",
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w800,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         isCheckedOut
//                             ? "Work session completed"
//                             : isCheckedIn
//                             ? "You are currently checked in"
//                             : "Check in to start working",
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 9,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(.10),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     isCheckedOut
//                         ? "COMPLETED"
//                         : isCheckedIn
//                         ? "ACTIVE"
//                         : "NOT STARTED",
//                     style: TextStyle(
//                       fontSize: 9,
//                       fontWeight: FontWeight.w800,
//                       color: statusColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 18),
//
//             // Check In / Check Out times
//             Row(
//               children: [
//                 Expanded(
//                   child: _SessionTime(
//                     icon: Icons.login_rounded,
//                     title: "CHECK IN",
//                     value: Common.formatToLocalUS(checkIn.toString()),
//                     color: Colors.green,
//
//                   ),
//                 ),
//
//                 const SizedBox(width: 10),
//
//                 Expanded(
//                   child: _SessionTime(
//                     icon: Icons.logout_rounded,
//                     title: "CHECK OUT",
//                     value: Common.formatToLocalUS(checkOut.toString()),
//                     color: AppColors.error,
//                   ),
//                 ),
//               ],
//             ),
//
//             if (isCheckedIn) ...[
//               const SizedBox(height: 10),
//
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 13,
//                   vertical: 11,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(13),
//                   border: Border.all(color: const Color(0xffE9EEF5)),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.timer_outlined,
//                       size: 18,
//                       color: AppColors.primary,
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       "Duration",
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       _getDuration(checkIn, checkOut),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//
//             const SizedBox(height: 14),
//
//             if (!isCheckedIn)
//               _sessionButton(
//                 title: "Check In",
//                 icon: Icons.login_rounded,
//                 color: AppColors.primary,
//                 onPressed: () => _confirmCheckIn(context),
//               )
//             else if (!isCheckedOut)
//               _sessionButton(
//                 title: "Check Out",
//                 icon: Icons.logout_rounded,
//                 color: AppColors.error,
//                   onPressed: () => _confirmCheckOut(context),
//               )
//             else
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 13),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(.08),
//                   borderRadius: BorderRadius.circular(13),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.check_circle_rounded,
//                       size: 19,
//                       color: Colors.green,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       "Work Session Completed",
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w800,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }
//
//   Widget _sessionButton({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       height: 46,
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon, size: 19, color: Colors.white),
//         label: Text(
//           title,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w800,
//             color: Colors.white,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(13),
//           ),
//         ),
//       ),
//     );
//   }
//   Future<void>_confirmCheckIn(BuildContext context) async {
//     final confirmed = await Get.dialog<bool>(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
//         contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
//         actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         title: Row(
//           children: [
//             Container(
//               height: 42,
//               width: 42,
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(.10),
//                 borderRadius: BorderRadius.circular(13),
//               ),
//               child: const Icon(
//                 Icons.login_rounded,
//                 color: AppColors.primary,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Text(
//                 "Confirm Check In",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           "Are you ready to start working on this task?\n\n"
//               "Your check-in time will be recorded when you confirm.",
//           style: TextStyle(
//             fontSize: 13,
//             height: 1.5,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back(result: false);
//             },
//             child: Text(
//               "Cancel",
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               Get.back(result: true);
//             },
//             icon: const Icon(
//               Icons.check_rounded,
//               size: 18,
//             ),
//             label: const Text("Yes, Check In"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       completionController.checkIn();
//     }
//   }
//   Future<void> _confirmCheckOut(BuildContext context) async {
//     final confirmed = await Get.dialog<bool>(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
//         contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
//         actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//
//         title: Row(
//           children: [
//             Container(
//               height: 42,
//               width: 42,
//               decoration: BoxDecoration(
//                 color: AppColors.error.withOpacity(.10),
//                 borderRadius: BorderRadius.circular(13),
//               ),
//               child: const Icon(
//                 Icons.logout_rounded,
//                 color: AppColors.error,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Text(
//                 "Confirm Check Out",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         content: Text(
//           "Are you sure you want to check out from this task?\n\n"
//               "Your work session will be completed and the check-out time will be recorded.",
//           style: TextStyle(
//             fontSize: 13,
//             height: 1.5,
//             color: Colors.grey.shade700,
//           ),
//         ),
//
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.back(result: false);
//             },
//             child: Text(
//               "Cancel",
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ),
//
//           ElevatedButton.icon(
//             onPressed: () {
//               Get.back(result: true);
//             },
//             icon: const Icon(
//               Icons.logout_rounded,
//               size: 18,
//             ),
//             label: const Text("Yes, Check Out"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.error,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       completionController.checkOut();
//     }
//   }
// }
