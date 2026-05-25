class DistributionModel {
  final int? id;
  final int beneficiaryId;
  final int datesBoxes;
  final int datesPieces;
  final int datesReceived;
  final int wheatBags;
  final int wheatPieces;
  final int wheatReceived;
  final double meatKg;
  final int meatReceived;
  final int basketCount;
  final int basketReceived;
  final String overallStatus;
  final int? receivedAt;
  final int? receivedBy;
  final String notes;
  final int updatedAt;

  DistributionModel({
    this.id,
    required this.beneficiaryId,
    this.datesBoxes = 0,
    this.datesPieces = 0,
    this.datesReceived = 0,
    this.wheatBags = 0,
    this.wheatPieces = 0,
    this.wheatReceived = 0,
    this.meatKg = 0.0,
    this.meatReceived = 0,
    this.basketCount = 0,
    this.basketReceived = 0,
    this.overallStatus = 'PENDING',
    this.receivedAt,
    this.receivedBy,
    this.notes = '',
    required this.updatedAt,
  });

  bool get isDatesReceived => datesReceived == 1;
  bool get isWheatReceived => wheatReceived == 1;
  bool get isMeatReceived => meatReceived == 1;
  bool get isBasketReceived => basketReceived == 1;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'beneficiary_id': beneficiaryId,
      'dates_boxes': datesBoxes,
      'dates_pieces': datesPieces,
      'dates_received': datesReceived,
      'wheat_bags': wheatBags,
      'wheat_pieces': wheatPieces,
      'wheat_received': wheatReceived,
      'meat_kg': meatKg,
      'meat_received': meatReceived,
      'basket_count': basketCount,
      'basket_received': basketReceived,
      'overall_status': overallStatus,
      'received_at': receivedAt,
      'received_by': receivedBy,
      'notes': notes,
      'updated_at': updatedAt,
    };
  }

  factory DistributionModel.fromMap(Map<String, dynamic> map) {
    return DistributionModel(
      id: map['id'] as int?,
      beneficiaryId: map['beneficiary_id'] as int,
      datesBoxes: map['dates_boxes'] as int? ?? 0,
      datesPieces: map['dates_pieces'] as int? ?? 0,
      datesReceived: map['dates_received'] as int? ?? 0,
      wheatBags: map['wheat_bags'] as int? ?? 0,
      wheatPieces: map['wheat_pieces'] as int? ?? 0,
      wheatReceived: map['wheat_received'] as int? ?? 0,
      meatKg: (map['meat_kg'] as num?)?.toDouble() ?? 0.0,
      meatReceived: map['meat_received'] as int? ?? 0,
      basketCount: map['basket_count'] as int? ?? 0,
      basketReceived: map['basket_received'] as int? ?? 0,
      overallStatus: map['overall_status'] as String? ?? 'PENDING',
      receivedAt: map['received_at'] as int?,
      receivedBy: map['received_by'] as int?,
      notes: map['notes'] as String? ?? '',
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory DistributionModel.fromJson(Map<String, dynamic> json) =>
      DistributionModel.fromMap(json);
}
