import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/distribution_model.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../../../data/providers/database_helper.dart';
import '../../../data/services/auth_service.dart';

class DistributionController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = Get.find();

  final isLoading = false.obs;
  final isSaving = false.obs;

  // Selectors
  final villages = <VillageModel>[].obs;
  final selectedVillage = Rx<VillageModel?>(null);
  final years = <YearModel>[].obs;
  final selectedYear = Rx<YearModel?>(null);
  final beneficiaries = <Map<String, dynamic>>[].obs;
  final filteredBeneficiaries = <Map<String, dynamic>>[].obs;

  // Current beneficiary
  final currentBeneficiary = Rx<Map<String, dynamic>?>(null);

  // Distribution counters
  final datesBoxes = 0.obs;
  final datesPieces = 0.obs;
  final datesReceived = false.obs;

  final wheatBags = 0.obs;
  final wheatPieces = 0.obs;
  final wheatReceived = false.obs;

  final meatKg = 0.0.obs;
  final meatReceived = false.obs;

  final basketCount = 0.obs;
  final basketReceived = false.obs;

  final notesController = TextEditingController();
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

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
      _applyFilter();
    } catch (e) {
      Helpers.showError('فشل تحميل المستفيدين');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var list = beneficiaries.toList();
    if (searchQuery.value.isNotEmpty) {
      list = list.where((b) =>
        (b['beneficiary_name'] as String)
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    filteredBeneficiaries.value = list;
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  Future<void> selectBeneficiary(int beneficiaryId) async {
    isLoading.value = true;
    try {
      final ben = beneficiaries.firstWhere(
        (b) => b['beneficiary_id'] == beneficiaryId,
        orElse: () => <String, dynamic>{},
      );
      if (ben.isEmpty) {
        Helpers.showError('المستفيد غير موجود');
        return;
      }
      currentBeneficiary.value = ben;
      _loadDistributionData(ben);
    } catch (e) {
      Helpers.showError('فشل تحميل بيانات المستفيد');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDistributionData(Map<String, dynamic> data) {
    datesBoxes.value = (data['dates_boxes'] as int?) ?? 0;
    datesPieces.value = (data['dates_pieces'] as int?) ?? 0;
    datesReceived.value = (data['dates_received'] as int?) == 1;

    wheatBags.value = (data['wheat_bags'] as int?) ?? 0;
    wheatPieces.value = (data['wheat_pieces'] as int?) ?? 0;
    wheatReceived.value = (data['wheat_received'] as int?) == 1;

    meatKg.value = (data['meat_kg'] as num?)?.toDouble() ?? 0.0;
    meatReceived.value = (data['meat_received'] as int?) == 1;

    basketCount.value = (data['basket_count'] as int?) ?? 0;
    basketReceived.value = (data['basket_received'] as int?) == 1;

    notesController.text = data['distribution_notes'] as String? ?? '';
  }

  // Counter methods
  void incrementDatesBoxes() => datesBoxes.value++;
  void decrementDatesBoxes() {
    if (datesBoxes.value > 0) datesBoxes.value--;
  }
  void incrementDatesPieces() => datesPieces.value++;
  void decrementDatesPieces() {
    if (datesPieces.value > 0) datesPieces.value--;
  }

  void incrementWheatBags() => wheatBags.value++;
  void decrementWheatBags() {
    if (wheatBags.value > 0) wheatBags.value--;
  }
  void incrementWheatPieces() => wheatPieces.value++;
  void decrementWheatPieces() {
    if (wheatPieces.value > 0) wheatPieces.value--;
  }

  void incrementMeat() {
    meatKg.value = double.parse((meatKg.value + 0.5).toStringAsFixed(1));
  }
  void decrementMeat() {
    if (meatKg.value > 0) {
      meatKg.value = double.parse((meatKg.value - 0.5).toStringAsFixed(1));
    }
  }

  void incrementBasket() => basketCount.value++;
  void decrementBasket() {
    if (basketCount.value > 0) basketCount.value--;
  }

  void toggleDatesReceived() => datesReceived.value = !datesReceived.value;
  void toggleWheatReceived() => wheatReceived.value = !wheatReceived.value;
  void toggleMeatReceived() => meatReceived.value = !meatReceived.value;
  void toggleBasketReceived() => basketReceived.value = !basketReceived.value;

  String get overallStatus {
    final received = [
      datesReceived.value,
      wheatReceived.value,
      meatReceived.value,
      basketReceived.value,
    ];
    final receivedCount = received.where((r) => r).length;
    if (receivedCount == 0) return 'PENDING';
    if (receivedCount == 4) return 'RECEIVED';
    return 'PARTIAL';
  }

  Color get overallStatusColor {
    switch (overallStatus) {
      case 'RECEIVED':
        return AppColors.received;
      case 'PARTIAL':
        return AppColors.partial;
      default:
        return AppColors.pending;
    }
  }

  String get overallStatusText {
    switch (overallStatus) {
      case 'RECEIVED':
        return 'تم الاستلام بالكامل';
      case 'PARTIAL':
        return 'استلام جزئي';
      default:
        return 'لم يتم الاستلام';
    }
  }

  Future<void> saveDistribution() async {
    if (currentBeneficiary.value == null) return;
    isSaving.value = true;
    try {
      final beneficiaryId = currentBeneficiary.value!['beneficiary_id'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      final dist = DistributionModel(
        beneficiaryId: beneficiaryId,
        datesBoxes: datesBoxes.value,
        datesPieces: datesPieces.value,
        datesReceived: datesReceived.value ? 1 : 0,
        wheatBags: wheatBags.value,
        wheatPieces: wheatPieces.value,
        wheatReceived: wheatReceived.value ? 1 : 0,
        meatKg: meatKg.value,
        meatReceived: meatReceived.value ? 1 : 0,
        basketCount: basketCount.value,
        basketReceived: basketReceived.value ? 1 : 0,
        overallStatus: overallStatus,
        receivedAt: overallStatus == 'RECEIVED' ? now : null,
        receivedBy: _authService.currentUser?.id,
        notes: notesController.text.trim(),
        updatedAt: now,
      );
      await _dbHelper.insertOrUpdateDistribution(dist);
      Helpers.showSuccess('تم حفظ بيانات الاستلام بنجاح');
      await loadBeneficiaries();
      Get.back();
    } catch (e) {
      Helpers.showError('فشل حفظ البيانات: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteDistribution() async {
    if (currentBeneficiary.value == null) return;
    final confirmed = await Helpers.confirmDelete(
      message: 'هل أنت متأكد من حذف بيانات الاستلام لهذا المستفيد؟',
    );
    if (confirmed) {
      try {
        final beneficiaryId = currentBeneficiary.value!['beneficiary_id'] as int;
        await _dbHelper.deleteDistribution(beneficiaryId);
        Helpers.showSuccess('تم حذف بيانات الاستلام');
        await loadBeneficiaries();
        Get.back();
      } catch (e) {
        Helpers.showError('فشل حذف البيانات');
      }
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
