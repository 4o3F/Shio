import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ShioGlobalStorage extends GetxController {
  static ShioGlobalStorage INSTANCE = ShioGlobalStorage();

  final API_BASE_URL = "https://koube.403f.cafe/api";
  final ENTRANCE_CODE_LENGTH = 10;

  final diskStorage = GetStorage();
  Rx<String> entranceCodeSalt = "".obs;
  Rx<String> apiKey = "".obs;
  RxSet<int> entranceIDsWaitingSync = <int>{}.obs;

  Rx<int> shioPage = 0.obs;

  void restorePersist() {
    entranceCodeSalt.value = diskStorage.read("entrance_code_salt") ?? "";
    apiKey.value = diskStorage.read("api_key") ?? "";
    entranceIDsWaitingSync = diskStorage.read("entrance_ids_waiting_sync") ?? <int>{}.obs;
  }

  void setApiKey(String apiKey) {
    this.apiKey.value = apiKey;
    diskStorage.write("api_key", apiKey);
  }

  void setEntranceCodeSalt(String entranceCodeSalt) {
    this.entranceCodeSalt.value = entranceCodeSalt;
    diskStorage.write("entrance_code_salt", entranceCodeSalt);
  }

  void addEntranceIDsWaitingSync(int id) {
    entranceIDsWaitingSync.add(id);
    diskStorage.write("entrance_ids_waiting_sync", entranceIDsWaitingSync);
  }

  void switchPage(int destination) {
    shioPage.value = destination;
    switch (destination) {
      case 0:
        Get.toNamed("/inbound");
      case 1:
        Get.toNamed("/config");
    }
  }
}
