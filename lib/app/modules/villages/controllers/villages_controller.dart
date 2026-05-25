import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../../../data/providers/database_helper.dart';

class VillagesController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final isLoading = false.obs;
  final villages = <VillageModel>[].obs;
  final villageNameController = TextEditingController();
  final villageDescController = TextEditingController();

  // Years
  final years = <YearModel>[].obs;
  final selectedVillage = Rx<VillageModel?>(null);
  final yearNameController = TextEditingController();
  final showYearSection = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadVillages();
  }

  Future<void> loadVillages() async {
    isLoading.value = true;
    try {
      villages.value = await _dbHelper.getAllVillages();
    } catch (e) {
      Helpers.showError('فشل تحميل القرى');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addVillage() async {
    final name = villageNameController.text.trim();
    if (name.isEmpty) {
      Helpers.showWarning('يرجى إدخال اسم القرية');
      return;
    }
    try {
      await _dbHelper.insertVillage(VillageModel(
        name: name,
        description: villageDescController.text.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      Helpers.showSuccess('تم إضافة القرية بنجاح');
      villageNameController.clear();
      villageDescController.clear();
      Get.back();
      await loadVillages();
    } catch (e) {
      Helpers.showError('فشل إضافة القرية (قد تكون موجودة مسبقاً)');
    }
  }

  Future<void> updateVillage(VillageModel village) async {
    try {
      await _dbHelper.updateVillage(village);
      Helpers.showSuccess('تم تحديث القرية بنجاح');
      await loadVillages();
    } catch (e) {
      Helpers.showError('فشل تحديث القرية');
    }
  }

  Future<void> deleteVillage(VillageModel village) async {
    final confirmed = await Helpers.confirmDelete(
      message: 'هل أنت متأكد من حذف قرية "${village.name}"؟',
    );
    if (confirmed) {
      try {
        await _dbHelper.deleteVillage(village.id!);
        Helpers.showSuccess('تم حذف القرية بنجاح');
        await loadVillages();
      } catch (e) {
        Helpers.showError('فشل حذف القرية');
      }
    }
  }

  void selectVillage(VillageModel village) {
    selectedVillage.value = village;
    loadYears();
    showYearSection.value = true;
  }

  Future<void> loadYears() async {
    if (selectedVillage.value == null) return;
    try {
      years.value = await _dbHelper.getYearsByVillage(
        selectedVillage.value!.id!,
      );
    } catch (e) {
      Helpers.showError('فشل تحميل السنوات');
    }
  }

  Future<void> addYear() async {
    final name = yearNameController.text.trim();
    if (name.isEmpty) {
      Helpers.showWarning('يرجى إدخال اسم السنة');
      return;
    }
    if (selectedVillage.value == null) return;
    try {
      await _dbHelper.insertYear(YearModel(
        villageId: selectedVillage.value!.id!,
        yearName: name,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      Helpers.showSuccess('تم إضافة السنة بنجاح');
      yearNameController.clear();
      Get.back();
      await loadYears();
    } catch (e) {
      Helpers.showError('فشل إضافة السنة (قد تكون موجودة مسبقاً)');
    }
  }

  Future<void> archiveYear(YearModel year) async {
    try {
      await _dbHelper.archiveYear(year.id!);
      Helpers.showSuccess('تم أرشفة السنة بنجاح');
      await loadYears();
    } catch (e) {
      Helpers.showError('فشل أرشفة السنة');
    }
  }

  Future<void> deleteYear(YearModel year) async {
    final confirmed = await Helpers.confirmDelete(
      message: 'هل أنت متأكد من حذف سنة "${year.yearName}"؟',
    );
    if (confirmed) {
      try {
        await _dbHelper.deleteYear(year.id!);
        Helpers.showSuccess('تم حذف السنة بنجاح');
        await loadYears();
      } catch (e) {
        Helpers.showError('فشل حذف السنة');
      }
    }
  }

  @override
  void onClose() {
    villageNameController.dispose();
    villageDescController.dispose();
    yearNameController.dispose();
    super.onClose();
  }
}
