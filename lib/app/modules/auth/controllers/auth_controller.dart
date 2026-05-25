import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();

  final isLoading = false.obs;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  void _checkSession() {
    if (_authService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (!_validateInputs()) return;

    isLoading.value = true;
    try {
      final user = await _authService.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Helpers.showSuccess('مرحباً بك ${user.fullName} 👋');
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Helpers.showError('اسم المستخدم أو كلمة المرور غير صحيحة');
      }
    } catch (e) {
      Helpers.showError('حدث خطأ، يرجى المحاولة مجدداً');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  bool _validateInputs() {
    if (usernameController.text.trim().isEmpty) {
      Helpers.showWarning('يرجى إدخال اسم المستخدم');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      Helpers.showWarning('يرجى إدخال كلمة المرور');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
