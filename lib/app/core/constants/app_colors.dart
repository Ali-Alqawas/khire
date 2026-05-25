import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF0D3B0F);
  static const Color received = Color(0xFF4CAF50);
  static const Color partial = Color(0xFFFF9800);
  static const Color pending = Color(0xFF9E9E9E);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color cardShadow = Color(0x1A000000);

  static Color statusColor(String status) {
    switch (status) {
      case 'RECEIVED':
        return received;
      case 'PARTIAL':
        return partial;
      default:
        return pending;
    }
  }
}
