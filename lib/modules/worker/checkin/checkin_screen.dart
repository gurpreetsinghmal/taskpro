import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:taskpro/modules/worker/checkin/checkin_controller.dart';
import 'package:taskpro/modules/worker/photoupload/task_completion_screen.dart';
import '../../../common/helpers/app_helper.dart';
import '../../../common/models/work_order_model.dart';
import '../../../common/models/work_session_model.dart';
import '../../../theme/app_colors.dart';


class CheckInScreen extends StatelessWidget {
  final WorkOrderModel task;
  const CheckInScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final controller=Get.put(CheckinController(task: task));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            _buildPageIntro(),

            const SizedBox(height: 10),

            _CheckInOutCard(task: task,controller: controller,),
          ],
        ),
      )),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
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
                  color: AppColors.textPrimary,
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
            'CheckIn / CheckOut Session',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'WO No. ${task.workOrderNo}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textHint,
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

}

// ============================================================
// WORK SESSIONS
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

      return _ModernSessionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.isCheckedIn?findButton(title: "Go to Site",onPressed: () {
              Get.to(() => TaskCompletionScreen(task: controller.task));
            },backgroundColor: AppColors.textPrimary
            ):const SizedBox(),
            const SizedBox(height: 10),
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

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Work Sessions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
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

  Widget _buildSummary(CheckinController controller) {
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
      CheckinController controller,
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
      CheckinController controller,
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
