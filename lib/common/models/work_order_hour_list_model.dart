class WorkOrderHourListModel{
  final int? id;
  final int? workOrderId;
  final String? estimatedHours;
  final String? actualHours;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final DateTime? actualStartAt;
  final DateTime? actualCompletedAt;

  WorkOrderHourListModel({
    this.id,
    this.workOrderId,
    this.estimatedHours,
    this.actualHours,
    this.scheduledStart,
    this.scheduledEnd,
    this.actualStartAt,
    this.actualCompletedAt,
  });

  factory WorkOrderHourListModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderHourListModel(
      id: json['id'] as int?,
      workOrderId: json['work_order_id'] as int?,
      estimatedHours: json['estimated_hours'] as String?,
      actualHours: json['actual_hours'] as String?,
      scheduledStart: json['scheduled_start'] != null
          ? DateTime.tryParse(json['scheduled_start'])
          : null,
      scheduledEnd: json['scheduled_end'] != null
          ? DateTime.tryParse(json['scheduled_end'])
          : null,
      actualStartAt: json['actual_start_at'] != null
          ? DateTime.tryParse(json['actual_start_at'])
          : null,
      actualCompletedAt: json['actual_completed_at'] != null
          ? DateTime.tryParse(json['actual_completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_order_id': workOrderId,
      'estimated_hours': estimatedHours,
      'actual_hours': actualHours,
      'scheduled_start': scheduledStart?.toIso8601String(),
      'scheduled_end': scheduledEnd?.toIso8601String(),
      'actual_start_at': actualStartAt?.toIso8601String(),
      'actual_completed_at': actualCompletedAt?.toIso8601String(),
    };
  }
}