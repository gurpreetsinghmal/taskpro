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
  final String? travelRate;
  final String? scheduledEtaFrom;
  final String? scheduledEtaTo;
  final String? hardStartTime;
  // Hard Start Time Change Request
  final DateTime? proposedDatetime;
  final int? proposedDatetimeAcceptedByManager;
  final DateTime? requestedAt;
  final int? requestedBy;
  final DateTime? approvedAt;
  final int? approvedBy;
  final String? proposedReason;

  final dynamic maxHours;
  final dynamic approximateHoursToComplete;
  final WorkOrderAddressModel? address;

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
    this.travelRate,
    this.scheduledEtaFrom,
    this.scheduledEtaTo,
    this.hardStartTime,
    // Hard Start Time Change Request
    this.proposedDatetime, //"proposed_datetime":  "2026-09-24 23:00:00",
    this.proposedDatetimeAcceptedByManager, //proposed_datetime_accepted_by_manager
    this.requestedAt, //requested_at
    this.requestedBy, //requested_by
    this.approvedAt, //approved_at
    this.approvedBy, //approved_by
    this.proposedReason, //proposed_reason
    this.maxHours,
    this.approximateHoursToComplete,
    this.address,
    this.checkins = const [],
    this.sync = 1,
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
      travelRate: json['travelrate'] as String?,
      scheduledEtaFrom: json['scheduled_eta_from'] as String?,
      scheduledEtaTo: json['scheduled_eta_to'] as String?,
      hardStartTime: json['hard_start_time'] as String?,
      proposedDatetime: json['proposed_datetime'] != null
          ? DateTime.tryParse(json['proposed_datetime'].toString())
          : null,

      proposedDatetimeAcceptedByManager:
          json['proposed_datetime_accepted_by_manager'] == null
          ? null
          : int.tryParse(
              json['proposed_datetime_accepted_by_manager'].toString(),
            ),

      requestedAt: json['requested_at'] != null
          ? DateTime.tryParse(json['requested_at'].toString())
          : null,

      requestedBy: json['requested_by'] == null
          ? null
          : int.tryParse(json['requested_by'].toString()),

      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'].toString())
          : null,

      approvedBy: json['approved_by'] == null
          ? null
          : int.tryParse(json['approved_by'].toString()),

      proposedReason: json['proposed_reason']?.toString(),
      maxHours: json['max_hours'],
      approximateHoursToComplete: json['approximate_hours_to_complete'],
      address: json['address'] is Map<String, dynamic>
          ? WorkOrderAddressModel.fromJson(
              json['address'] as Map<String, dynamic>,
            )
          : null,
      checkins:
          (json['checkins'] as List<dynamic>?)
              ?.map(
                (item) =>
                    WorkSessionModel.fromJson(item as Map<String, dynamic>),
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
      'travelrate': travelRate,
      'scheduled_eta_from': scheduledEtaFrom,
      'scheduled_eta_to': scheduledEtaTo,
      'hard_start_time': hardStartTime,
      'proposed_datetime': proposedDatetime?.toIso8601String(),
      'proposed_datetime_accepted_by_manager':
          proposedDatetimeAcceptedByManager,
      'requested_at': requestedAt?.toIso8601String(),
      'requested_by': requestedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'proposed_reason': proposedReason,
      'max_hours': maxHours,
      'approximate_hours_to_complete': approximateHoursToComplete,
      'address': address?.toJson(),
      'checkins': checkins.map((session) => session.toJson()).toList(),
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
    String? travelRate,
    String? scheduledEtaFrom,
    String? scheduledEtaTo,
    String? hardStartTime,
    DateTime? proposedDatetime,
    int? proposedDatetimeAcceptedByManager,
    DateTime? requestedAt,
    int? requestedBy,
    DateTime? approvedAt,
    int? approvedBy,
    String? proposedReason,
    dynamic maxHours,
    dynamic approximateHoursToComplete,
    WorkOrderAddressModel? address,
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
      travelRate: travelRate ?? this.travelRate,

      scheduledEtaFrom: scheduledEtaFrom ?? this.scheduledEtaFrom,
      scheduledEtaTo: scheduledEtaTo ?? this.scheduledEtaTo,
      hardStartTime: hardStartTime ?? this.hardStartTime,

      proposedDatetime: proposedDatetime ?? this.proposedDatetime,

      proposedDatetimeAcceptedByManager:
          proposedDatetimeAcceptedByManager ??
          this.proposedDatetimeAcceptedByManager,

      requestedAt: requestedAt ?? this.requestedAt,

      requestedBy: requestedBy ?? this.requestedBy,

      approvedAt: approvedAt ?? this.approvedAt,

      approvedBy: approvedBy ?? this.approvedBy,

      proposedReason: proposedReason ?? this.proposedReason,

      maxHours: maxHours ?? this.maxHours,
      approximateHoursToComplete:
          approximateHoursToComplete ?? this.approximateHoursToComplete,
      address: address ?? this.address,
      checkins: checkins ?? this.checkins,

      sync: sync ?? this.sync,
    );
  }
}

class WorkOrderAddressModel {
  final String fullAddress;
  final String googleMapLink;

  const WorkOrderAddressModel({
    required this.fullAddress,
    required this.googleMapLink,
  });

  factory WorkOrderAddressModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderAddressModel(
      fullAddress: json['full_address']?.toString() ?? '',
      googleMapLink: json['google_map_link']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'full_address': fullAddress, 'google_map_link': googleMapLink};
  }

  WorkOrderAddressModel copyWith({String? fullAddress, String? googleMapLink}) {
    return WorkOrderAddressModel(
      fullAddress: fullAddress ?? this.fullAddress,
      googleMapLink: googleMapLink ?? this.googleMapLink,
    );
  }
}
