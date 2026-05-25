import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../providers/database_helper.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  final _dbHelper = DatabaseHelper.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<AuthService> init() async {
    await _ensureAdminExists();
    await _loadSession();
    return this;
  }

  Future<void> _ensureAdminExists() async {
    final existingAdmin =
        await _dbHelper.getUserByUsername(AppConstants.defaultAdminUsername);
    if (existingAdmin == null) {
      await _dbHelper.insertUser(UserModel(
        username: AppConstants.defaultAdminUsername,
        passwordHash: _hashPassword(AppConstants.defaultAdminPassword),
        fullName: AppConstants.defaultAdminName,
        role: AppConstants.roleAdmin,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }
  }

  Future<UserModel?> login(String username, String password) async {
    final user = await _dbHelper.getUserByUsername(username);
    if (user == null) return null;
    if (user.isActive == 0) return null;

    final hashedPassword = _hashPassword(password);
    if (user.passwordHash != hashedPassword) return null;

    _currentUser = user;
    await _saveSession(user);
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.remove('current_user');
    await _storage.remove('session_token');
  }

  Future<void> _saveSession(UserModel user) async {
    await _storage.write('current_user', user.toJson());
    await _storage.write('session_token', _generateToken());
  }

  Future<void> _loadSession() async {
    final userData = _storage.read<Map<String, dynamic>>('current_user');
    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
    }
  }

  String _generateToken() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return sha256.convert(utf8.encode('$_currentUser$now')).toString();
  }

  Future<bool> changePassword(int userId, String oldPassword, String newPassword) async {
    final user = await _dbHelper.getUserById(userId);
    if (user == null) return false;
    if (user.passwordHash != _hashPassword(oldPassword)) return false;
    await _dbHelper.updateUser(UserModel(
      id: user.id,
      username: user.username,
      passwordHash: _hashPassword(newPassword),
      fullName: user.fullName,
      role: user.role,
      isActive: user.isActive,
      createdAt: user.createdAt,
    ));
    return true;
  }

  Future<UserModel?> createUser(String username, String password, String fullName, String role) async {
    final existing = await _dbHelper.getUserByUsername(username);
    if (existing != null) return null;
    final id = await _dbHelper.insertUser(UserModel(
      username: username,
      passwordHash: _hashPassword(password),
      fullName: fullName,
      role: role,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
    return await _dbHelper.getUserById(id);
  }

  Future<List<UserModel>> getAllUsers() => _dbHelper.getAllUsers();
  Future<int> deleteUser(int id) => _dbHelper.deleteUser(id);
  Future<int> updateUser(UserModel user) => _dbHelper.updateUser(user);
}
