import 'package:get/get.dart';
import '../controllers/beneficiaries_controller.dart';

class BeneficiariesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BeneficiariesController>(() => BeneficiariesController());
  }
}
