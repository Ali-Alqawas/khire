import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/village_model.dart';
import '../models/year_model.dart';
import '../models/beneficiary_model.dart';
import '../models/distribution_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'USER',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE villages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT DEFAULT '',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE years (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        village_id INTEGER NOT NULL,
        year_name TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (village_id) REFERENCES villages(id),
        UNIQUE(village_id, year_name)
      )
    ''');

    await db.execute('''
      CREATE TABLE beneficiaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        notes TEXT DEFAULT '',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (year_id) REFERENCES years(id),
        UNIQUE(year_id, name)
      )
    ''');

    await db.execute('''
      CREATE TABLE distributions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        beneficiary_id INTEGER NOT NULL UNIQUE,
        dates_boxes INTEGER DEFAULT 0,
        dates_pieces INTEGER DEFAULT 0,
        dates_received INTEGER DEFAULT 0,
        wheat_bags INTEGER DEFAULT 0,
        wheat_pieces INTEGER DEFAULT 0,
        wheat_received INTEGER DEFAULT 0,
        meat_kg REAL DEFAULT 0.0,
        meat_received INTEGER DEFAULT 0,
        basket_count INTEGER DEFAULT 0,
        basket_received INTEGER DEFAULT 0,
        overall_status TEXT DEFAULT 'PENDING',
        received_at INTEGER,
        received_by INTEGER,
        notes TEXT DEFAULT '',
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(id),
        FOREIGN KEY (received_by) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Future upgrades
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // ============ USERS ============

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'full_name ASC');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ============ VILLAGES ============

  Future<int> insertVillage(VillageModel village) async {
    final db = await database;
    return await db.insert('villages', village.toMap());
  }

  Future<List<VillageModel>> getAllVillages() async {
    final db = await database;
    final result = await db.query(
      'villages',
      orderBy: 'name ASC',
    );
    return result.map((map) => VillageModel.fromMap(map)).toList();
  }

  Future<List<VillageModel>> getActiveVillages() async {
    final db = await database;
    final result = await db.query(
      'villages',
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
    return result.map((map) => VillageModel.fromMap(map)).toList();
  }

  Future<VillageModel?> getVillageById(int id) async {
    final db = await database;
    final result = await db.query(
      'villages',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return VillageModel.fromMap(result.first);
  }

  Future<int> updateVillage(VillageModel village) async {
    final db = await database;
    return await db.update(
      'villages',
      village.toMap(),
      where: 'id = ?',
      whereArgs: [village.id],
    );
  }

  Future<int> deleteVillage(int id) async {
    final db = await database;
    return await db.delete('villages', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getVillageBeneficiaryCount(int villageId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM beneficiaries b
      INNER JOIN years y ON b.year_id = y.id
      WHERE y.village_id = ?
    ''', [villageId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getVillageStats(int villageId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT b.id) as total,
        SUM(CASE WHEN d.overall_status = 'RECEIVED' THEN 1 ELSE 0 END) as received,
        SUM(CASE WHEN d.overall_status = 'PARTIAL' THEN 1 ELSE 0 END) as partial,
        SUM(CASE WHEN (d.overall_status IS NULL OR d.overall_status = 'PENDING') THEN 1 ELSE 0 END) as pending
      FROM beneficiaries b
      INNER JOIN years y ON b.year_id = y.id
      LEFT JOIN distributions d ON b.id = d.beneficiary_id
      WHERE y.village_id = ?
    ''', [villageId]);
    if (result.isEmpty) {
      return {'total': 0, 'received': 0, 'partial': 0, 'pending': 0};
    }
    final row = result.first;
    return {
      'total': (row['total'] as int?) ?? 0,
      'received': (row['received'] as int?) ?? 0,
      'partial': (row['partial'] as int?) ?? 0,
      'pending': (row['pending'] as int?) ?? 0,
    };
  }

  // ============ YEARS ============

  Future<int> insertYear(YearModel year) async {
    final db = await database;
    return await db.insert('years', year.toMap());
  }

  Future<List<YearModel>> getYearsByVillage(int villageId) async {
    final db = await database;
    final result = await db.query(
      'years',
      where: 'village_id = ?',
      whereArgs: [villageId],
      orderBy: 'year_name DESC',
    );
    return result.map((map) => YearModel.fromMap(map)).toList();
  }

  Future<List<YearModel>> getActiveYearsByVillage(int villageId) async {
    final db = await database;
    final result = await db.query(
      'years',
      where: 'village_id = ? AND is_archived = 0',
      whereArgs: [villageId],
      orderBy: 'year_name DESC',
    );
    return result.map((map) => YearModel.fromMap(map)).toList();
  }

  Future<YearModel?> getYearById(int id) async {
    final db = await database;
    final result = await db.query(
      'years',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return YearModel.fromMap(result.first);
  }

  Future<int> updateYear(YearModel year) async {
    final db = await database;
    return await db.update(
      'years',
      year.toMap(),
      where: 'id = ?',
      whereArgs: [year.id],
    );
  }

  Future<int> deleteYear(int id) async {
    final db = await database;
    return await db.delete('years', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> archiveYear(int id) async {
    final db = await database;
    return await db.update(
      'years',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ BENEFICIARIES ============

  Future<int> insertBeneficiary(BeneficiaryModel beneficiary) async {
    final db = await database;
    return await db.insert('beneficiaries', beneficiary.toMap());
  }

  Future<List<BeneficiaryModel>> getBeneficiariesByYear(int yearId) async {
    final db = await database;
    final result = await db.query(
      'beneficiaries',
      where: 'year_id = ?',
      whereArgs: [yearId],
      orderBy: 'name ASC',
    );
    return result.map((map) => BeneficiaryModel.fromMap(map)).toList();
  }

  Future<BeneficiaryModel?> getBeneficiaryById(int id) async {
    final db = await database;
    final result = await db.query(
      'beneficiaries',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return BeneficiaryModel.fromMap(result.first);
  }

  Future<BeneficiaryModel?> getBeneficiaryByNameAndYear(
      String name, int yearId) async {
    final db = await database;
    final result = await db.query(
      'beneficiaries',
      where: 'name = ? AND year_id = ?',
      whereArgs: [name, yearId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return BeneficiaryModel.fromMap(result.first);
  }

  Future<int> updateBeneficiary(BeneficiaryModel beneficiary) async {
    final db = await database;
    return await db.update(
      'beneficiaries',
      beneficiary.toMap(),
      where: 'id = ?',
      whereArgs: [beneficiary.id],
    );
  }

  Future<int> deleteBeneficiary(int id) async {
    final db = await database;
    return await db.delete(
      'beneficiaries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getBeneficiaryCountByYear(int yearId) async {
    final db = await database;
    final result = await db.query(
      'beneficiaries',
      where: 'year_id = ?',
      whereArgs: [yearId],
      columns: ['id'],
    );
    return result.length;
  }

  Future<List<String>> searchBeneficiaries(int yearId, String query) async {
    final db = await database;
    final result = await db.query(
      'beneficiaries',
      where: 'year_id = ? AND name LIKE ?',
      whereArgs: [yearId, '%$query%'],
      orderBy: 'name ASC',
      limit: 20,
    );
    return result.map((map) => map['name'] as String).toList();
  }

  Future<int> importBeneficiaries(List<String> names, int yearId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    int imported = 0;
    for (final name in names) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) continue;
      final existing = await getBeneficiaryByNameAndYear(trimmed, yearId);
      if (existing == null) {
        await insertBeneficiary(BeneficiaryModel(
          yearId: yearId,
          name: trimmed,
          createdAt: now,
        ));
        imported++;
      }
    }
    return imported;
  }

  // ============ DISTRIBUTIONS ============

  Future<int> insertOrUpdateDistribution(DistributionModel dist) async {
    final db = await database;
    final existing = await db.query(
      'distributions',
      where: 'beneficiary_id = ?',
      whereArgs: [dist.beneficiaryId],
      limit: 1,
    );
    if (existing.isEmpty) {
      return await db.insert('distributions', dist.toMap());
    } else {
      return await db.update(
        'distributions',
        dist.toMap(),
        where: 'beneficiary_id = ?',
        whereArgs: [dist.beneficiaryId],
      );
    }
  }

  Future<DistributionModel?> getDistributionByBeneficiary(
      int beneficiaryId) async {
    final db = await database;
    final result = await db.query(
      'distributions',
      where: 'beneficiary_id = ?',
      whereArgs: [beneficiaryId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return DistributionModel.fromMap(result.first);
  }

  Future<List<Map<String, dynamic>>> getDistributionsWithBeneficiaries(
      int yearId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        b.id as beneficiary_id,
        b.name as beneficiary_name,
        b.notes as beneficiary_notes,
        COALESCE(d.dates_boxes, 0) as dates_boxes,
        COALESCE(d.dates_pieces, 0) as dates_pieces,
        COALESCE(d.dates_received, 0) as dates_received,
        COALESCE(d.wheat_bags, 0) as wheat_bags,
        COALESCE(d.wheat_pieces, 0) as wheat_pieces,
        COALESCE(d.wheat_received, 0) as wheat_received,
        COALESCE(d.meat_kg, 0.0) as meat_kg,
        COALESCE(d.meat_received, 0) as meat_received,
        COALESCE(d.basket_count, 0) as basket_count,
        COALESCE(d.basket_received, 0) as basket_received,
        COALESCE(d.overall_status, 'PENDING') as overall_status,
        d.received_at,
        d.received_by,
        COALESCE(d.notes, '') as distribution_notes,
        d.updated_at
      FROM beneficiaries b
      LEFT JOIN distributions d ON b.id = d.beneficiary_id
      WHERE b.year_id = ?
      ORDER BY b.name ASC
    ''', [yearId]);
  }

  Future<Map<String, dynamic>> getYearStats(int yearId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT b.id) as total,
        SUM(CASE WHEN d.overall_status = 'RECEIVED' THEN 1 ELSE 0 END) as received,
        SUM(CASE WHEN d.overall_status = 'PARTIAL' THEN 1 ELSE 0 END) as partial,
        SUM(CASE WHEN (d.overall_status IS NULL OR d.overall_status = 'PENDING') THEN 1 ELSE 0 END) as pending,
        COALESCE(SUM(d.dates_boxes), 0) as total_dates_boxes,
        COALESCE(SUM(d.dates_pieces), 0) as total_dates_pieces,
        COALESCE(SUM(d.wheat_bags), 0) as total_wheat_bags,
        COALESCE(SUM(d.wheat_pieces), 0) as total_wheat_pieces,
        COALESCE(SUM(d.meat_kg), 0.0) as total_meat_kg,
        COALESCE(SUM(d.basket_count), 0) as total_baskets
      FROM beneficiaries b
      LEFT JOIN distributions d ON b.id = d.beneficiary_id
      WHERE b.year_id = ?
    ''', [yearId]);
    if (result.isEmpty) {
      return {
        'total': 0,
        'received': 0,
        'partial': 0,
        'pending': 0,
        'total_dates_boxes': 0,
        'total_dates_pieces': 0,
        'total_wheat_bags': 0,
        'total_wheat_pieces': 0,
        'total_meat_kg': 0.0,
        'total_baskets': 0,
      };
    }
    return result.first;
  }

  Future<List<Map<String, dynamic>>> getDistributionsByStatus(
      int yearId, String status) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT b.*, d.*
      FROM beneficiaries b
      LEFT JOIN distributions d ON b.id = d.beneficiary_id
      WHERE b.year_id = ?
      AND (d.overall_status = ? OR (d.overall_status IS NULL AND ? = 'PENDING'))
      ORDER BY b.name ASC
    ''', [yearId, status, status]);
  }

  Future<int> deleteDistribution(int beneficiaryId) async {
    final db = await database;
    return await db.delete(
      'distributions',
      where: 'beneficiary_id = ?',
      whereArgs: [beneficiaryId],
    );
  }
}
