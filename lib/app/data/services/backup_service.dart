import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  BackupService._init();

  Future<String> _getBackupDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  Future<String?> createBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final source = p.join(dbPath, AppConstants.dbName);
      final backupDir = await _getBackupDir();
      final timestamp = DateTime.now()
          .millisecondsSinceEpoch
          .toString();
      final dest = p.join(backupDir, 'khire_backup_$timestamp.db');
      await File(source).copy(dest);
      return dest;
    } catch (e) {
      Helpers.showError('فشل إنشاء النسخة الاحتياطية: $e');
      return null;
    }
  }

  Future<bool> restoreBackup(String backupPath) async {
    try {
      final dbPath = await getDatabasesPath();
      final dest = p.join(dbPath, AppConstants.dbName);
      await File(backupPath).copy(dest);
      return true;
    } catch (e) {
      Helpers.showError('فشل استعادة النسخة الاحتياطية: $e');
      return false;
    }
  }

  Future<List<String>> getBackupList() async {
    try {
      final backupDir = await _getBackupDir();
      final dir = Directory(backupDir);
      if (!await dir.exists()) return [];
      final files = await dir.list().where((entity) =>
          entity is File &&
          p.extension(entity.path) == '.db').map((e) => e.path).toList();
      files.sort((a, b) => File(b).lastModifiedSync().compareTo(
          File(a).lastModifiedSync()));
      return files;
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteBackup(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
