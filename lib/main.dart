import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shio/pages/routes.dart';
import 'package:shio/storage/storage.dart';

void main() async {
  await GetStorage.init();
  runApp(const Shio());
}

class Shio extends StatelessWidget {
  const Shio({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        useMaterial3: true,
      ),
      home: const ShioMain(title: "Shio"),
    );
  }
}

class ShioMain extends StatelessWidget {
  const ShioMain({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    ShioGlobalStorage.INSTANCE.restorePersist();
    final globalState = Get.put(ShioGlobalStorage.INSTANCE);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shio"),
      ),
      body: GetMaterialApp(
        title: 'Shio',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
          useMaterial3: true,
        ),
        initialRoute: "/inbound",
        getPages: ShioRoutes.getPages,
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: ShioGlobalStorage.INSTANCE.shioPage.value,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.input_outlined), label: "入场"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "设置")
        ],
        onTap: ShioGlobalStorage.INSTANCE.switchPage,
      )),
    );
  }
}
