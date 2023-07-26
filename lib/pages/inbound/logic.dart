import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class InboundLogic extends GetxController {
  MobileScannerController mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates);
  @override
  void onInit() {
    mobileScannerController.stop();
    mobileScannerController.start();
    super.onInit();
  }

  @override
  void dispose() {
    mobileScannerController.dispose();
    super.dispose();
  }
}
