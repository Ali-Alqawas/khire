import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as share;
import '../../core/utils/helpers.dart';
import '../providers/database_helper.dart';

class CsvService {
  static final CsvService instance = CsvService._init();
  CsvService._init();

  final _dbHelper = DatabaseHelper.instance;

  Future<List<String>> parseImportedFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final extension = file.path.split('.').last.toLowerCase();

      List<String> names = [];

      if (extension == 'csv') {
        final rows = const CsvToListConverter().convert(content);
        for (final row in rows) {
          if (row.isNotEmpty) {
            final name = row[0].toString().trim();
            if (name.isNotEmpty) names.add(name);
          }
        }
      } else {
        names = content
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
      }

      return names;
    } catch (e) {
      Helpers.showError('فشل قراءة الملف: $e');
      return [];
    }
  }

  Future<String?> exportToCsv(int yearId) async {
    try {
      final data = await _dbHelper.getDistributionsWithBeneficiaries(yearId);
      if (data.isEmpty) {
        Helpers.showWarning('لا توجد بيانات للتصدير');
        return null;
      }

      final header = [
        'الاسم',
        'كراتين التمر',
        'حبات التمر',
        'التمر مستلم',
        'أكياس البر',
        'قطمات البر',
        'البر مستلم',
        'اللحوم (كجم)',
        'اللحوم مستلم',
        'عدد السلال',
        'السلال مستلمة',
        'الحالة العامة',
        'ملاحظات',
      ];

      final rows = <List<dynamic>>[header];
      for (final row in data) {
        rows.add([
          row['beneficiary_name'] ?? '',
          row['dates_boxes'] ?? 0,
          row['dates_pieces'] ?? 0,
          (row['dates_received'] ?? 0) == 1 ? 'نعم' : 'لا',
          row['wheat_bags'] ?? 0,
          row['wheat_pieces'] ?? 0,
          (row['wheat_received'] ?? 0) == 1 ? 'نعم' : 'لا',
          row['meat_kg'] ?? 0.0,
          (row['meat_received'] ?? 0) == 1 ? 'نعم' : 'لا',
          row['basket_count'] ?? 0,
          (row['basket_received'] ?? 0) == 1 ? 'نعم' : 'لا',
          _statusArabic(row['overall_status']?.toString() ?? 'PENDING'),
          row['distribution_notes'] ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/report_$yearId.csv');
      await file.writeAsString(csv);
      return file.path;
    } catch (e) {
      Helpers.showError('فشل تصدير CSV: $e');
      return null;
    }
  }

  Future<void> shareFile(String path) async {
    try {
      await share.SharePlus.instance.share(
        share.ShareParams(files: [share.XFile(path)]),
      );
    } catch (e) {
      Helpers.showError('فشل مشاركة الملف: $e');
    }
  }

  String _statusArabic(String status) {
    switch (status) {
      case 'RECEIVED':
        return 'تم الاستلام';
      case 'PARTIAL':
        return 'استلام جزئي';
      default:
        return 'لم يستلم';
    }
  }
}
