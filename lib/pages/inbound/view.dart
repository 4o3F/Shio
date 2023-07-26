import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../../storage/storage.dart';
import 'logic.dart';

class InboundPage extends StatelessWidget {
  InboundPage({Key? key}) : super(key: key);

  final logic = Get.put(InboundLogic());

  void syncEntranceIDs(BuildContext context) {
    //print(logic.entranceIDsWaitingSync);
    http
        .post(
            Uri.parse(
                "${ShioGlobalStorage.INSTANCE.apiBaseURL.value}/audience/enter"),
            headers: <String, String>{
              'Authorization':
                  'Bearer ${ShioGlobalStorage.INSTANCE.apiKey.value}'
            },
            body: jsonEncode(<String, List>{
              'aids': ShioGlobalStorage.INSTANCE.entranceIDsWaitingSync.toList()
            }))
        .then((response) {
      if (response.statusCode == 200) {
        ShioGlobalStorage.INSTANCE.entranceIDsWaitingSync.clear();
        showTopSnackBar(
            Overlay.of(context), const CustomSnackBar.success(message: "同步成功"));
        //saveConfigs(context);
      } else {
        print(response.body);
        showTopSnackBar(Overlay.of(context),
            CustomSnackBar.error(message: "同步失败 错误码: ${response.statusCode}"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.delete<InboundLogic>();
    final logic = Get.put(InboundLogic());

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: MobileScanner(
                fit: BoxFit.contain,
                controller: logic.mobileScannerController,
                onDetect: (capture) {
                  String? scanResult = capture.barcodes[0].displayValue;
                  if (scanResult == null) {
                    showTopSnackBar(Overlay.of(context),
                        const CustomSnackBar.error(message: '扫码错误'));
                  } else {
                    var data = scanResult.split('@');
                    var audienceID = int.tryParse(data[0]);
                    if(audienceID == null) {
                      showTopSnackBar(Overlay.of(context),
                          const CustomSnackBar.error(message: "入场码非法"));
                    }
                    var audienceEntranceCode = data[1];
                    var realAudienceEntranceCode = sha256
                        .convert(utf8.encode(audienceID.toString() +
                            ShioGlobalStorage.INSTANCE.entranceCodeSalt.value))
                        .toString()
                        .substring(
                            0, ShioGlobalStorage.INSTANCE.entranceCodeLength.value);
                    if (audienceEntranceCode == realAudienceEntranceCode) {
                      ShioGlobalStorage.INSTANCE.addEntranceIDsWaitingSync(audienceID!);
                      showTopSnackBar(Overlay.of(context),
                          const CustomSnackBar.success(message: "入场成功"));
                    } else {
                      showTopSnackBar(Overlay.of(context),
                          const CustomSnackBar.error(message: "入场码验证失败"));
                    }
                  }
                }),
          ),
          Obx(
            () => RichText(
                text: TextSpan(children: [
              TextSpan(
                text:
                    "IDs waiting sync: ${ShioGlobalStorage.INSTANCE.entranceIDsWaitingSync.length}",
                style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
            ])),
          ),
          ElevatedButton.icon(
              onPressed: () => {syncEntranceIDs(context)},
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.lightBlueAccent),
              ),
              icon: const Icon(
                Icons.download_for_offline_outlined,
                color: Colors.white,
              ),
              label: const Text(
                "Sync Entered Audience IDs",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }
}
