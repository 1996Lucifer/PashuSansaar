import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var dataSnapshotValue;
AppLifecycleState appLifecycleState;
Map<String, dynamic> callingInfo = {};
int count = 0;

String uniqueValue = '';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String token;
String lastDocument = '';
List districtList = [];
