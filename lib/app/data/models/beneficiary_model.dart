class BeneficiaryModel {
  final int? id;
  final int yearId;
  final String name;
  final String notes;
  final int createdAt;

  BeneficiaryModel({
    this.id,
    required this.yearId,
    required this.name,
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'year_id': yearId,
      'name': name,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory BeneficiaryModel.fromMap(Map<String, dynamic> map) {
    return BeneficiaryModel(
      id: map['id'] as int?,
      yearId: map['year_id'] as int,
      name: map['name'] as String,
      notes: map['notes'] as String? ?? '',
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) =>
      BeneficiaryModel.fromMap(json);
}
