import '../../../services/local_data_service.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../common/models/work_order_model.dart';
import '../../../common/models/work_session_model.dart';
import '../../../location/location_service.dart';
import '../../../services/secure_storage_service.dart';
import '../../../singature/signature_screen.dart';
import '../../../theme/app_colors.dart';

class CheckinController extends GetxController {
  final WorkOrderModel _initialTask;
  final LocalDataService local;
  WorkOrderModel get task => local.findOrder(_initialTask.id) ?? _initialTask;
  Worker? _ordersWorker;

  CheckinController({required WorkOrderModel task, LocalDataService? local})
    : _initialTask = task,
      local = local ?? LocalDataService.instance;

  /// All check-in/check-out sessions
  final RxList<WorkSessionModel> workSessions = <WorkSessionModel>[].obs;
  SecureStorageService get storage => local.storage;

  late Position position;

  /// Base64 encoded PNG signature.
  final RxnString signatureBase64CheckIn = RxnString();
  final RxnString signatureBase64CheckOut = RxnString();

  @override
  void onInit() {
    super.onInit();

    /// Load sessions received from API
    workSessions.assignAll(task.checkins);
    _ordersWorker = ever(local.workOrders, (_) {
      workSessions.assignAll(local.findOrder(_initialTask.id)?.checkins ?? []);
    });
    local.initialize();
  }

  Future<void> captureSignature(RxnString refPic) async {
    final String? result = await Get.to<String>(() => const SignatureScreen());

    if (result == null || result.isEmpty) {
      refPic.value = "";
      return;
    }
    if (result.isNotEmpty) {
      refPic.value = result;
    }

    update();

    // Get.snackbar(
    //   'Signature Added',
    //   'Customer signature has been captured successfully.',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor:AppColors.success,
    //   colorText: Colors.white,
    //   margin: const EdgeInsets.all(16),
    //   duration: const Duration(seconds: 2),
    // );
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
    if (!await LocationService.requestLocationAccess()) {
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
      checkInSignature: signatureBase64CheckIn.value,
      checkOutSignature: null,
      createdBy: null,
      updatedBy: null,
      deletedBy: null,
      createdAt: null,
      updatedAt: null,
      deletedAt: null,
    );

    workSessions.add(session);

    final sessions = workSessions.toList();
    await storage.editWorkOrder(
      task.id,
      (current) => current.copyWith(checkins: sessions, sync: 0),
    );
    signatureBase64CheckIn.value = "";
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
    if (!await LocationService.requestLocationAccess()) {
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
      checkOutSignature: signatureBase64CheckOut.value,
      submittedFrom: 1,
    );

    workSessions.refresh();
    final sessions = workSessions.toList();
    await storage.editWorkOrder(
      task.id,
      (current) => current.copyWith(checkins: sessions, sync: 0),
    );
    await LocationService.stop();
    signatureBase64CheckOut.value = "";
  }

  final Rxn<DateTime> checkInTime = Rxn<DateTime>();
  final Rxn<DateTime> checkOutTime = Rxn<DateTime>();

  Future<bool> canStartCheckIn() async {
    final id = await storage.isAlreadyCheckIn();
    if (id != null && id != task.id) {
      Get.snackbar(
        'Already Checked In',
        'You are Already Checked In for Other Work Order, First Checked Out to Start Work',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    _ordersWorker?.dispose();
    super.onClose();
  }
}
