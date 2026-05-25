import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.reports),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: controller.exportToPdf,
            tooltip: AppStrings.exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            onPressed: controller.exportToCsv,
            tooltip: AppStrings.exportCsv,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVillageYearSelector(),
              const SizedBox(height: 20),
              if (controller.selectedYear.value != null) ...[
                _buildSummaryCards(),
                const SizedBox(height: 20),
                _buildPieChart(),
                const SizedBox(height: 20),
                _buildDistributionDetails(),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVillageYearSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(() => DropdownButtonFormField<VillageModel>(
              value: controller.selectedVillage.value,
              decoration: const InputDecoration(
                labelText: AppStrings.villages,
                prefixIcon: Icon(Icons.location_city_rounded),
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
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<YearModel>(
              value: controller.selectedYear.value,
              decoration: const InputDecoration(
                labelText: AppStrings.yearName,
                prefixIcon: Icon(Icons.calendar_today_rounded),
              ),
              items: controller.years
                  .map((y) => DropdownMenuItem(value: y, child: Text(y.yearName)))
                  .toList(),
              onChanged: (y) {
                if (y != null) {
                  controller.selectedYear.value = y;
                  controller.loadReport();
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoCard(
              AppStrings.totalBeneficiaries,
              '${controller.totalBeneficiaries.value}',
              AppColors.primary,
              Icons.people_rounded,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard(
              AppStrings.receivedCount,
              '${controller.receivedCount.value}',
              AppColors.received,
              Icons.check_circle_rounded,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInfoCard(
              AppStrings.partialCount,
              '${controller.partialCount.value}',
              AppColors.partial,
              Icons.remove_circle_outline_rounded,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildInfoCard(
              AppStrings.pendingCount,
              '${controller.pendingCount.value}',
              AppColors.pending,
              Icons.pending_rounded,
            )),
          ],
        ),
        const SizedBox(height: 20),
        _buildQuantitiesCard(),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, Color color, IconData icon) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitiesCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.statistics,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuantityRow(AppStrings.dates,
              '${controller.totalDatesBoxes.value} كرتون / ${controller.totalDatesPieces.value} حبة',
              Icons.date_range_rounded),
            const Divider(height: 24),
            _buildQuantityRow(AppStrings.wheat,
              '${controller.totalWheatBags.value} كيس / ${controller.totalWheatPieces.value} قطمة',
              Icons.grass_rounded),
            const Divider(height: 24),
            _buildQuantityRow(AppStrings.meat,
              '${controller.totalMeatKg.value.toStringAsFixed(1)} كجم',
              Icons.restaurant_rounded),
            const Divider(height: 24),
            _buildQuantityRow(AppStrings.basket,
              '${controller.totalBaskets.value} سلة',
              Icons.shopping_basket_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
      ],
    );
  }

  Widget _buildPieChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نسبة الاستلام',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    if (controller.receivedCount.value > 0)
                      PieChartSectionData(
                        value: controller.receivedCount.value.toDouble(),
                        color: AppColors.received,
                        title: '${((controller.receivedCount.value / (controller.totalBeneficiaries.value == 0 ? 1 : controller.totalBeneficiaries.value)) * 100).toStringAsFixed(1)}%',
                        radius: 35,
                        titleStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (controller.partialCount.value > 0)
                      PieChartSectionData(
                        value: controller.partialCount.value.toDouble(),
                        color: AppColors.partial,
                        title: '${((controller.partialCount.value / (controller.totalBeneficiaries.value == 0 ? 1 : controller.totalBeneficiaries.value)) * 100).toStringAsFixed(1)}%',
                        radius: 35,
                        titleStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (controller.pendingCount.value > 0)
                      PieChartSectionData(
                        value: controller.pendingCount.value.toDouble(),
                        color: AppColors.pending,
                        title: '${((controller.pendingCount.value / (controller.totalBeneficiaries.value == 0 ? 1 : controller.totalBeneficiaries.value)) * 100).toStringAsFixed(1)}%',
                        radius: 35,
                        titleStyle: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(AppColors.received, 'مستلم'),
                const SizedBox(width: 16),
                _buildLegend(AppColors.partial, 'جزئي'),
                const SizedBox(width: 16),
                _buildLegend(AppColors.pending, 'لم يستلم'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.cairo(fontSize: 12)),
      ],
    );
  }

  Widget _buildDistributionDetails() {
    return Obx(() {
      if (controller.distributionData.isEmpty) {
        return Center(
          child: Text(
            AppStrings.noData,
            style: GoogleFonts.cairo(fontSize: 16, color: AppColors.textSecondary),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل التوزيع',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.distributionData.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Helpers.statusColor(
                  item['overall_status']?.toString() ?? 'PENDING',
                ).withValues(alpha: 0.2),
                child: Icon(
                  Icons.person_rounded,
                  color: Helpers.statusColor(
                    item['overall_status']?.toString() ?? 'PENDING',
                  ),
                ),
              ),
              title: Text(
                item['beneficiary_name'] ?? '',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'تمر: ${item['dates_boxes']}/${item['dates_pieces']} | بر: ${item['wheat_bags']}/${item['wheat_pieces']} | لحوم: ${item['meat_kg']} | سلال: ${item['basket_count']}',
                style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Helpers.statusColor(
                    item['overall_status']?.toString() ?? 'PENDING',
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  Helpers.statusArabic(item['overall_status']?.toString() ?? 'PENDING'),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Helpers.statusColor(
                      item['overall_status']?.toString() ?? 'PENDING',
                    ),
                  ),
                ),
              ),
            ),
          )),
        ],
      );
    });
  }
}
