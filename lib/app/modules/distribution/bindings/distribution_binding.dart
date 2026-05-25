import 'package:get/get.dart';
import '../controllers/distribution_controller.dart';

class DistributionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DistributionController>(() => DistributionController());
  }
}
