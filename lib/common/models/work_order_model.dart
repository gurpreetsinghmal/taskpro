class WorkOrderModel {
  final int id;
  final String workOrderNo;
  final int leadId;
  final String leadTitle;
  final int managerId;
  final String managerFirstName;
  final String? managerMiddleName;
  final String managerLastName;
  final String technicianId;
  final String technicianFirstName;
  final String? technicianMiddleName;
  final String technicianLastName;
  final int serviceTypeId;
  final String serviceTypeName;
  final int priorityId;
  final String priority;
  final int? statusId;
  final String? statusName;
  final String workOrderTitle;
  final String? scopeOfWork;

  const WorkOrderModel({
    required this.id,
    required this.workOrderNo,
    required this.leadId,
    required this.leadTitle,
    required this.managerId,
    required this.managerFirstName,
    this.managerMiddleName,
    required this.managerLastName,
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
  });

  // Read from API with explicit null-safe casting
  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderModel(
      id: json['id'] as int,
      workOrderNo: json['work_order_no'] as String,
      leadId: json['lead_id'] as int,
      leadTitle: json['lead_title'] as String,
      managerId: json['manager_id'] as int,
      managerFirstName: json['manager_first_name'] as String,
      managerMiddleName: json['manager_middle_name'] as String?,
      managerLastName: json['manager_last_name'] as String,
      technicianId: json['technician_id']?.toString() ?? '',
      technicianFirstName: json['technician_first_name'] as String,
      technicianMiddleName: json['technician_middle_name'] as String?,
      technicianLastName: json['technician_last_name'] as String,
      serviceTypeId: json['service_type_id'] as int,
      serviceTypeName: json['service_type_name'] as String,
      priorityId: json['priority_id'] as int,
      priority: json['priority'] as String,
      statusId: json['status_id'] as int?,
      statusName: json['status_name'] as String?,
      workOrderTitle: json['work_order_title'] as String,
      scopeOfWork: json['scope_of_work'] as String?,
    );
  }

  // Write to API
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
    };
  }
}