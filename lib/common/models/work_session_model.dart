class WorkSessionModel {
  final int? id;
  final int workOrderId;
  final DateTime? checkInDateTime;
  final DateTime? checkOutDateTime;
  // ------------------------------------------------------------
  // Check-in / Check-out Location
  // ------------------------------------------------------------
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final int? submittedFrom;
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
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.submittedFrom,
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
  bool get isActive => checkInDateTime != null && checkOutDateTime == null;
  bool get isCompleted => checkInDateTime != null && checkOutDateTime != null;
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
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkOutLatitude,
    double? checkOutLongitude,
    int? submittedFrom,
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
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkOutLatitude: checkOutLatitude ?? this.checkOutLatitude,
      checkOutLongitude: checkOutLongitude ?? this.checkOutLongitude,
      submittedFrom: submittedFrom??this.submittedFrom,
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
      checkInDateTime: _parseDateTime(json['checkin_datetime']),
      checkOutDateTime: _parseDateTime(json['checkout_datetime']),
      // ----------------------------------------------------------
      // Location
      // ----------------------------------------------------------
      checkInLatitude: _parseDouble(json['checkin_latitude']),
      checkInLongitude: _parseDouble(json['checkin_longitude']),
      checkOutLatitude: _parseDouble(json['checkout_latitude']),
      checkOutLongitude: _parseDouble(json['checkout_longitude']),
      submittedFrom: json['submitted_from'] as int?,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      deletedBy: json['deleted_by'] as int?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deletedAt: _parseDateTime(json['deleted_at']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_order_id': workOrderId,
      'checkin_datetime': checkInDateTime?.toIso8601String(),
      'checkout_datetime': checkOutDateTime?.toIso8601String(),
      // ----------------------------------------------------------
      // Location
      // ----------------------------------------------------------
      'checkin_latitude': checkInLatitude,
      'checkin_longitude': checkInLongitude,
      'checkout_latitude': checkOutLatitude,
      'checkout_longitude': checkOutLongitude,
      'submitted_from':submittedFrom,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // ------------------------------------------------------------
  // DateTime Parser
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // Double Parser
  // ------------------------------------------------------------
  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().trim());
  }
}
