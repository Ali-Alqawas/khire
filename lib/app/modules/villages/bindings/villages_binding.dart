import 'package:get/get.dart';
import '../controllers/villages_controller.dart';

class VillagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VillagesController>(() => VillagesController());
  }
}
