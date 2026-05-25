class YearModel {
  final int? id;
  final int villageId;
  final String yearName;
  final int isArchived;
  final int createdAt;

  YearModel({
    this.id,
    required this.villageId,
    required this.yearName,
    this.isArchived = 0,
    required this.createdAt,
  });

  bool get isArchivedBool => isArchived == 1;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'village_id': villageId,
      'year_name': yearName,
      'is_archived': isArchived,
      'created_at': createdAt,
    };
  }

  factory YearModel.fromMap(Map<String, dynamic> map) {
    return YearModel(
      id: map['id'] as int?,
      villageId: map['village_id'] as int,
      yearName: map['year_name'] as String,
      isArchived: map['is_archived'] as int? ?? 0,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory YearModel.fromJson(Map<String, dynamic> json) =>
      YearModel.fromMap(json);
}
