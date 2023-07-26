import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shio/storage/storage.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'logic.dart';

class ConfigPage extends StatelessWidget {
  ConfigPage({Key? key}) : super(key: key);

  final logic = Get.put(ConfigLogic());

  void saveAPIBaseURL(BuildContext context) {
    ShioGlobalStorage.INSTANCE
        .setApiBaseURL(logic.apiBaseURLController.text);
    showTopSnackBar(
        Overlay.of(context), const CustomSnackBar.success(message: "保存成功"));
  }

  void saveAPIKey(BuildContext context) {
    ShioGlobalStorage.INSTANCE.setApiKey(logic.apiKeyController.text);
    showTopSnackBar(
        Overlay.of(context), const CustomSnackBar.success(message: "保存成功"));
  }

  void saveEntranceCodeConfig(BuildContext context) {
    ShioGlobalStorage.INSTANCE.setEntranceCodeSalt(logic.entranceCodeController.text);
    ShioGlobalStorage.INSTANCE.setEntranceCodeLength(int.parse(logic.entranceCodeLengthController.text));
    showTopSnackBar(
        Overlay.of(context), const CustomSnackBar.success(message: "保存成功"));
  }

  void fetchEntranceCodeSalt(BuildContext context) {
    http.get(
        Uri.parse(
            "${ShioGlobalStorage.INSTANCE.apiBaseURL.value}/common/getEntranceCodeConfig"),
        headers: <String, String>{
          'Authorization': 'Bearer ${ShioGlobalStorage.INSTANCE.apiKey.value}'
        }).then((response) {
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        logic.entranceCodeController.text = body['data']['salt'];
        logic.entranceCodeLengthController.text = body['data']['length'].toString();
        showTopSnackBar(
            Overlay.of(context), const CustomSnackBar.success(message: "获取成功"));
        //saveConfigs(context);
      } else {
        showTopSnackBar(Overlay.of(context),
            CustomSnackBar.error(message: "获取失败 错误码: ${response.statusCode}"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    logic.apiKeyController.text = ShioGlobalStorage.INSTANCE.apiKey.value;
    logic.entranceCodeController.text =
        ShioGlobalStorage.INSTANCE.entranceCodeSalt.value;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: logic.apiBaseURLController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(labelText: "API Base URL"),
          ),
          const Icon(Icons.arrow_downward_outlined),
          ElevatedButton.icon(
              onPressed: () => {saveAPIBaseURL(context)},
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.amberAccent),
              ),
              icon: const Icon(
                Icons.save_outlined,
                color: Colors.white,
              ),
              label: const Text(
                "Save API Base URL",
                style: TextStyle(color: Colors.white),
              )),
          TextField(
            controller: logic.apiKeyController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: "API Key"),
          ),
          const Icon(Icons.arrow_downward_outlined),
          ElevatedButton.icon(
              onPressed: () => {saveAPIKey(context)},
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.amberAccent),
              ),
              icon: const Icon(
                Icons.save_outlined,
                color: Colors.white,
              ),
              label: const Text(
                "Save API Key",
                style: TextStyle(color: Colors.white),
              )),
          const Icon(Icons.arrow_downward_outlined),
          TextField(
            controller: logic.entranceCodeController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Entrance Code Salt"),
          ),
          TextField(
            controller: logic.entranceCodeLengthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Entrance Code Length"),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                      onPressed: () => {fetchEntranceCodeSalt(context)},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.lightBlueAccent),
                      ),
                      icon: const Icon(
                        Icons.download_for_offline_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Fetch Entrance Code Config",
                        style: TextStyle(color: Colors.white),
                      )),
                  const Icon(Icons.arrow_downward_outlined),
                  ElevatedButton.icon(
                      onPressed: () => {saveEntranceCodeConfig(context)},
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.amberAccent),
                      ),
                      icon: const Icon(
                        Icons.save_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Save Entrance Code Configs",
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ))
        ],
      ),
    );
  }
}
