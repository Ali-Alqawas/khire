import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/villages/bindings/villages_binding.dart';
import '../modules/villages/views/villages_view.dart';
import '../modules/beneficiaries/bindings/beneficiaries_binding.dart';
import '../modules/beneficiaries/views/beneficiaries_view.dart';
import '../modules/distribution/bindings/distribution_binding.dart';
import '../modules/distribution/views/distribution_view.dart';
import '../modules/reports/bindings/reports_binding.dart';
import '../modules/reports/views/reports_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.villages,
      page: () => const VillagesView(),
      binding: VillagesBinding(),
    ),
    GetPage(
      name: AppRoutes.beneficiaries,
      page: () => const BeneficiariesView(),
      binding: BeneficiariesBinding(),
    ),
    GetPage(
      name: AppRoutes.distribution,
      page: () => const DistributionView(),
      binding: DistributionBinding(),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
  ];
}
