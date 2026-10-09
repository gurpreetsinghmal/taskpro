import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taskpro/modules/worker/checkin/checkin_controller.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/helpers/app_helper.dart';
import '../../../common/models/work_order_model.dart';
import '../../../common/models/work_session_model.dart';
import '../../../services/secure_storage_service.dart';
import '../../../theme/app_colors.dart';

class CheckInScreen extends StatelessWidget {
  final WorkOrderModel task;

  const CheckInScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckinController(task: task));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorkOrderHeader(controller, context),
              const SizedBox(height: 14),
              _CheckInOutCard(task: task, controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // APP BAR
  // ==========================================================

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF5F7FB),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 68,
      leadingWidth: 58,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Get.back(),
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF172033),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      titleSpacing: 8,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work Tracking',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172033),
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Manage your check-in and work time',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WORK ORDER HEADER
  // ==========================================================

  Widget _buildWorkOrderHeader(
    CheckinController controller,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: .20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .12),
                  ),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WORK ORDER',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.workOrderNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info, size: 13, color: Colors.white),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: () {
                        WorkOrderDetailsModal.show(context, task);
                      },
                      child: Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHECK IN / CHECK OUT
// ============================================================

class _CheckInOutCard extends StatelessWidget {
  final WorkOrderModel task;
  final CheckinController controller;

  const _CheckInOutCard({required this.task, required this.controller});

  static const Color _blue = Color(0xFF2563EB);
  static const Color _green = Color(0xFF16A34A);
  static const Color _red = Color(0xFFDC2626);
  static const Color _text = Color(0xFF172033);
  static const Color _muted = Color(0xFF718096);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sessions = controller.workSessions;
      final activeSession = controller.activeSession;

      final completedSessions = sessions
          .where((session) => session.checkOutDateTime != null)
          .toList();

      return Column(
        children: [
          // ==================================================
          // CURRENT STATUS CARD
          // ==================================================

          findButton(
            title: 'Navigate to Location',
            icon: Icon(Icons.location_on_outlined, color: Colors.white),
            onPressed: () => _openGoogleMaps(task.address!.googleMapLink),
            backgroundColor: AppColors.success,
            textColor: AppColors.textWhite,
          ),

          const SizedBox(height: 12),

          // ==================================================
          // GO TO SITE
          // ==================================================
          if (controller.isCheckedIn) ...[
            _buildworkCompletionCheckList(),
            const SizedBox(height: 12),
          ],

          // ==================================================
          // SESSION SUMMARY
          // ==================================================
          _buildSummary(controller),

          // ==================================================
          // ACTIVE SESSION
          // ==================================================
          if (activeSession != null) ...[
            const SizedBox(height: 12),
            _ActiveSessionCard(
              session: activeSession,
              onCheckOut: () {
                _confirmCheckOut(context, controller);
              },
            ),
          ],

          // ==================================================
          // HISTORY
          // ==================================================
          if (completedSessions.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SessionHistory(sessions: completedSessions),
          ],

          // ==================================================
          // CHECK IN
          // ==================================================
          if (activeSession == null && task.statusId == 59) ...[
            const SizedBox(height: 14),
            _buildCheckInButton(context),
          ],
        ],
      );
    });
  }

  // ==========================================================
  // STATUS CARD
  // ==========================================================

  // ==========================================================
  // GO TO SITE
  // ==========================================================

  Widget _buildworkCompletionCheckList() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172033).withValues(alpha: .12),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: findButton(
        title: "Work Completion Check List",
        onPressed: () {
          Get.to(() => TaskCompletionScreen(task: controller.task));
        },
        backgroundColor: const Color(0xFF172033),
        icon: const Icon(
          Icons.navigation_rounded,
          size: 19,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _buildSummary(CheckinController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SessionSummaryItem(
              icon: Icons.layers_outlined,
              title: 'Sessions',
              value: '${controller.totalSessions}',
              color: _blue,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _SessionSummaryItem(
              icon: Icons.check_circle_outline_rounded,
              title: 'Completed',
              value: '${controller.completedSessions}',
              color: _green,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _SessionSummaryItem(
              icon: Icons.timer_outlined,
              title: 'Total Time',
              value: _formatDuration(controller.totalWorkedDuration),
              color: const Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 42, color: const Color(0xFFE5EAF1));
  }

  // ==========================================================
  // CHECK IN BUTTON
  // ==========================================================

  Widget _buildCheckInButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: .20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: findButton(
        title: controller.workSessions.isEmpty
            ? 'Check In'
            : 'Start New Check In',
        icon: const Icon(Icons.login_rounded, size: 20, color: Colors.white),
        backgroundColor: _blue,
        onPressed: () async{
          final storage = SecureStorageService.instance;
          int? id=await storage.isAlreadyCheckIn();
          if(id!=null && id!=task.id){
            Get.snackbar(
              'Already Checked In',
              'You are Already Checked In for Other Work Order, First Checked Out to Start Work',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
            return;
          }
          _confirmCheckIn(context, controller);
        },
      ),
    );
  }

  // ==========================================================
  // CONFIRM CHECK IN
  // ==========================================================

  Future<void> _confirmCheckIn(
    BuildContext context,
    CheckinController controller,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
        contentPadding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.login_rounded, color: _blue, size: 22),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text(
                'Start Work ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you ready to start working on this work order?\n\n'
              'Your check-in time will be recorded when you confirm.',
              style: TextStyle(fontSize: 12.5, height: 1.5, color: _muted),
            ),
            SizedBox(height: 12,),
             _buildGetSignature(controller, controller.signatureBase64CheckIn),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _muted,
              ),
            ),
          ),

          Obx(() {
            final hasSignature =
                controller.signatureBase64CheckIn.value?.isNotEmpty ?? false;

            if (!hasSignature) {
              return const SizedBox.shrink();
            }

            return ElevatedButton.icon(
              onPressed: () => Get.back(result: true),
              icon: const Icon(
                Icons.play_arrow_rounded,
                size: 18,
              ),
              label: const Text(
                'Start',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            );
          }),
        ],
      ),
    );

    if (confirmed == true) {
      controller.checkIn();
    }
  }

  // ==========================================================
  // CONFIRM CHECK OUT
  // ==========================================================

  Future<void> _confirmCheckOut(
    BuildContext context,
    CheckinController controller,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
        contentPadding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _red.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.logout_rounded, color: _red, size: 22),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Text(
                'End Work ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to check out from this session?\n\n'
              'Your work session will be completed and the check-out time will be recorded.',
              style: TextStyle(fontSize: 12.5, height: 1.5, color: _muted),
            ),
            SizedBox(height: 12,),
            _buildGetSignature(controller, controller.signatureBase64CheckOut),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w700, color: _muted),
            ),
          ),
          Obx(() {
            final hasSignature =
                controller.signatureBase64CheckOut.value?.isNotEmpty ?? false;

            if (!hasSignature) {
              return const SizedBox.shrink();
            }

            return ElevatedButton.icon(
              onPressed: () => Get.back(result: true),
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
              ),
              label: const Text(
                'Check Out',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            );
          }),
          ],
      ),
    );

    if (confirmed == true) {
      controller.checkOut();
    }
  }

  static String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    }

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }

  static Future<void> _openGoogleMaps(String address) async {
    final Uri googleMapsUri;

    googleMapsUri = Uri.parse(address);

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  _buildGetSignature(CheckinController controller, RxnString signatureBase64) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
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
            signatureBase64.value != null && signatureBase64.value!.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Representative Signature',
                        style: TextStyle(
                          fontSize: 12,
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
                    controller.captureSignature(signatureBase64);
                  },
                  icon: Icon(
                    hasSignature ? Icons.edit_rounded : Icons.add_rounded,
                    size: 17,
                  ),
                  label: Text(hasSignature ? 'Change' : 'Add'),
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
                  border: Border.all(color: Colors.grey.shade200),
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
                            base64Decode(signatureBase64.value!),
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
                            border: Border.all(color: Colors.green.shade100),
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
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    controller.captureSignature(signatureBase64);
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
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SESSION CONTAINER
// ============================================================

// ============================================================
// SESSION SUMMARY ITEM
// ============================================================

class _SessionSummaryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SessionSummaryItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF16A34A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Work Tracking',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF172033),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your work session is currently active',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
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

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.login_rounded,
                    size: 16,
                    color: Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Checked in at',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatDateTime(session.checkInDateTime),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF172033),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 11),

          SizedBox(
            width: double.infinity,
            height: 47,
            child: OutlinedButton.icon(
              onPressed: onCheckOut,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Check Out',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: const Color(0xFFDC2626).withValues(alpha: .30),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          initiallyExpanded: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          iconColor: const Color(0xFF64748B),
          collapsedIconColor: const Color(0xFF64748B),
          title: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 19,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session History',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF172033),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Previous Work Track',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${sessions.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          children: [
            ...sessions.asMap().entries.map((entry) {
              return _SessionHistoryItem(
                sessionNumber: entry.key + 1,
                session: entry.value,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SESSION HISTORY ITEM
// ============================================================

// class _SessionHistoryItem extends StatelessWidget {
//   final int sessionNumber;
//   final WorkSessionModel session;
//
//   const _SessionHistoryItem({
//     required this.sessionNumber,
//     required this.session,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isActive = session.isActive;
//
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: const Color(0xFFE8EDF4),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Session number
//           Container(
//             width: 35,
//             height: 35,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: isActive
//                   ? const Color(0xFFDCFCE7)
//                   : const Color(0xFFEFF6FF),
//               shape: BoxShape.circle,
//             ),
//             child: Text(
//               '${session.checkInLatitude}${session.checkInLongitude}',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w900,
//                 color: isActive
//                     ? const Color(0xFF15803D)
//                     : const Color(0xFF2563EB),
//               ),
//             ),
//           ),
//
//           const SizedBox(width: 11),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Work Track $sessionNumber',
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w900,
//                           color: Color(0xFF172033),
//                         ),
//                       ),
//                     ),
//                     if (isActive)
//                       const _StatusBadge(
//                         text: 'ACTIVE',
//                         color: Color(0xFF16A34A),
//                       ),
//                   ],
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 _historyRow(
//                   Icons.login_rounded,
//                   _formatDateTime(
//                     session.checkInDateTime,
//                   ),
//                   const Color(0xFF16A34A),
//                   'Check in',
//                 ),
//
//                 const SizedBox(height: 6),
//
//                 _historyRow(
//                   Icons.logout_rounded,
//                   isActive
//                       ? 'Still working'
//                       : _formatDateTime(
//                     session.checkOutDateTime,
//                   ),
//                   isActive
//                       ? const Color(0xFF16A34A)
//                       : const Color(0xFFDC2626),
//                   'Check out',
//                 ),
//
//                 if (!isActive &&
//                     session.duration != null) ...[
//                   const SizedBox(height: 6),
//                   _historyRow(
//                     Icons.timer_outlined,
//                     _formatDuration(
//                       session.duration!,
//                     ),
//                     const Color(0xFF64748B),
//                     'Duration',
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _historyRow(
//       IconData icon,
//       String text,
//       Color color,
//       String label,
//       ) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 14,
//           color: color,
//         ),
//         const SizedBox(width: 6),
//         SizedBox(
//           width: 52,
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 9.5,
//               color: Color(0xFF94A3B8),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(
//               fontSize: 10.5,
//               color: Color(0xFF475569),
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   static String _formatDateTime(DateTime? dateTime) {
//     if (dateTime == null) return '--';
//
//     return DateFormat(
//       'dd MMM yyyy, hh:mm a',
//     ).format(dateTime);
//   }
//
//   static String _formatDuration(Duration duration) {
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//
//     if (hours > 0) {
//       return '${hours}h ${minutes}m';
//     }
//
//     return '${minutes}m';
//   }
// }

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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─────────────────────────────────────────────
          // Header
          // ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? const [Color(0xFF16A34A), Color(0xFF22C55E)]
                          : const [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$sessionNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Track $sessionNumber',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF172033),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isActive ? 'Currently in progress' : 'Completed work ',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isActive)
                  const _StatusBadge(text: 'ACTIVE', color: Color(0xFF16A34A)),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEFF2F6)),

          // ─────────────────────────────────────────────
          // Check In
          // ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 8),
            child: _LocationEvent(
              title: 'Check In',
              icon: Icons.login_rounded,
              color: const Color(0xFF16A34A),
              dateTime: session.checkInDateTime,
              latitude: _toDouble(session.checkInLatitude),
              longitude: _toDouble(session.checkInLongitude),
            ),
          ),

          // ─────────────────────────────────────────────
          // Check Out
          // ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 6, 15, 8),
            child: _LocationEvent(
              title: 'Check Out',
              icon: Icons.logout_rounded,
              color: isActive
                  ? const Color(0xFF64748B)
                  : const Color(0xFFDC2626),
              dateTime: session.checkOutDateTime,
              latitude: _toDouble(session.checkOutLatitude),
              longitude: _toDouble(session.checkOutLongitude),
              isActive: isActive,
            ),
          ),

          // ─────────────────────────────────────────────
          // Duration
          // ─────────────────────────────────────────────
          if (!isActive && session.duration != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 2, 15, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 17,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Total Duration',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDuration(session.duration!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF172033),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
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

class _LocationEvent extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final DateTime? dateTime;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  const _LocationEvent({
    required this.title,
    required this.icon,
    required this.color,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    this.isActive = false,
  });

  bool get hasLocation =>
      latitude != null && longitude != null && latitude != 0 && longitude != 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline icon
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
          ],
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + time
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  if (hasLocation)
                    InkWell(
                      onTap: () => _openGoogleMaps(latitude!, longitude!),
                      borderRadius: BorderRadius.circular(7),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Map',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(width: 5),
                  if (isActive)
                    const Text(
                      'IN PROGRESS',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                dateTime == null
                    ? (isActive ? 'Still working' : 'Not available')
                    : _formatDateTime(dateTime),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 7),

              // Location
              if (!hasLocation)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Location not available',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUri;

    googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';

    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
}
