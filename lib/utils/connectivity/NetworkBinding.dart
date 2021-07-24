import 'package:get/get.dart';
import 'package:pashusansaar/utils/connectivity/connectivity.dart';

class NetworkBinding extends Bindings {
  // dependence injection attach our class.
  @override
  void dependencies() {
    Get.lazyPut<GetXNetworkManager>(() => GetXNetworkManager());
  }
}
