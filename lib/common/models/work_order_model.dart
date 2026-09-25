import 'package:taskpro/common/models/work_session_model.dart';

class WorkOrderModel {
  final int id;
  final String workOrderNo;
  final int leadId;
  final String leadTitle;
  final int managerId;
  final String managerFirstName;
  final String? managerMiddleName;
  final String managerLastName;
  final String? managerEmail;
  final String? managerPhoneNumber;
  final String? managerOtherEmail;
  final String? managerOtherPhone;
  final String technicianId;
  final String technicianFirstName;
  final String? technicianMiddleName;
  final String technicianLastName;
  final int serviceTypeId;
  final String serviceTypeName;
  final int priorityId;
  final String priority;
  int? statusId;
  final String? statusName;
  final String workOrderTitle;
  final String? scopeOfWork;
  final int? rateType;
  final dynamic rateValue;
  final String? scheduledEtaFrom;
  final String? scheduledEtaTo;
  final String? hardStartTime;
  final dynamic maxHours;
  final dynamic approximateHoursToComplete;
  // Multiple check-in / check-out sessions
  final List<WorkSessionModel> checkins;
  int sync;



  WorkOrderModel({
    required this.id,
    required this.workOrderNo,
    required this.leadId,
    required this.leadTitle,
    required this.managerId,
    required this.managerFirstName,
    this.managerMiddleName,
    required this.managerLastName,
    this.managerEmail,
    this.managerPhoneNumber,
    this.managerOtherEmail,
    this.managerOtherPhone,
    required this.technicianId,
    required this.technicianFirstName,
    this.technicianMiddleName,
    required this.technicianLastName,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.priorityId,
    required this.priority,
    this.statusId,
    this.statusName,
    required this.workOrderTitle,
    this.scopeOfWork,
    this.rateType,
    this.rateValue,
    this.scheduledEtaFrom,
    this.scheduledEtaTo,
    this.hardStartTime,
    this.maxHours,
    this.approximateHoursToComplete,
    this.checkins = const [],
    this.sync=1

  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderModel(
      id: json['id'] as int? ?? 0,
      workOrderNo: json['work_order_no']?.toString() ?? '',
      leadId: json['lead_id'] as int? ?? 0,
      leadTitle: json['lead_title'] as String? ?? '',
      managerId: json['manager_id'] as int? ?? 0,
      managerFirstName: json['manager_first_name'] as String? ?? '',
      managerMiddleName: json['manager_middle_name'] as String?,
      managerLastName: json['manager_last_name'] as String? ?? '',
      managerEmail: json['manager_email'] as String?,
      managerPhoneNumber: json['manager_phone_number'] as String?,
      managerOtherEmail: json['manager_other_email'] as String?,
      managerOtherPhone: json['manager_other_phone'] as String?,
      technicianId: json['technician_id']?.toString() ?? '',
      technicianFirstName: json['technician_first_name'] as String? ?? '',
      technicianMiddleName: json['technician_middle_name'] as String?,
      technicianLastName: json['technician_last_name'] as String? ?? '',
      serviceTypeId: json['service_type_id'] as int? ?? 0,
      serviceTypeName: json['service_type_name'] as String? ?? '',
      priorityId: json['priority_id'] as int? ?? 0,
      priority: json['priority'] as String? ?? '',
      statusId: json['status_id'] as int?,
      statusName: json['status_name'] as String?,
      workOrderTitle: json['work_order_title'] as String? ?? '',
      scopeOfWork: json['scope_of_work'] as String?,
      rateType: json['rate_type'] as int?,
      rateValue: json['rate_value'],
      scheduledEtaFrom: json['scheduled_eta_from'] as String?,
      scheduledEtaTo: json['scheduled_eta_to'] as String?,
      hardStartTime: json['hard_start_time'] as String?,
      maxHours: json['max_hours'],
      approximateHoursToComplete: json['approximate_hours_to_complete'],
      checkins: (json['checkins'] as List<dynamic>?)
          ?.map(
            (item) => WorkSessionModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList() ??
          [],
      sync: json['sync'] as int? ?? 1,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_order_no': workOrderNo,
      'lead_id': leadId,
      'lead_title': leadTitle,
      'manager_id': managerId,
      'manager_first_name': managerFirstName,
      'manager_middle_name': managerMiddleName,
      'manager_last_name': managerLastName,
      'manager_email': managerEmail,
      'manager_phone_number': managerPhoneNumber,
      'manager_other_email': managerOtherEmail,
      'manager_other_phone': managerOtherPhone,
      'technician_id': technicianId,
      'technician_first_name': technicianFirstName,
      'technician_middle_name': technicianMiddleName,
      'technician_last_name': technicianLastName,
      'service_type_id': serviceTypeId,
      'service_type_name': serviceTypeName,
      'priority_id': priorityId,
      'priority': priority,
      'status_id': statusId,
      'status_name': statusName,
      'work_order_title': workOrderTitle,
      'scope_of_work': scopeOfWork,
      'rate_type': rateType,
      'rate_value': rateValue,
      'scheduled_eta_from': scheduledEtaFrom,
      'scheduled_eta_to': scheduledEtaTo,
      'hard_start_time': hardStartTime,
      'max_hours': maxHours,
      'approximate_hours_to_complete': approximateHoursToComplete,
      'checkins': checkins
          .map((session) => session.toJson())
          .toList(),
      'sync': sync,
    };
  }
  WorkOrderModel copyWith({
    int? id,
    String? workOrderNo,
    int? leadId,
    String? leadTitle,
    int? managerId,
    String? managerFirstName,
    String? managerMiddleName,
    String? managerLastName,
    String? managerEmail,
    String? managerPhoneNumber,
    String? managerOtherEmail,
    String? managerOtherPhone,
    String? technicianId,
    String? technicianFirstName,
    String? technicianMiddleName,
    String? technicianLastName,
    int? serviceTypeId,
    String? serviceTypeName,
    int? priorityId,
    String? priority,
    int? statusId,
    String? statusName,
    String? workOrderTitle,
    String? scopeOfWork,
    int? rateType,
    dynamic rateValue,
    String? scheduledEtaFrom,
    String? scheduledEtaTo,
    String? hardStartTime,
    dynamic maxHours,
    dynamic approximateHoursToComplete,
    List<WorkSessionModel>? checkins,
    int? sync,
  }) {
    return WorkOrderModel(
      id: id ?? this.id,
      workOrderNo: workOrderNo ?? this.workOrderNo,
      leadId: leadId ?? this.leadId,
      leadTitle: leadTitle ?? this.leadTitle,

      managerId: managerId ?? this.managerId,
      managerFirstName: managerFirstName ?? this.managerFirstName,
      managerMiddleName: managerMiddleName ?? this.managerMiddleName,
      managerLastName: managerLastName ?? this.managerLastName,
      managerEmail: managerEmail ?? this.managerEmail,
      managerPhoneNumber: managerPhoneNumber ?? this.managerPhoneNumber,
      managerOtherEmail: managerOtherEmail ?? this.managerOtherEmail,
      managerOtherPhone: managerOtherPhone ?? this.managerOtherPhone,

      technicianId: technicianId ?? this.technicianId,
      technicianFirstName: technicianFirstName ?? this.technicianFirstName,
      technicianMiddleName: technicianMiddleName ?? this.technicianMiddleName,
      technicianLastName: technicianLastName ?? this.technicianLastName,

      serviceTypeId: serviceTypeId ?? this.serviceTypeId,
      serviceTypeName: serviceTypeName ?? this.serviceTypeName,

      priorityId: priorityId ?? this.priorityId,
      priority: priority ?? this.priority,

      statusId: statusId ?? this.statusId,
      statusName: statusName ?? this.statusName,

      workOrderTitle: workOrderTitle ?? this.workOrderTitle,
      scopeOfWork: scopeOfWork ?? this.scopeOfWork,

      rateType: rateType ?? this.rateType,
      rateValue: rateValue ?? this.rateValue,

      scheduledEtaFrom: scheduledEtaFrom ?? this.scheduledEtaFrom,
      scheduledEtaTo: scheduledEtaTo ?? this.scheduledEtaTo,
      hardStartTime: hardStartTime ?? this.hardStartTime,

      maxHours: maxHours ?? this.maxHours,
      approximateHoursToComplete:
      approximateHoursToComplete ?? this.approximateHoursToComplete,

      checkins: checkins ?? this.checkins,

      sync: sync ?? this.sync,
    );
  }
  // ------------------------------------------------------------
  // Helpful getters
  // ------------------------------------------------------------

  WorkSessionModel? get activeSession {
    for (final session in checkins.reversed) {
      if (session.isActive) {
        return session;
      }
    }

    return null;
  }

  bool get isCheckedIn => activeSession != null;

  bool get isCheckedOut =>
      checkins.isNotEmpty && activeSession == null;

  int get totalSessions => checkins.length;

  int get completedSessions =>
      checkins.where((session) => !session.isActive).length;

  Duration get totalWorkedDuration {
    Duration total = Duration.zero;

    for (final session in checkins) {
      final duration = session.duration;

      if (duration != null) {
        total += duration;
      }
    }

    return total;
  }
}