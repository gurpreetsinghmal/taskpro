import 'dart:math';

import 'package:get/get.dart';


import '../../../common/models/work_order_model.dart';
import '../../../common/models/work_session_model.dart';
import '../../../services/secure_storage_service.dart';

class CheckinController extends GetxController {

  final WorkOrderModel task;

  CheckinController({
    required this.task
  });

  /// All check-in/check-out sessions
  final RxList<WorkSessionModel> workSessions = <WorkSessionModel>[].obs;
  final storage = SecureStorageService.instance;

  @override
  void onInit() {
    super.onInit();

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
    final random = Random();
    final session = WorkSessionModel(
      id: random.nextInt(10000),
      workOrderId: task.id,
      checkInDateTime: DateTime.now(),
      checkOutDateTime: null,
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

    workSessions[index] = currentSession.copyWith(
      checkOutDateTime: DateTime.now(),
    );

    workSessions.refresh();
    final updatedWorkOrder = task.copyWith(
      checkins: workSessions,
      sync: 0,
    );

    await storage.updateWorkOrderData(updatedWorkOrder);
  }

  final Rxn<DateTime> checkInTime = Rxn<DateTime>();
  final Rxn<DateTime> checkOutTime = Rxn<DateTime>();

}
