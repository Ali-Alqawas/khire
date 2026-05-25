import 'package:get/get.dart';
import '../../../data/models/beneficiary_model.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../../../data/providers/database_helper.dart';
import '../../../data/services/auth_service.dart';

class DashboardController extends GetxController {
  final AuthService _authService = Get.find();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final isLoading = false.obs;
  final villages = <VillageModel>[].obs;
  final selectedVillage = Rx<VillageModel?>(null);
  final years = <YearModel>[].obs;
  final selectedYear = Rx<YearModel?>(null);
  final beneficiaries = <BeneficiaryModel>[].obs;

  final totalBeneficiaries = 0.obs;
  final receivedCount = 0.obs;
  final partialCount = 0.obs;
  final pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadVillages();
  }

  String get currentUserName => _authService.currentUser?.fullName ?? '';
  bool get isAdmin => _authService.isAdmin;

  Future<void> loadVillages() async {
    isLoading.value = true;
    try {
      villages.value = await _dbHelper.getActiveVillages();
      if (villages.isNotEmpty && selectedVillage.value == null) {
        selectVillage(villages.first);
      }
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectVillage(VillageModel village) async {
    selectedVillage.value = village;
    await loadYears();
  }

  Future<void> loadYears() async {
    if (selectedVillage.value == null) return;
    isLoading.value = true;
    try {
      years.value = await _dbHelper.getActiveYearsByVillage(
        selectedVillage.value!.id!,
      );
      if (years.isNotEmpty) {
        selectYear(years.first);
      } else {
        selectedYear.value = null;
        beneficiaries.clear();
        _resetStats();
      }
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectYear(YearModel year) async {
    selectedYear.value = year;
    await loadBeneficiaries();
    await loadStats();
  }

  Future<void> loadBeneficiaries() async {
    if (selectedYear.value == null) return;
    try {
      beneficiaries.value = await _dbHelper.getBeneficiariesByYear(
        selectedYear.value!.id!,
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadStats() async {
    if (selectedYear.value == null) return;
    try {
      final stats = await _dbHelper.getYearStats(selectedYear.value!.id!);
      totalBeneficiaries.value = (stats['total'] as int?) ?? 0;
      receivedCount.value = (stats['received'] as int?) ?? 0;
      partialCount.value = (stats['partial'] as int?) ?? 0;
      pendingCount.value = (stats['pending'] as int?) ?? 0;
    } catch (e) {
      _resetStats();
    }
  }

  void _resetStats() {
    totalBeneficiaries.value = 0;
    receivedCount.value = 0;
    partialCount.value = 0;
    pendingCount.value = 0;
  }

  String get completionPercentage {
    if (totalBeneficiaries.value == 0) return '0';
    final completed = receivedCount.value + partialCount.value;
    return ((completed / totalBeneficiaries.value) * 100).toStringAsFixed(1);
  }
}
