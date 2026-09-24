class WorkSessionModel {
  final int? id;
  final int workOrderId;
  final DateTime? checkInDateTime;
  final DateTime? checkOutDateTime;
  final int? createdBy;
  final int? updatedBy;
  final int? deletedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const WorkSessionModel({
    required this.id,
    required this.workOrderId,
    this.checkInDateTime,
    this.checkOutDateTime,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // ------------------------------------------------------------
  // Session state
  // ------------------------------------------------------------

  bool get isActive =>
      checkInDateTime != null &&
          checkOutDateTime == null;

  bool get isCompleted =>
      checkInDateTime != null &&
          checkOutDateTime != null;

  Duration? get duration {
    if (checkInDateTime == null) {
      return null;
    }

    final endTime = checkOutDateTime ?? DateTime.now();

    return endTime.difference(checkInDateTime!);
  }

  // ------------------------------------------------------------
  // Copy
  // ------------------------------------------------------------

  WorkSessionModel copyWith({
    int? id,
    int? workOrderId,
    DateTime? checkInDateTime,
    DateTime? checkOutDateTime,
    int? createdBy,
    int? updatedBy,
    int? deletedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return WorkSessionModel(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      checkInDateTime: checkInDateTime ?? this.checkInDateTime,
      checkOutDateTime: checkOutDateTime ?? this.checkOutDateTime,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      deletedBy: deletedBy ?? this.deletedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // ------------------------------------------------------------
  // JSON
  // ------------------------------------------------------------

  factory WorkSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkSessionModel(
      id: json['id'] as int?,
      workOrderId: json['work_order_id'] as int? ?? 0,
      checkInDateTime: _parseDateTime(
        json['checkin_datetime'],
      ),
      checkOutDateTime: _parseDateTime(
        json['checkout_datetime'],
      ),
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      deletedBy: json['deleted_by'] as int?,
      createdAt: _parseDateTime(
        json['created_at'],
      ),
      updatedAt: _parseDateTime(
        json['updated_at'],
      ),
      deletedAt: _parseDateTime(
        json['deleted_at'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_order_id': workOrderId,
      'checkin_datetime':
      checkInDateTime?.toIso8601String(),
      'checkout_datetime':
      checkOutDateTime?.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}