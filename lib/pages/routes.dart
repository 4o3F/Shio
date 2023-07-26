import 'package:get/get.dart';
import 'package:shio/pages/inbound/view.dart';

import 'config/view.dart';

class ShioRoutes {
  static final List<GetPage> getPages = [
    GetPage(name: "/inbound", page: () => InboundPage()),
    GetPage(name: "/config", page: () => ConfigPage())
  ];
}