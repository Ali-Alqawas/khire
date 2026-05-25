import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/villages_controller.dart';

class VillagesView extends GetView<VillagesController> {
  const VillagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.villages)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVillageDialog(),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.villages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_city_rounded, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  AppStrings.noVillages,
                  style: GoogleFonts.cairo(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddVillageDialog(),
                  icon: const Icon(Icons.add),
                  label: Text(AppStrings.addVillage),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.villages.length,
          itemBuilder: (context, index) {
            final village = controller.villages[index];
            return _buildVillageCard(village);
          },
        );
      }),
    );
  }

  Widget _buildVillageCard(village) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.location_city_rounded, color: AppColors.primary),
        title: Text(
          village.name,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: village.description.isNotEmpty
            ? Text(
                village.description,
                style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _showEditVillageDialog(village),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              onPressed: () => controller.deleteVillage(village),
            ),
          ],
        ),
        onExpansionChanged: (expanded) {
          if (expanded) controller.selectVillage(village);
        },
        children: [
          _buildYearSection(),
        ],
      ),
    );
  }

  Widget _buildYearSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.yearName,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddYearDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: Text(AppStrings.addYear),
              ),
            ],
          ),
          Obx(() {
            if (controller.years.isEmpty) {
              return Text(
                AppStrings.noYears,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              );
            }
            return Column(
              children: controller.years.map((year) {
                return ListTile(
                  dense: true,
                  leading: Icon(
                    year.isArchivedBool ? Icons.archive_rounded : Icons.calendar_today_rounded,
                    color: year.isArchivedBool ? AppColors.pending : AppColors.primary,
                    size: 20,
                  ),
                  title: Text(
                    year.yearName,
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!year.isArchivedBool)
                        IconButton(
                          icon: const Icon(Icons.archive_outlined, size: 18),
                          onPressed: () => controller.archiveYear(year),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        onPressed: () => controller.deleteYear(year),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  void _showAddVillageDialog() {
    controller.villageNameController.clear();
    controller.villageDescController.clear();
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.addVillage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.villageNameController,
              decoration: const InputDecoration(
                labelText: AppStrings.villageName,
                hintText: 'أدخل اسم القرية',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.villageDescController,
              decoration: const InputDecoration(
                labelText: AppStrings.villageDescription,
                hintText: 'وصف القرية (اختياري)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: controller.addVillage,
            child: Text(AppStrings.add),
          ),
        ],
      ),
    );
  }

  void _showEditVillageDialog(village) {
    controller.villageNameController.text = village.name;
    controller.villageDescController.text = village.description;
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.editVillage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.villageNameController,
              decoration: const InputDecoration(
                labelText: AppStrings.villageName,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.villageDescController,
              decoration: const InputDecoration(
                labelText: AppStrings.villageDescription,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateVillage(village.copyWith(
                name: controller.villageNameController.text.trim(),
                description: controller.villageDescController.text.trim(),
              ));
              Get.back();
            },
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showAddYearDialog() {
    controller.yearNameController.clear();
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.addYear),
        content: TextField(
          controller: controller.yearNameController,
          decoration: const InputDecoration(
            labelText: AppStrings.yearName,
            hintText: 'مثال: 1446',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: controller.addYear,
            child: Text(AppStrings.add),
          ),
        ],
      ),
    );
  }
}
