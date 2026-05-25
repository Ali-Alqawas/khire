import 'package:get/get.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../../../data/providers/database_helper.dart';
import '../../../data/services/csv_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportsController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CsvService _csvService = CsvService.instance;

  final isLoading = false.obs;
  final isExporting = false.obs;

  final villages = <VillageModel>[].obs;
  final selectedVillage = Rx<VillageModel?>(null);
  final years = <YearModel>[].obs;
  final selectedYear = Rx<YearModel?>(null);

  // Stats
  final totalBeneficiaries = 0.obs;
  final receivedCount = 0.obs;
  final partialCount = 0.obs;
  final pendingCount = 0.obs;

  final totalDatesBoxes = 0.obs;
  final totalDatesPieces = 0.obs;
  final totalWheatBags = 0.obs;
  final totalWheatPieces = 0.obs;
  final totalMeatKg = 0.0.obs;
  final totalBaskets = 0.obs;

  final distributionData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadVillages();
  }

  Future<void> loadVillages() async {
    try {
      villages.value = await _dbHelper.getActiveVillages();
      if (villages.isNotEmpty && selectedVillage.value == null) {
        selectedVillage.value = villages.first;
        await loadYears();
      }
    } catch (e) {
      Helpers.showError('فشل تحميل القرى');
    }
  }

  Future<void> loadYears() async {
    if (selectedVillage.value == null) return;
    try {
      years.value = await _dbHelper.getActiveYearsByVillage(
        selectedVillage.value!.id!,
      );
      if (years.isNotEmpty) {
        selectedYear.value = years.first;
        await loadReport();
      }
    } catch (e) {
      Helpers.showError('فشل تحميل السنوات');
    }
  }

  Future<void> loadReport() async {
    if (selectedYear.value == null) return;
    isLoading.value = true;
    try {
      final stats = await _dbHelper.getYearStats(selectedYear.value!.id!);
      totalBeneficiaries.value = (stats['total'] as int?) ?? 0;
      receivedCount.value = (stats['received'] as int?) ?? 0;
      partialCount.value = (stats['partial'] as int?) ?? 0;
      pendingCount.value = (stats['pending'] as int?) ?? 0;
      totalDatesBoxes.value = (stats['total_dates_boxes'] as int?) ?? 0;
      totalDatesPieces.value = (stats['total_dates_pieces'] as int?) ?? 0;
      totalWheatBags.value = (stats['total_wheat_bags'] as int?) ?? 0;
      totalWheatPieces.value = (stats['total_wheat_pieces'] as int?) ?? 0;
      totalMeatKg.value = (stats['total_meat_kg'] as num?)?.toDouble() ?? 0.0;
      totalBaskets.value = (stats['total_baskets'] as int?) ?? 0;

      distributionData.value =
          await _dbHelper.getDistributionsWithBeneficiaries(selectedYear.value!.id!);
    } catch (e) {
      Helpers.showError('فشل تحميل التقرير');
    } finally {
      isLoading.value = false;
    }
  }

  double get completionRate {
    if (totalBeneficiaries.value == 0) return 0;
    return (receivedCount.value + partialCount.value) / totalBeneficiaries.value;
  }

  Future<void> exportToCsv() async {
    if (selectedYear.value == null) return;
    isExporting.value = true;
    try {
      final path = await _csvService.exportToCsv(selectedYear.value!.id!);
      if (path != null) {
        await _csvService.shareFile(path);
      }
    } catch (e) {
      Helpers.showError('فشل تصدير CSV');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportToPdf() async {
    if (selectedYear.value == null) return;
    isExporting.value = true;
    try {
      final pdf = pw.Document();
      final data = await _dbHelper.getDistributionsWithBeneficiaries(
        selectedYear.value!.id!,
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          header: (context) => pw.Header(
            level: 0,
            child: pw.Text(
              'تقرير توزيع المساعدات - ${selectedYear.value!.yearName}',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          build: (context) => [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Paragraph(
                    text: 'القرية: ${selectedVillage.value?.name ?? ""}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Paragraph(
                    text: 'إجمالي المستفيدين: ${totalBeneficiaries.value} | تم الاستلام: ${receivedCount.value} | استلام جزئي: ${partialCount.value} | لم يستلم: ${pendingCount.value}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(height: 20),
                  _buildPdfTable(data),
                ],
              ),
            ),
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'report_${selectedYear.value!.yearName}.pdf',
      );
    } catch (e) {
      Helpers.showError('فشل تصدير PDF');
    } finally {
      isExporting.value = false;
    }
  }

  pw.Widget _buildPdfTable(List<Map<String, dynamic>> data) {
    final rows = data.map((item) => [
      item['beneficiary_name'] ?? '',
      _statusArabic(item['overall_status']?.toString() ?? 'PENDING'),
      '${item['dates_boxes'] ?? 0} / ${item['dates_pieces'] ?? 0}',
      '${item['wheat_bags'] ?? 0} / ${item['wheat_pieces'] ?? 0}',
      '${item['meat_kg'] ?? 0} كجم',
      '${item['basket_count'] ?? 0}',
    ]).toList();

    return pw.TableHelper.fromTextArray(
      headerAlignment: pw.Alignment.center,
      cellAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      cellStyle: pw.TextStyle(fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: PdfColors.green800),
      headers: ['الاسم', 'الحالة', 'التمر', 'البر', 'اللحوم', 'السلال'],
      data: rows,
    );
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

  String getStatusArabic(String status) => Helpers.statusArabic(status);
}
