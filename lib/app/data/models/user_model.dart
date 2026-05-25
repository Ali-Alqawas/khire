class UserModel {
  final int? id;
  final String username;
  final String passwordHash;
  final String fullName;
  final String role;
  final int isActive;
  final int createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.fullName,
    this.role = 'USER',
    this.isActive = 1,
    required this.createdAt,
  });

  bool get isAdmin => role == 'ADMIN';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password_hash': passwordHash,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      fullName: map['full_name'] as String,
      role: map['role'] as String? ?? 'USER',
      isActive: map['is_active'] as int? ?? 1,
      createdAt: map['created_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromMap(json);
}
