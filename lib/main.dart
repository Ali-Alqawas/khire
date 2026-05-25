import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'services/initial_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitialServices.init();
  runApp(const KhireApp());
}

class KhireApp extends StatelessWidget {
  const KhireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'نظام إدارة توزيع المساعدات الخيرية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      defaultTransition: Transition.leftToRightWithFade,
      translations: Messages(),
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),
      textDirection: TextDirection.rtl,
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar_SA': {
      'hello': 'مرحباً',
      'loading': 'جاري التحميل...',
    },
  };
}
