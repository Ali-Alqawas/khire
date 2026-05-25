import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/beneficiary_model.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../../../data/providers/database_helper.dart';
import '../../../data/services/csv_service.dart';

class BeneficiariesController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CsvService _csvService = CsvService.instance;

  final isLoading = false.obs;
  final isImporting = false.obs;
  final villages = <VillageModel>[].obs;
  final selectedVillage = Rx<VillageModel?>(null);
  final years = <YearModel>[].obs;
  final selectedYear = Rx<YearModel?>(null);
  final beneficiaries = <Map<String, dynamic>>[].obs;
  final filteredBeneficiaries = <Map<String, dynamic>>[].obs;
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final notesController = TextEditingController();
  final bulkNamesController = TextEditingController();
  final searchQuery = ''.obs;
  final statusFilter = 'ALL'.obs;

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
        await loadBeneficiaries();
      }
    } catch (e) {
      Helpers.showError('فشل تحميل السنوات');
    }
  }

  Future<void> loadBeneficiaries() async {
    if (selectedYear.value == null) return;
    isLoading.value = true;
    try {
      beneficiaries.value = await _dbHelper.getDistributionsWithBeneficiaries(
        selectedYear.value!.id!,
      );
      _applyFilters();
    } catch (e) {
      Helpers.showError('فشل تحميل المستفيدين');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    var list = beneficiaries.toList();
    if (statusFilter.value != 'ALL') {
      list = list.where((b) =>
        b['overall_status'] == statusFilter.value
      ).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      list = list.where((b) =>
        (b['beneficiary_name'] as String)
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    filteredBeneficiaries.value = list;
  }

  void filterByStatus(String status) {
    statusFilter.value = status;
    _applyFilters();
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  Future<void> addBeneficiary() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Helpers.showWarning('يرجى إدخال اسم المستفيد');
      return;
    }
    if (selectedYear.value == null) return;
    try {
      final existing = await _dbHelper.getBeneficiaryByNameAndYear(
        name,
        selectedYear.value!.id!,
      );
      if (existing != null) {
        Helpers.showWarning('المستفيد "$name" موجود مسبقاً');
        return;
      }
      await _dbHelper.insertBeneficiary(BeneficiaryModel(
        yearId: selectedYear.value!.id!,
        name: name,
        notes: notesController.text.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      Helpers.showSuccess('تم إضافة المستفيد بنجاح');
      nameController.clear();
      notesController.clear();
      Get.back();
      await loadBeneficiaries();
    } catch (e) {
      Helpers.showError('فشل إضافة المستفيد');
    }
  }

  Future<void> addMultipleBeneficiaries() async {
    final text = bulkNamesController.text.trim();
    if (text.isEmpty) {
      Helpers.showWarning('يرجى إدخال أسماء المستفيدين');
      return;
    }
    if (selectedYear.value == null) return;
    isLoading.value = true;
    try {
      final names = text
          .split('\n')
          .map((n) => n.trim())
          .where((n) => n.isNotEmpty)
          .toList();
      int added = 0;
      int skipped = 0;
      for (final name in names) {
        final existing = await _dbHelper.getBeneficiaryByNameAndYear(
          name,
          selectedYear.value!.id!,
        );
        if (existing == null) {
          await _dbHelper.insertBeneficiary(BeneficiaryModel(
            yearId: selectedYear.value!.id!,
            name: name,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
          added++;
        } else {
          skipped++;
        }
      }
      Helpers.showSuccess('تم إضافة $added مستفيد${skipped > 0 ? ', تجاوز $skipped مكرر' : ''}');
      bulkNamesController.clear();
      Get.back();
      await loadBeneficiaries();
    } catch (e) {
      Helpers.showError('فشل إضافة المستفيدين');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> importFromFile() async {
    if (selectedYear.value == null) {
      Helpers.showWarning('يرجى اختيار السنة أولاً');
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );
      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.first.path;
      if (filePath == null) return;
      isImporting.value = true;
      final names = await _csvService.parseImportedFile(filePath);
      if (names.isEmpty) {
        Helpers.showWarning('لم يتم العثور على أسماء في الملف');
        return;
      }
      final imported = await _dbHelper.importBeneficiaries(
        names,
        selectedYear.value!.id!,
      );
      Helpers.showSuccess('تم استيراد $imported من ${names.length} اسم');
      await loadBeneficiaries();
    } catch (e) {
      Helpers.showError('فشل استيراد الملف');
    } finally {
      isImporting.value = false;
    }
  }

  Future<void> deleteBeneficiary(int id) async {
    final confirmed = await Helpers.confirmDelete(
      message: 'هل أنت متأكد من حذف هذا المستفيد؟',
    );
    if (confirmed) {
      try {
        await _dbHelper.deleteBeneficiary(id);
        Helpers.showSuccess('تم حذف المستفيد');
        await loadBeneficiaries();
      } catch (e) {
        Helpers.showError('فشل حذف المستفيد');
      }
    }
  }

  String getStatusArabic(String status) => Helpers.statusArabic(status);
  Color getStatusColor(String status) => Helpers.statusColor(status);

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    notesController.dispose();
    bulkNamesController.dispose();
    super.onClose();
  }
}
