import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/beneficiaries_controller.dart';

class BeneficiariesView extends GetView<BeneficiariesController> {
  const BeneficiariesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.beneficiaries),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: controller.importFromFile,
            tooltip: AppStrings.importCsv,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildVillageYearSelector(),
          _buildFilters(),
          _buildSearchBar(),
          Expanded(child: _buildBeneficiariesList()),
        ],
      ),
    );
  }

  Widget _buildVillageYearSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButtonFormField<VillageModel>(
              value: controller.selectedVillage.value,
              decoration: const InputDecoration(
                labelText: AppStrings.villages,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: controller.villages
                  .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  controller.selectedVillage.value = v;
                  controller.loadYears();
                }
              },
            )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() => DropdownButtonFormField<YearModel>(
              value: controller.selectedYear.value,
              decoration: const InputDecoration(
                labelText: AppStrings.yearName,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: controller.years
                  .map((y) => DropdownMenuItem(value: y, child: Text(y.yearName)))
                  .toList(),
              onChanged: (y) {
                if (y != null) {
                  controller.selectedYear.value = y;
                  controller.loadBeneficiaries();
                }
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['ALL', 'PENDING', 'PARTIAL', 'RECEIVED'];
    final labels = ['الكل', 'لم يستلم', 'استلام جزئي', 'تم الاستلام'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            return Obx(() {
              final isSelected = controller.statusFilter.value == filters[index];
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: Text(labels[index]),
                  selected: isSelected,
                  onSelected: (_) => controller.filterByStatus(filters[index]),
                  selectedColor: AppColors.statusColor(filters[index]).withValues(alpha: 0.2),
                  checkmarkColor: AppColors.statusColor(filters[index]),
                ),
              );
            });
          }),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: AppStrings.search,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.search('');
                  },
                )
              : const SizedBox()),
        ),
        onChanged: controller.search,
      ),
    );
  }

  Widget _buildBeneficiariesList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredBeneficiaries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                AppStrings.noBeneficiaries,
                style: GoogleFonts.cairo(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadBeneficiaries,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.filteredBeneficiaries.length,
          itemBuilder: (context, index) {
            final item = controller.filteredBeneficiaries[index];
            return _buildBeneficiaryCard(item);
          },
        ),
      );
    });
  }

  Widget _buildBeneficiaryCard(Map<String, dynamic> item) {
    final status = item['overall_status']?.toString() ?? 'PENDING';
    final statusColor = controller.getStatusColor(status);
    final statusText = controller.getStatusArabic(status);
    final name = item['beneficiary_name'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(Icons.person_rounded, color: statusColor),
        ),
        title: Text(name, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.cairo(fontSize: 11, color: statusColor),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: () => Get.toNamed(
          AppRoutes.distribution,
          arguments: {'beneficiary_id': item['beneficiary_id']},
        ),
        onLongPress: () => controller.deleteBeneficiary(item['beneficiary_id'] as int),
      ),
    );
  }

  void _showAddOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person_add_rounded, color: Colors.white),
              ),
              title: Text('إضافة مستفيد واحد', style: GoogleFonts.cairo()),
              onTap: () {
                Get.back();
                _showAddSingleDialog();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.partial,
                child: Icon(Icons.content_paste_rounded, color: Colors.white),
              ),
              title: Text('إضافة متعددة (نسخ/لصق)', style: GoogleFonts.cairo()),
              onTap: () {
                Get.back();
                _showAddMultipleDialog();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.file_upload_rounded, color: Colors.white),
              ),
              title: Text('استيراد من ملف', style: GoogleFonts.cairo()),
              onTap: () {
                Get.back();
                controller.importFromFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSingleDialog() {
    controller.nameController.clear();
    controller.notesController.clear();
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.addBeneficiary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: AppStrings.beneficiaryName,
                hintText: 'أدخل اسم المستفيد',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.notesController,
              decoration: const InputDecoration(
                labelText: AppStrings.notes,
                hintText: 'ملاحظات (اختياري)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(AppStrings.cancel)),
          ElevatedButton(onPressed: controller.addBeneficiary, child: Text(AppStrings.add)),
        ],
      ),
    );
  }

  void _showAddMultipleDialog() {
    controller.bulkNamesController.clear();
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.addMultiple),
        content: TextField(
          controller: controller.bulkNamesController,
          decoration: const InputDecoration(
            hintText: 'أدخل الأسماء سطراً بعد سطر\nاسم المستفيد الأول\nاسم المستفيد الثاني',
          ),
          maxLines: 8,
          textInputAction: TextInputAction.newline,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: controller.addMultipleBeneficiaries,
            child: Text(AppStrings.add),
          ),
        ],
      ),
    );
  }
}
