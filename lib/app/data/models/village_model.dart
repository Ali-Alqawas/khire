class VillageModel {
  final int? id;
  final String name;
  final String description;
  final int isActive;
  final int createdAt;

  VillageModel({
    this.id,
    required this.name,
    this.description = '',
    this.isActive = 1,
    required this.createdAt,
  });

  bool get isActiveBool => isActive == 1;

  VillageModel copyWith({
    int? id,
    String? name,
    String? description,
    int? isActive,
    int? createdAt,
  }) {
    return VillageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  factory VillageModel.fromMap(Map<String, dynamic> map) {
    return VillageModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      isActive: map['is_active'] as int? ?? 1,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory VillageModel.fromJson(Map<String, dynamic> json) =>
      VillageModel.fromMap(json);
}
