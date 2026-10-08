import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:taskpro/common/helpers/helper_methods.dart';


import '../../../common/models/work_order_model.dart';
import '../../../common/models/work_session_model.dart';
import '../../../location/location_controller.dart';
import '../../../location/location_service.dart';
import '../../../services/secure_storage_service.dart';
import '../../../theme/app_colors.dart';

class CheckinController extends GetxController {

  final WorkOrderModel task;

  CheckinController({
    required this.task
  });

  /// All check-in/check-out sessions
  final RxList<WorkSessionModel> workSessions = <WorkSessionModel>[].obs;
  final storage = SecureStorageService.instance;
  final locController=Get.put(LocationController());
  late Position position;
  @override
  void onInit() {
    super.onInit();
    getPositions();
    /// Load sessions received from API
    workSessions.assignAll(task.checkins);
  }

  // ------------------------------------------------------------
  // CURRENT SESSION
  // ------------------------------------------------------------

  WorkSessionModel? get activeSession {
    for (final session in workSessions.reversed) {
      if (session.isActive) {
        return session;
      }
    }

    return null;
  }
  // ------------------------------------------------------------
  // STATUS
  // ------------------------------------------------------------

  bool get isCheckedIn {
    return activeSession != null;
  }

  bool get isCheckedOut {
    return workSessions.isNotEmpty && activeSession == null;
  }
  // ------------------------------------------------------------
  // SESSION COUNTS
  // ------------------------------------------------------------

  int get totalSessions {
    return workSessions.length;
  }

  int get completedSessions {
    return workSessions.where((session) {
      return !session.isActive;
    }).length;
  }
  // ------------------------------------------------------------
  // TOTAL WORKING TIME
  // ------------------------------------------------------------

  Duration get totalWorkedDuration {
    Duration total = Duration.zero;

    for (final session in workSessions) {
      final duration = session.duration;

      if (duration != null) {
        total += duration;
      }
    }

    return total;
  }
  // ------------------------------------------------------------
  // CHECK IN
  // ------------------------------------------------------------

  Future<void> checkIn() async {
    int? id=await storage.isAlreadyCheckIn();
    if(id!=null && id!=task.id){
      Get.snackbar(
        'Already Checked In',
        'You are Already Checked In for Other($id) Work Order, First Checked Out to Start Work',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    if(!await LocationService.start())
    {
      Get.snackbar(
        'Allow Location Service',
        'Please Allow Location Service details Before Starting Entering Session.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      return;
    }
    if (activeSession != null) {
      Get.snackbar(
        'Already Checked In',
        'Please check out from the current session first.',
      );
      return;
    }
    /// Don't allow another session while one is active
    if (isCheckedIn) {
      return;
    }
    position = await LocationService.getLatLong();

    final random = Random();
    final session = WorkSessionModel(
      id: random.nextInt(10000),
      workOrderId: task.id,
      checkInDateTime: DateTime.now(),
      checkOutDateTime: null,
      checkInLatitude: position.latitude,
      checkOutLatitude: null,
      checkInLongitude: position.longitude,
      checkOutLongitude: null,
      submittedFrom: 1,
      createdBy: null,
      updatedBy: null,
      deletedBy: null,
      createdAt: null,
      updatedAt: null,
      deletedAt: null,
    );

    workSessions.add(session);

    final updatedWorkOrder = task.copyWith(
      checkins: workSessions,
      sync: 0,
    );

    await storage.updateWorkOrderData(updatedWorkOrder);




  }
  // ------------------------------------------------------------
  // CHECK OUT
  // ------------------------------------------------------------
  Future<void> checkOut() async {
    if(!await LocationService.start())
    {
      Get.snackbar(
        'Failed',
        'Please Allow Location Service details Before Ending Session.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    final currentSession = activeSession;
    if (currentSession == null) {
      Get.snackbar(
        'currentSession',
        'Please check out from the current session first.',
      );
      return;
    }

    final index = workSessions.indexWhere(
          (session) => session.id == currentSession.id,
    );

    if (index == -1) {
      return;
    }
    position = await LocationService.getLatLong();
    workSessions[index] = currentSession.copyWith(
      checkOutDateTime: DateTime.now(),
      checkOutLatitude: position.latitude,
      checkOutLongitude: position.longitude,
      submittedFrom: 1
    );

    workSessions.refresh();
    final updatedWorkOrder = task.copyWith(
      checkins: workSessions,
      sync: 0,
    );

    await storage.updateWorkOrderData(updatedWorkOrder);
    await LocationService.stop();
  }

  final Rxn<DateTime> checkInTime = Rxn<DateTime>();
  final Rxn<DateTime> checkOutTime = Rxn<DateTime>();

  void getPositions() async{
    if(!await LocationService.start())
    {
      Get.snackbar(
        'Failed',
        'Please Allow Location Service details.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    position = await LocationService.getLatLong();
  }
}


class WorkOrderDetailsModal {
  static void show(
      BuildContext context,
      WorkOrderModel workOrder,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha:0.55),
      builder: (_) {
        return _WorkOrderDetailsSheet(workOrder: workOrder);
      },
    );
  }
}

class _WorkOrderDetailsSheet extends StatelessWidget {
  final WorkOrderModel workOrder;

  const _WorkOrderDetailsSheet({
    required this.workOrder,
  });

  Color get _primary => const Color(0xFF1769E0);
  Color get _darkBlue => const Color(0xFF123A73);
  Color get _lightBlue => const Color(0xFFEAF3FF);

  Color get _priorityColor {
    switch (workOrder.priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return const Color(0xFFE53935);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'low':
        return const Color(0xFF16A085);
      default:
        return const Color(0xFF1769E0);
    }
  }

  Color get _statusColor {
    switch (workOrder.statusId) {
      case 12:
        return const Color(0xFF2196F3);
      case 13:
        return const Color(0xFF42A5F5);
      case 14:
        return const Color(0xFFFF9800);
      case 15:
        return const Color(0xFFFFC107);
      case 16:
        return const Color(0xFF16A085);
      case 17:
        return const Color(0xFFE53935);
      case 18:
        return const Color(0xFF8E44AD);
      default:
        return _primary;
    }
  }

  String _value(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not available';
    }
    return value;
  }

  String get _managerName {
    final parts = [
      workOrder.managerFirstName,
      workOrder.managerMiddleName,
      workOrder.managerLastName,
    ].where((e) => e != null && e.trim().isNotEmpty);

    return parts.join(' ');
  }

  String get _technicianName {
    final parts = [
      workOrder.technicianFirstName,
      workOrder.technicianMiddleName,
      workOrder.technicianLastName,
    ].where((e) => e != null && e.trim().isNotEmpty);

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.93,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8FC),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                18,
                18,
                18,
                25 + bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleCard(),

                  const SizedBox(height: 18),

                  _sectionTitle(
                    icon: Icons.info_outline_rounded,
                    title: 'Work Order Information',
                  ),

                  const SizedBox(height: 10),

                  _buildBasicInfo(),

                  const SizedBox(height: 20),

                  _sectionTitle(
                    icon: Icons.schedule_rounded,
                    title: 'Schedule',
                  ),

                  const SizedBox(height: 10),

                  _buildScheduleCard(),

                  const SizedBox(height: 20),

                  if (workOrder.address != null) ...[
                    _sectionTitle(
                      icon: Icons.location_on_rounded,
                      title: 'Service Location',
                    ),

                    const SizedBox(height: 10),

                    _buildAddressCard(),

                    const SizedBox(height: 20),
                  ],

                  _sectionTitle(
                    icon: Icons.groups_rounded,
                    title: 'People',
                  ),

                  const SizedBox(height: 10),

                  _buildPeopleSection(),

                  const SizedBox(height: 20),

                  _sectionTitle(
                    icon: Icons.assignment_rounded,
                    title: 'Work Details',
                  ),

                  const SizedBox(height: 10),

                  _buildWorkDetails(),

                  const SizedBox(height: 20),

                  _sectionTitle(
                    icon: Icons.payments_rounded,
                    title: 'Commercial Details',
                  ),

                  const SizedBox(height: 10),

                  _buildCommercialDetails(),

                  if (_hasHardStartRequest) ...[
                    const SizedBox(height: 20),

                    _sectionTitle(
                      icon: Icons.access_time_filled_rounded,
                      title: 'Hard Start Change Request',
                    ),

                    const SizedBox(height: 10),

                    _buildHardStartRequest(),
                  ],

                  const SizedBox(height: 20),

                  _buildSessionsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 14, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primary,
            const Color(0xFF0D47A1),
            _darkBlue,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha:0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.45),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.20),
                  ),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WORK ORDER DETAILS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      workOrder.workOrderNo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TITLE
  // ------------------------------------------------------------

  Widget _buildTitleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.055),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _value(workOrder.workOrderTitle),
                  style: const TextStyle(
                    color: Color(0xFF172B4D),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              _statusBadge(),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _smallBadge(
                icon: Icons.flag_rounded,
                text: _value(workOrder.priority),
                color: _priorityColor,
              ),

              const SizedBox(width: 8),

              _smallBadge(
                icon: Icons.build_circle_rounded,
                text: _value(workOrder.serviceTypeName),
                color: const Color(0xFF7B61FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha:0.11),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _value(workOrder.statusName),
            style: TextStyle(
              color: _statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.09),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BASIC INFO
  // ------------------------------------------------------------

  Widget _buildBasicInfo() {
    return _card(
      child: Column(
        children: [
          _infoRow(
            icon: Icons.confirmation_number_rounded,
            label: 'Work Order No.',
            value: workOrder.workOrderNo,
            color: _primary,
          ),

          _divider(),

          _infoRow(
            icon: Icons.business_center_rounded,
            label: 'Lead',
            value: workOrder.leadTitle,
            color: const Color(0xFF7B61FF),
          ),

          _divider(),

          _infoRow(
            icon: Icons.miscellaneous_services_rounded,
            label: 'Service Type',
            value: workOrder.serviceTypeName,
            color: const Color(0xFF16A085),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SCHEDULE
  // ------------------------------------------------------------

  Widget _buildScheduleCard() {
    return _card(
      child: Column(
        children: [
          _timelineRow(
            icon: Icons.play_circle_fill_rounded,
            title: 'Scheduled Start',
            value: _value(workOrder.scheduledEtaFrom),
            color: const Color(0xFF16A085),
            isLast: false,
          ),

          _timelineRow(
            icon: Icons.flag_circle_rounded,
            title: 'Scheduled End',
            value: _value(workOrder.scheduledEtaTo),
            color: const Color(0xFFE67E22),
            isLast: false,
          ),

          _timelineRow(
            icon: Icons.flash_on_rounded,
            title: 'Hard Start Time',
            value: _value(workOrder.hardStartTime),
            color: const Color(0xFFE53935),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _timelineRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.11),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: color,
                ),
              ),

              if (!isLast)
                Container(
                  width: 2,
                  height: 28,
                  color: color.withValues(alpha:0.18),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7A869A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF172B4D),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ADDRESS
  // ------------------------------------------------------------

  Widget _buildAddressCard() {
    final address = workOrder.address!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF4FF),
            Color(0xFFF4F8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _primary.withValues(alpha:0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha:0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  _value(address.fullAddress),
                  style: const TextStyle(
                    color: Color(0xFF243B53),
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (address.googleMapLink.trim().isNotEmpty) ...[
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Keep your existing map functionality here.
                },
                icon: const Icon(
                  Icons.directions_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Open Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: BorderSide(
                    color: _primary.withValues(alpha:0.25),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PEOPLE
  // ------------------------------------------------------------

  Widget _buildPeopleSection() {
    return Column(
      children: [
        _personCard(
          icon: Icons.manage_accounts_rounded,
          title: 'Manager',
          name: _managerName,
          email: workOrder.managerEmail,
          phone: workOrder.managerPhoneNumber,
          color: const Color(0xFF7B61FF),
        ),

        const SizedBox(height: 10),

        _personCard(
          icon: Icons.engineering_rounded,
          title: 'Technician',
          name: _technicianName,
          email: null,
          phone: null,
          color: const Color(0xFF16A085),
        ),
      ],
    );
  }

  Widget _personCard({
    required IconData icon,
    required String title,
    required String name,
    required String? email,
    required String? phone,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172B4D),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                if (email != null &&
                    email.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF7A869A),
                      fontSize: 11,
                    ),
                  ),
                ],

                if (phone != null &&
                    phone.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      color: Color(0xFF7A869A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // WORK DETAILS
  // ------------------------------------------------------------

  Widget _buildWorkDetails() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailTile(
            icon: Icons.description_rounded,
            title: 'Scope of Work',
            value: _value(workOrder.scopeOfWork),
            color: const Color(0xFF1769E0),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _miniStat(
                  icon: Icons.timer_rounded,
                  title: 'Max Hours',
                  value: workOrder.maxHours?.toString() ?? '—',
                  color: const Color(0xFF7B61FF),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _miniStat(
                  icon: Icons.timelapse_rounded,
                  title: 'Approx. Hours',
                  value:
                  workOrder.approximateHoursToComplete?.toString() ??
                      '—',
                  color: const Color(0xFFE67E22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // COMMERCIAL
  // ------------------------------------------------------------

  Widget _buildCommercialDetails() {
    return Row(
      children: [
        Expanded(
          child: _commercialCard(
            icon: Icons.payments_rounded,
            title: 'Rate',
            value: workOrder.rateValue?.toString() ?? '—',
            color: const Color(0xFF16A085),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _commercialCard(
            icon: Icons.directions_car_filled_rounded,
            title: 'Travel Rate',
            value: workOrder.travelRate ?? '—',
            color: const Color(0xFF1769E0),
          ),
        ),
      ],
    );
  }

  Widget _commercialCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.11),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),

          const SizedBox(height: 11),

          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7A869A),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF172B4D),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HARD START REQUEST
  // ------------------------------------------------------------

  bool get _hasHardStartRequest {
    return workOrder.proposedDatetime != null ||
        workOrder.requestedAt != null ||
        workOrder.approvedAt != null ||
        (workOrder.proposedReason != null &&
            workOrder.proposedReason!.trim().isNotEmpty);
  }

  Widget _buildHardStartRequest() {
    final accepted =
        workOrder.proposedDatetimeAcceptedByManager == 1;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accepted
              ? const Color(0xFF16A085).withValues(alpha:0.25)
              : const Color(0xFFFF9800).withValues(alpha:0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (accepted
                      ? const Color(0xFF16A085)
                      : const Color(0xFFFF9800))
                      .withValues(alpha:0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  accepted
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                  color: accepted
                      ? const Color(0xFF16A085)
                      : const Color(0xFFFF9800),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Status',
                      style: TextStyle(
                        color: Color(0xFF7A869A),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      accepted ? 'Approved by Manager' : 'Pending',
                      style: TextStyle(
                        color: accepted
                            ? const Color(0xFF16A085)
                            : const Color(0xFFFF9800),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (workOrder.proposedDatetime != null)
            _requestRow(
              Icons.event_rounded,
              'Proposed Time',
              workOrder.proposedDatetime
                  .toString()
                  .replaceFirst('T', ' '),
            ),

          if (workOrder.requestedAt != null)
            _requestRow(
              Icons.send_rounded,
              'Requested At',
              workOrder.requestedAt
                  .toString()
                  .replaceFirst('T', ' '),
            ),

          if (workOrder.approvedAt != null)
            _requestRow(
              Icons.verified_rounded,
              'Approved At',
              workOrder.approvedAt
                  .toString()
                  .replaceFirst('T', ' '),
            ),

          if (workOrder.proposedReason != null &&
              workOrder.proposedReason!.trim().isNotEmpty)
            _requestRow(
              Icons.chat_bubble_outline_rounded,
              'Reason',
              workOrder.proposedReason!,
            ),
        ],
      ),
    );
  }

  Widget _requestRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: _primary,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7A869A),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF243B53),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CHECK-IN / CHECK-OUT
  // ------------------------------------------------------------

  Widget _buildSessionsCard() {
    final sessions = workOrder.checkins;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B61FF).withValues(alpha:0.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF7B61FF),
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Sessions',
                      style: TextStyle(
                        color: Color(0xFF172B4D),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Check-in / check-out history',
                      style: TextStyle(
                        color: Color(0xFF7A869A),
                        fontSize: 10,
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
                  color: const Color(0xFF7B61FF).withValues(alpha:0.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${sessions.length}',
                  style: const TextStyle(
                    color: Color(0xFF7B61FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          if (sessions.isNotEmpty) ...[
            const SizedBox(height: 15),

            ...List.generate(
              sessions.length,
                  (index) {
                final session = sessions[index];

                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == sessions.length - 1 ? 0 : 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha:0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: _primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          '${Common.getformatDate(session.checkInDateTime.toString())}\n${Common.getformatDate(session.checkOutDateTime.toString())}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF52606D),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.timer_off_outlined,
                    color: Color(0xFF9AA5B1),
                    size: 28,
                  ),
                  SizedBox(height: 7),
                  Text(
                    'No work sessions recorded',
                    style: TextStyle(
                      color: Color(0xFF7A869A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // COMMON WIDGETS
  // ------------------------------------------------------------

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _lightBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 17,
            color: _primary,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7A869A),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF243B53),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Divider(
        height: 1,
        color: Colors.grey.shade100,
      ),
    );
  }

  Widget _detailTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 19,
            color: color,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF7A869A),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF243B53),
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.065),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 19,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF7A869A),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

