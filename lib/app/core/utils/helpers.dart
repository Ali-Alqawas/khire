import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class Helpers {
  static void showSuccess(String message) {
    Get.snackbar(
      'نجاح',
      message,
      backgroundColor: AppColors.received,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      backgroundColor: AppColors.partial,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String message) {
    Get.snackbar(
      'معلومات',
      message,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static Future<bool> confirmDelete({
    String title = 'تأكيد الحذف',
    String message = 'هل أنت متأكد من الحذف؟',
  }) async {
    final result = await Get.defaultDialog<bool>(
      title: title,
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      middleText: message,
      textConfirm: 'نعم، حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      cancelTextColor: AppColors.textSecondary,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    return result ?? false;
  }

  static String statusArabic(String status) {
    switch (status) {
      case AppConstants.statusReceived:
        return AppConstants.receivedArabic;
      case AppConstants.statusPartial:
        return AppConstants.partialArabic;
      default:
        return AppConstants.pendingArabic;
    }
  }

  static Color statusColor(String status) {
    return AppColors.statusColor(status);
  }

  static String formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
