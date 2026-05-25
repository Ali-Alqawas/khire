import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../app/data/services/auth_service.dart';

class InitialServices {
  static Future<void> init() async {
    await GetStorage.init();
    await Get.putAsync<AuthService>(() async {
      final auth = AuthService();
      return await auth.init();
    });
  }
}
