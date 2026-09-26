import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:taskpro/common/helpers/app_helper.dart';
import 'package:taskpro/common/models/work_order_model.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_controller.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_models.dart';
import 'package:taskpro/theme/app_colors.dart';

import '../../../common/models/work_session_model.dart';
import '../tasks/w_tasks_controller.dart';

class TaskCompletionScreen extends StatelessWidget {
  final WorkOrderModel task;

  const TaskCompletionScreen({super.key, required this.task});

  static const Color _background = Color(0xFFF7F9FC);
  static const Color _card = Colors.white;
  static const Color _text = Color(0xFF172033);
  static const Color _muted = Color(0xFF718096);
  static const Color _border = Color(0xFFE8EDF4);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _green = Color(0xFF16A34A);
  static const Color _red = Color(0xFFDC2626);

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageIntro(),

              const SizedBox(height: 18),

              _CheckInOutCard(task: task),

              Obx(
                () => completionController.isCheckedIn
                    ? Column(
                        children: [
                          const SizedBox(height: 16),

                          _buildTaskSummaryCard(completionController),

                          const SizedBox(height: 16),

                          _buildImageUploadSection(
                            context,
                            completionController,
                          ),

                          const SizedBox(height: 16),

                          _buildChecklistSection(completionController),

                          const SizedBox(height: 16),

                          _buildNotesSection(completionController),

                          const SizedBox(height: 20),

                          _buildSubmitButton(context, completionController),

                          const SizedBox(height: 12),
                        ],
                      )
                    : const SizedBox(),
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

  Widget _buildPageIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: .18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.assignment_turned_in_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finish your work order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Record your work, attach proof and submit the completion report.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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

  Widget _buildChecklistSection(TaskCompletionController controller) {
    return _ModernCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
            child: _sectionHeader(
              icon: Icons.fact_check_outlined,
              title: 'Completion Checklist',
              subtitle: 'Verify each item before submitting',
            ),
          ),

          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.checklist.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: _border),
              itemBuilder: (context, index) {
                final item = controller.checklist[index];

                return InkWell(
                  onTap: () => controller.toggleChecklist(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: item.isChecked ? _blue : Colors.white,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: item.isChecked
                                  ? _blue
                                  : const Color(0xFFD5DCE7),
                              width: 1.5,
                            ),
                          ),
                          child: item.isChecked
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: item.isChecked
                                  ? _text
                                  : const Color(0xFF526174),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          item.isChecked
                              ? Icons.verified_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 18,
                          color: item.isChecked
                              ? _green
                              : const Color(0xFFCBD5E1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),
        ],
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
            title: 'Resolution Notes',
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

// ============================================================
// WORK SESSIONS
// ============================================================

class _CheckInOutCard extends StatelessWidget {
  final WorkOrderModel task;

  const _CheckInOutCard({required this.task});

  static const Color _blue = Color(0xFF2563EB);
  static const Color _green = Color(0xFF16A34A);
  static const Color _red = Color(0xFFDC2626);
  static const Color _text = Color(0xFF172033);
  static const Color _muted = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskCompletionController>();

    return Obx(() {
      final sessions = controller.workSessions;
      final activeSession = controller.activeSession;

      return _ModernSessionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    color: _blue,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Sessions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Track your time on this work order',
                        style: TextStyle(fontSize: 10.5, color: _muted),
                      ),
                    ],
                  ),
                ),

                if (activeSession != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7, color: _green),
                        SizedBox(width: 5),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: _green,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            _buildSummary(controller),

            if (activeSession != null) ...[
              const SizedBox(height: 16),
              _ActiveSessionCard(
                session: activeSession,
                onCheckOut: () {
                  _confirmCheckOut(context, controller);
                },
              ),
            ],

            if (sessions.any(
              (session) => session.checkOutDateTime != null,
            )) ...[
              const SizedBox(height: 6),
              _SessionHistory(
                sessions: sessions
                    .where((session) => session.checkOutDateTime != null)
                    .toList(),
              ),
            ],

            const SizedBox(height: 15),

            if (activeSession == null && task.statusId == 59)
              findButton(
                title: sessions.isEmpty ? 'Check In' : 'Start New Session',
                icon: Icon(Icons.login_rounded, size: 19,color: AppColors.textWhite,),
                backgroundColor: AppColors.primary,
                onPressed:()=>_confirmCheckIn(context, controller)
              ),
           ],
        ),
      );
    });
  }

  Widget _buildSummary(TaskCompletionController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SessionSummaryItem(
              icon: Icons.layers_outlined,
              title: 'Sessions',
              value: '${controller.totalSessions}',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _SessionSummaryItem(
              icon: Icons.check_circle_outline_rounded,
              title: 'Completed',
              value: '${controller.completedSessions}',
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _SessionSummaryItem(
              icon: Icons.timer_outlined,
              title: 'Total Time',
              value: _formatDuration(controller.totalWorkedDuration),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 38, color: const Color(0xFFE1E7EF));
  }

  Future<void> _confirmCheckIn(
    BuildContext context,
    TaskCompletionController controller,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
        contentPadding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.login_rounded, color: _blue),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text(
                'Confirm Check-In',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you ready to start working on this task?\n\n'
          'Your check-in time will be recorded when you confirm.',
          style: TextStyle(fontSize: 12.5, height: 1.5, color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.check_rounded, size: 17),
            label: const Text('Yes, Check In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.checkIn();
    }
  }

  Future<void> _confirmCheckOut(
    BuildContext context,
    TaskCompletionController controller,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
        contentPadding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _red.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.logout_rounded, color: _red),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text(
                'Confirm Check-Out',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to check out from this session?\n\n'
          'Your work session will be completed and the check-out time will be recorded.',
          style: TextStyle(fontSize: 12.5, height: 1.5, color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.logout_rounded, size: 17),
            label: const Text('Yes, Check Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.checkOut();
    }
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

// ============================================================
// SESSION CONTAINER
// ============================================================

class _ModernSessionContainer extends StatelessWidget {
  final Widget child;

  const _ModernSessionContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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

// ============================================================
// SESSION SUMMARY ITEM
// ============================================================

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
        Icon(icon, size: 19, color: const Color(0xFF64748B)),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9.5,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ACTIVE SESSION
// ============================================================

class _ActiveSessionCard extends StatelessWidget {
  final WorkSessionModel session;
  final VoidCallback onCheckOut;

  const _ActiveSessionCard({required this.session, required this.onCheckOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF0FDF4), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF16A34A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Session',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'You are currently working',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.login_rounded,
                  size: 17,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 7),
                const Text(
                  'Checked in',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(session.checkInDateTime),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF172033),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 11),

          SizedBox(
            width: double.infinity,
            height: 45,
            child: OutlinedButton.icon(
              onPressed: onCheckOut,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Check Out',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: BorderSide(
                  color: const Color(0xFFDC2626).withValues(alpha: .35),
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';

    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
}

// ============================================================
// SESSION HISTORY
// ============================================================

class _SessionHistory extends StatelessWidget {
  final List<WorkSessionModel> sessions;

  const _SessionHistory({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 2),
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        iconColor: const Color(0xFF64748B),
        collapsedIconColor: const Color(0xFF64748B),
        title: const Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: Color(0xFF64748B)),
            SizedBox(width: 8),
            Text(
              'Session History',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),
          ],
        ),
        children: [
          const SizedBox(height: 4),
          ...sessions.asMap().entries.map((entry) {
            return _SessionHistoryItem(
              sessionNumber: entry.key + 1,
              session: entry.value,
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// SESSION HISTORY ITEM
// ============================================================

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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$sessionNumber',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: isActive
                    ? const Color(0xFF15803D)
                    : const Color(0xFF2563EB),
              ),
            ),
          ),

          const SizedBox(width: 11),

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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172033),
                        ),
                      ),
                    ),
                    if (isActive)
                      const Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 9),

                _historyRow(
                  Icons.login_rounded,
                  _formatDateTime(session.checkInDateTime),
                  const Color(0xFF16A34A),
                ),

                const SizedBox(height: 5),

                _historyRow(
                  Icons.logout_rounded,
                  isActive
                      ? 'Still working'
                      : _formatDateTime(session.checkOutDateTime),
                  isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),

                if (!isActive && session.duration != null) ...[
                  const SizedBox(height: 5),
                  _historyRow(
                    Icons.timer_outlined,
                    'Duration: ${_formatDuration(session.duration!)}',
                    const Color(0xFF64748B),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';

    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
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
