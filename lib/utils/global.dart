import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'connectivity/connectivity.dart';

AppLifecycleState appLifecycleState;
Map<String, dynamic> callingInfo = {};
int count = 0;

String uniqueValue = '';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String token;
String lastDocument = '';
List districtList = [];
final GetXNetworkManager networkManager = Get.find<GetXNetworkManager>();
