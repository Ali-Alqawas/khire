import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/village_model.dart';
import '../../../data/models/year_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await Get.find<AuthService>().logout();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadVillages();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVillageSelector(),
                const SizedBox(height: 16),
                _buildYearSelector(),
                const SizedBox(height: 20),
                _buildStatsCards(),
                const SizedBox(height: 20),
                _buildQuickActions(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.handshake_rounded, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  controller.currentUserName,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppStrings.appTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: Text(AppStrings.dashboard),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.location_city_rounded),
            title: Text(AppStrings.villages),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.villages);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_rounded),
            title: Text(AppStrings.beneficiaries),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.beneficiaries);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_rounded),
            title: Text(AppStrings.distribution),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.distribution);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: Text(AppStrings.reports),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(AppRoutes.reports);
            },
          ),
          if (controller.isAdmin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_rounded),
              title: Text(AppStrings.adminPanel),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVillageSelector() {
    return Obx(() {
      if (controller.villages.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.location_city_rounded, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(
                AppStrings.noVillages,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.villages),
                icon: const Icon(Icons.add),
                label: Text(AppStrings.addVillage),
              ),
            ],
          ),
        );
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.villages,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<VillageModel>(
                value: controller.selectedVillage.value,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_city_rounded),
                ),
                items: controller.villages
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.selectVillage(v);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildYearSelector() {
    return Obx(() {
      if (controller.selectedVillage.value == null) return const SizedBox();
      if (controller.years.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            AppStrings.noYears,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.yearName,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<YearModel>(
                value: controller.selectedYear.value,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                items: controller.years
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.yearName),
                        ))
                    .toList(),
                onChanged: (y) {
                  if (y != null) controller.selectYear(y);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatsCards() {
    return Obx(() {
      if (controller.selectedYear.value == null) return const SizedBox();
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard(
                AppStrings.totalBeneficiaries,
                controller.totalBeneficiaries.value.toString(),
                AppColors.primary,
                Icons.people_rounded,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                AppStrings.receivedCount,
                controller.receivedCount.value.toString(),
                AppColors.received,
                Icons.check_circle_rounded,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(
                AppStrings.partialCount,
                controller.partialCount.value.toString(),
                AppColors.partial,
                Icons.remove_circle_outline_rounded,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                AppStrings.pendingCount,
                controller.pendingCount.value.toString(),
                AppColors.pending,
                Icons.pending_rounded,
              )),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressCard(),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
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

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.overallStatus,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${controller.completionPercentage}%',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (controller.totalBeneficiaries.value > 0)
                    ? (controller.receivedCount.value +
                            controller.partialCount.value) /
                        controller.totalBeneficiaries.value
                    : 0,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation(AppColors.received),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                AppStrings.beneficiaries,
                Icons.people_rounded,
                AppColors.primary,
                () => Get.toNamed(AppRoutes.beneficiaries),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                AppStrings.distribution,
                Icons.assignment_rounded,
                AppColors.received,
                () => Get.toNamed(AppRoutes.distribution),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                AppStrings.reports,
                Icons.bar_chart_rounded,
                AppColors.partial,
                () => Get.toNamed(AppRoutes.reports),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                AppStrings.villages,
                Icons.location_city_rounded,
                AppColors.primary,
                () => Get.toNamed(AppRoutes.villages),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
