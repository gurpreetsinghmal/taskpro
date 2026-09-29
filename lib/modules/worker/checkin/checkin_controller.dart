import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';


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
    position = await LocationService.getLatLong();
  }
}
