import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../controllers/distribution_controller.dart';

class DistributionView extends GetView<DistributionController> {
  const DistributionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.currentBeneficiary.value != null) {
        final ben = controller.currentBeneficiary.value;
        return Scaffold(
          appBar: AppBar(
            title: Text(ben?['beneficiary_name'] ?? ''),
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded),
              onPressed: () {
                controller.currentBeneficiary.value = null;
              },
            ),
          ),
          body: _buildDistributionContent(),
        );
      }
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.distribution)),
        body: _buildBeneficiaryListScreen(),
      );
    });
  }

  Widget _buildBeneficiaryListScreen() {
    return Column(
      children: [
        _buildVillageYearSelector(),
        _buildSearchBar(),
        Expanded(child: _buildList()),
      ],
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

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredBeneficiaries.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textSecondary),
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
            final status = item['overall_status']?.toString() ?? 'PENDING';
            final statusColor = Helpers.statusColor(status);
            final statusText = Helpers.statusArabic(status);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  child: Icon(Icons.person_rounded, color: statusColor),
                ),
                title: Text(
                  item['beneficiary_name'] ?? '',
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
                ),
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
                onTap: () => controller.selectBeneficiary(item['beneficiary_id'] as int),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildDistributionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBanner(),
          const SizedBox(height: 20),
          _buildDatesSection(),
          const SizedBox(height: 16),
          _buildWheatSection(),
          const SizedBox(height: 16),
          _buildMeatSection(),
          const SizedBox(height: 16),
          _buildBasketSection(),
          const SizedBox(height: 16),
          _buildNotesSection(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: controller.overallStatusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: controller.overallStatusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: controller.overallStatusColor),
          const SizedBox(width: 12),
          Text(
            controller.overallStatusText,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: controller.overallStatusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required RxInt count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 14)),
        Row(
          children: [
            IconButton.filled(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.pending,
                foregroundColor: Colors.white,
                minimumSize: const Size(36, 36),
              ),
            ),
            SizedBox(
              width: 50,
              child: Center(
                child: Obx(() => Text(
                  '${count.value}',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )),
              ),
            ),
            IconButton.filled(
              onPressed: onIncrement,
              icon: const Icon(Icons.add, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(36, 36),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReceivedToggle({
    required String label,
    required RxBool isReceived,
    required VoidCallback onToggle,
  }) {
    return Obx(() => InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isReceived.value
              ? AppColors.received.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isReceived.value ? AppColors.received : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isReceived.value ? AppColors.received : AppColors.textSecondary,
              ),
            ),
            Icon(
              isReceived.value
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isReceived.value ? AppColors.received : AppColors.pending,
              size: 24,
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildDatesSection() {
    return _buildSectionCard(AppStrings.dates, Icons.date_range_rounded, AppColors.primary, [
      _buildCounterRow(
        label: AppStrings.boxes,
        count: controller.datesBoxes,
        onIncrement: controller.incrementDatesBoxes,
        onDecrement: controller.decrementDatesBoxes,
      ),
      const SizedBox(height: 12),
      _buildCounterRow(
        label: AppStrings.pieces,
        count: controller.datesPieces,
        onIncrement: controller.incrementDatesPieces,
        onDecrement: controller.decrementDatesPieces,
      ),
      const SizedBox(height: 12),
      _buildReceivedToggle(
        label: 'استلام التمر',
        isReceived: controller.datesReceived,
        onToggle: controller.toggleDatesReceived,
      ),
    ]);
  }

  Widget _buildWheatSection() {
    return _buildSectionCard(AppStrings.wheat, Icons.grass_rounded, AppColors.primary, [
      _buildCounterRow(
        label: AppStrings.bags,
        count: controller.wheatBags,
        onIncrement: controller.incrementWheatBags,
        onDecrement: controller.decrementWheatBags,
      ),
      const SizedBox(height: 12),
      _buildCounterRow(
        label: AppStrings.pieces,
        count: controller.wheatPieces,
        onIncrement: controller.incrementWheatPieces,
        onDecrement: controller.decrementWheatPieces,
      ),
      const SizedBox(height: 12),
      _buildReceivedToggle(
        label: 'استلام البر',
        isReceived: controller.wheatReceived,
        onToggle: controller.toggleWheatReceived,
      ),
    ]);
  }

  Widget _buildMeatSection() {
    return _buildSectionCard(AppStrings.meat, Icons.restaurant_rounded, AppColors.primary, [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppStrings.kg, style: GoogleFonts.cairo(fontSize: 14)),
          Row(
            children: [
              IconButton.filled(
                onPressed: controller.decrementMeat,
                icon: const Icon(Icons.remove, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.pending,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(36, 36),
                ),
              ),
              SizedBox(
                width: 70,
                child: Center(
                  child: Obx(() => Text(
                    '${controller.meatKg.value.toStringAsFixed(1)} كجم',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )),
                ),
              ),
              IconButton.filled(
                onPressed: controller.incrementMeat,
                icon: const Icon(Icons.add, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      _buildReceivedToggle(
        label: 'استلام اللحوم',
        isReceived: controller.meatReceived,
        onToggle: controller.toggleMeatReceived,
      ),
    ]);
  }

  Widget _buildBasketSection() {
    return _buildSectionCard(AppStrings.basket, Icons.shopping_basket_rounded, AppColors.primary, [
      _buildCounterRow(
        label: 'عدد السلال',
        count: controller.basketCount,
        onIncrement: controller.incrementBasket,
        onDecrement: controller.decrementBasket,
      ),
      const SizedBox(height: 12),
      _buildReceivedToggle(
        label: 'استلام السلال',
        isReceived: controller.basketReceived,
        onToggle: controller.toggleBasketReceived,
      ),
    ]);
  }

  Widget _buildNotesSection() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppStrings.notes,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.notesController,
              decoration: const InputDecoration(
                hintText: 'أدخل ملاحظات...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() => Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: controller.isSaving.value ? null : controller.saveDistribution,
            icon: controller.isSaving.value
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(controller.isSaving.value ? 'جاري الحفظ...' : AppStrings.save),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: controller.deleteDistribution,
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text('حذف بيانات الاستلام'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    ));
  }
}
