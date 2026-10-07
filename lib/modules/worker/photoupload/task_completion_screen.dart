import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_controller.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_models.dart';
import 'package:taskpro/theme/app_colors.dart';

import '../tasks/w_tasks_controller.dart';

class TaskCompletionScreen extends StatelessWidget {
  final WorkOrderModel task;

  const TaskCompletionScreen({super.key, required this.task});

  static const Color _background = AppColors.background;
  static const Color _text = AppColors.textPrimary;
  static const Color _muted = AppColors.textHint;
  static const Color _border = AppColors.accent;
  static const Color _blue = AppColors.primary;
  static const Color _green = AppColors.success;


  @override
  Widget build(BuildContext context) {
    final completionController = Get.put(TaskCompletionController(task: task));

    Get.put(WorkerTasksController());

    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Column(
                children: [
                  const SizedBox(height: 16),

                  _buildTaskSummaryCard(completionController),

                  const SizedBox(height: 16),

                  _buildImageUploadSection(
                    context,
                    completionController,
                  ),

                  const SizedBox(height: 16),


                  _buildChecklistSection1(completionController),

                  const SizedBox(height: 16),

                  _buildNotesSection(completionController),

                  const SizedBox(height: 16),

                  _buildGetSignature(completionController),

                  const SizedBox(height: 20),

                  _buildSubmitButton(context, completionController),

                  const SizedBox(height: 12),
                ],
              ),



            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 68,
      leadingWidth: 58,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () => Get.back(),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _text,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      titleSpacing: 8,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete Work Order',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'WO No. ${task.workOrderNo}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTaskSummaryCard(TaskCompletionController controller) {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.assignment_outlined, _blue),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Work Order Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
              _statusBadge('IN PROGRESS', Colors.amber),
            ],
          ),

          const SizedBox(height: 18),

          Obx(
            () => Text(
              controller.taskTitle.value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _text,
                letterSpacing: -.3,
              ),
            ),
          ),

          const SizedBox(height: 14),

          _infoRow(Icons.location_on_outlined, controller.taskLocation),

          const SizedBox(height: 9),

          _infoRow(
            Icons.person_outline_rounded,
            controller.workerName,
            prefix: 'Assigned to ',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, RxString value, {String prefix = ''}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: _blue),
        const SizedBox(width: 8),
        Expanded(
          child: Obx(
            () => Text(
              '$prefix${value.value}',
              style: const TextStyle(
                fontSize: 12,
                color: _muted,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(
    BuildContext context,
    TaskCompletionController controller,
  ) {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.photo_camera_outlined,
            title: 'Proof of Work',
            subtitle: 'Attach photos showing completed work',
            trailing: Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.uploadedPhotos.length}/4',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _blue,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.12,
              ),
              itemCount:
                  controller.uploadedPhotos.length +
                  (controller.uploadedPhotos.length < 4 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.uploadedPhotos.length) {
                  return _buildAddPhotoButton(context, controller);
                }

                return _buildPhotoTile(
                  context,
                  controller.uploadedPhotos[index],
                  controller,
                );
              },
            ),
          ),

          Obx(
            () => controller.uploadedPhotos.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'At least one photo is required before submission.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton(
    BuildContext context,
    TaskCompletionController controller,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _showPhotoPickerSourceSheet(context, controller),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7FF),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFBDD2FF), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withValues(alpha: .22),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add Photo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _blue,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Camera or Gallery',
                style: TextStyle(fontSize: 10, color: _muted),
              ),
            ],
          ),
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
      borderRadius: BorderRadius.circular(17),
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
                  color: const Color(0xFFE9EEF5),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: _muted,
                      size: 30,
                    ),
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
                    Colors.black.withValues(alpha: .15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: .78),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => controller.removePhoto(photo.id),
                child: Container(
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .55),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: .25)),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ),

            Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: .3)),
                ),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        photo.source == 'Camera'
                            ? Icons.camera_alt_rounded
                            : Icons.photo_library_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${photo.source} • ${photo.readableFileSize}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
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


  Widget _buildNotesSection(TaskCompletionController controller) {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            icon: Icons.edit_note_rounded,
            title: 'Custom Notes',
            subtitle: 'Add a short summary of the completed work',
          ),

          const SizedBox(height: 15),

          const Text(
            'QUICK NOTES',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: _muted,
              letterSpacing: .8,
            ),
          ),

          const SizedBox(height: 9),

          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.quickNotes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final note = controller.quickNotes[index];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => controller.addQuickNote(note),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD9E5FF)),
                      ),
                      child: Text(
                        note,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 13),

          TextField(
            controller: controller.notesController,
            maxLines: 5,
            minLines: 4,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
              fontSize: 13,
              color: _text,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText:
                  'Describe the work performed, tools used, findings or client notes...',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9AA6B6),
                height: 1.4,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _blue, width: 1.4),
              ),
            ),
          ),
        ],
      ),
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.uploadProgressText.value,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _text,
                          ),
                        ),
                      ),
                      Text(
                        '${(controller.uploadProgress.value * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: controller.uploadProgress.value,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE8EEF7),
                      color: _blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () => controller.submitTaskCompletion(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                disabledBackgroundColor: _blue.withValues(alpha: .55),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: _blue.withValues(alpha: .25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: controller.isSubmitting.value
                    ? const Row(
                        key: ValueKey('uploading'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Uploading Report...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        key: ValueKey('submit'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 21),
                          SizedBox(width: 9),
                          Text(
                            'Submit Task Completion',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your photos and completion details will be submitted together.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconBox(icon, _blue),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _statusBadge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: color.shade800,
          letterSpacing: .3,
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
      barrierColor: Colors.black.withValues(alpha: .92),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * .84,
                  minHeight: 320,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: Center(
                      child: Image.file(
                        File(photo.filePath),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
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
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .65),
                    borderRadius: BorderRadius.circular(14),
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
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
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
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8DEE8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Add Photo Proof',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Choose how you want to add proof of your completed work.',
                  style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
                ),

                const SizedBox(height: 20),

                _photoSourceOption(
                  icon: Icons.camera_alt_rounded,
                  color: _blue,
                  title: 'Take a Photo',
                  subtitle: 'Capture a new work-completion photo',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await controller.pickPhoto(context, ImageSource.camera);
                  },
                ),

                const SizedBox(height: 10),

                _photoSourceOption(
                  icon: Icons.photo_library_rounded,
                  color: const Color(0xFF7C3AED),
                  title: 'Choose from Gallery',
                  subtitle: 'Select an existing image from your device',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await controller.pickPhoto(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photoSourceOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10.5, color: _muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  _buildGetSignature(completionController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final hasSignature =
            completionController.signatureBase64.value != null &&
                completionController.signatureBase64.value!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.draw_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Technician Signature',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasSignature
                            ? 'Signature has been added'
                            : 'Please add a signature',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasSignature
                              ? Colors.green.shade600
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Add / Change button
                OutlinedButton.icon(
                  onPressed: () {
                    completionController.captureSignature();
                  },
                  icon: Icon(
                    hasSignature
                        ? Icons.edit_rounded
                        : Icons.add_rounded,
                    size: 17,
                  ),
                  label: Text(
                    hasSignature ? 'Change' : 'Add',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Signature Image
            if (hasSignature)
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      // Signature
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.memory(
                            base64Decode(
                              completionController
                                  .signatureBase64
                                  .value!,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Small "Signed" badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.shade100,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Signed',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
            // Empty Signature Area
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    completionController.captureSignature();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.draw_outlined,
                        size: 34,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No signature added',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Add" to sign',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildChecklistSection1(
      TaskCompletionController controller,
      ) {
    return Obx(() {
      final items = controller.sowItems;

      final preInstallItems = items
          .where((e) => e.type == 'pre_install')
          .toList()
        ..sort(
              (a, b) => a.sortOrder.compareTo(b.sortOrder),
        );

      final installItems = items
          .where((e) => e.type == 'install')
          .toList()
        ..sort(
              (a, b) => a.sortOrder.compareTo(b.sortOrder),
        );

      final total = items.length;

      final completed =
          items.where((e) => e.status == 1).length;

      final progress = total == 0 ? 0.0 : completed / total;

      if (total == 0) {
        return _ModernCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: _blue,
                  size: 26,
                ),
              ),

              const SizedBox(height: 13),

              const Text(
                "No Scope of Work",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "No checklist or specific work instructions have been assigned to this work order.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  color: Color(0xFF7A869A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return _ModernCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // ========================================================
            // MAIN HEADER
            // ========================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fact_check_outlined,
                          color: _blue,
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 11),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Scope of Work",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _text,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Complete all required work before submitting",
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF7A869A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // TOTAL PROGRESS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: completed == total
                              ? const Color(0xFFE8F7EF)
                              : const Color(0xFFEAF3FC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              completed == total
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_actions_rounded,
                              size: 13,
                              color: completed == total
                                  ? _green
                                  : _blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$completed/$total",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: completed == total
                                    ? _green
                                    : _blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // OVERALL PROGRESS
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor:
                            const Color(0xFFE9EDF3),
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                              completed == total
                                  ? _green
                                  : _blue,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      SizedBox(
                        width: 34,
                        child: Text(
                          "${(progress * 100).round()}%",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: completed == total
                                ? _green
                                : _blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              color: _border,
            ),

            // ========================================================
            // PRE INSTALLATION
            // ========================================================

            if (preInstallItems.isNotEmpty)
              _buildSowGroup(
                controller: controller,
                title: "Pre-Installation",
                subtitle: "Complete before starting installation",
                icon: Icons.assignment_outlined,
                items: preInstallItems,
              ),

            // ========================================================
            // INSTALLATION
            // ========================================================

            if (installItems.isNotEmpty) ...[
              if (preInstallItems.isNotEmpty)
                const Divider(
                  height: 1,
                  color: _border,
                ),

              _buildSowGroup(
                controller: controller,
                title: "Installation & Testing",
                subtitle: controller.isPreInstallationCompleted
                    ? "Complete during onsite work"
                    : "Complete Pre-Installation first",
                icon: controller.isPreInstallationCompleted
                    ? Icons.handyman_outlined
                    : Icons.lock_outline_rounded,
                items: installItems,
                isLocked: !controller.isPreInstallationCompleted,
              ),
            ],

            const SizedBox(height: 5),
          ],
        ),
      );
    });
  }




  Widget _buildSowGroup({
    required TaskCompletionController controller,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<SowItemModel> items,
    bool isLocked = false,
  }) {
    final completed =
        items.where((e) => e.status == 1).length;

    final bool allCompleted =
        completed == items.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // GROUP HEADER
          // ========================================================

          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: allCompleted
                      ? const Color(0xFFE9F8F0)
                      : const Color(0xFFF1F5FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  allCompleted
                      ? Icons.check_rounded
                      : icon,
                  size: 18,
                  color:
                  allCompleted ? _green : _blue,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8993A4),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: allCompleted
                      ? const Color(0xFFE9F8F0)
                      : const Color(0xFFF1F5FA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "$completed/${items.length}",
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color:
                    allCompleted ? _green : _blue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // ========================================================
          // SOW ITEMS
          // ========================================================

          ...List.generate(
            items.length,
                (index) {
              final item = items[index];

              return _buildSowChecklistItem(
                controller: controller,
                item: item,
                index: index,
                isLast: index == items.length - 1,
                isLocked: isLocked,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSowChecklistItem({
    required TaskCompletionController controller,
    required SowItemModel item,
    required int index,
    required bool isLast,
    bool isLocked = false,
  }) {
    final bool checked = item.status == 1;

    return Opacity(
      opacity: isLocked ? 0.55 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLocked
            ? () {
          Get.snackbar(
            'Installation Locked',
            'Complete all Pre-Installation items first.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            icon: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
            ),
          );
        }
            : () async{
          await controller.toggleSowItem(item);
        },
      
        child: Container(
          margin: EdgeInsets.only(
            bottom: isLast ? 0 : 8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: checked
                ? const Color(0xFFF5FBF8)
                : const Color(0xFFFAFBFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: checked
                  ? const Color(0xFFCDECDD)
                  : const Color(0xFFE6EAF0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // CHECKBOX
              // ======================================================
      
              AnimatedContainer(
                duration:
                const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: checked
                      ? _green
                      : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: checked
                        ? _green
                        : const Color(0xFFC7D0DC),
                    width: 1.5,
                  ),
                ),
                child: checked
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                )
                    : null,
              ),
      
              const SizedBox(width: 11),
      
              // ======================================================
              // DESCRIPTION
              // ======================================================
      
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: checked
                            ? const Color(0xFF536171)
                            : _text,
                      ),
                    ),
      
                    // COMPLETED STATUS
                    if (checked) ...[
                      const SizedBox(height: 6),
      
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: _green,
                          ),
      
                          const SizedBox(width: 4),
      
                          const Text(
                            "Completed",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _green,
                            ),
                          ),
      
                          if (item.completedAt != null) ...[
                            const SizedBox(width: 5),
      
                            const Text(
                              "•",
                              style: TextStyle(
                                color: Color(0xFF9AA4B2),
                                fontSize: 9,
                              ),
                            ),
      
                            const SizedBox(width: 5),
      
                            Flexible(
                              child: Text(
                                _formatSowDate(
                                  item.completedAt!,
                                ),
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight:
                                  FontWeight.w500,
                                  color:
                                  Color(0xFF8993A4),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
      
              const SizedBox(width: 8),
      
              // ======================================================
              // STATUS
              // ======================================================
      
              Icon(
                checked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: checked
                    ? _green
                    : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSowDate(DateTime date) {
    final d = date.toLocal();

    String two(int value) =>
        value.toString().padLeft(2, '0');

    return "${two(d.day)}/${two(d.month)}/${d.year} "
        "${two(d.hour)}:${two(d.minute)}";
  }
}

// ============================================================
// MODERN CARD
// ============================================================

class _ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ModernCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EDF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}