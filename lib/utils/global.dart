import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'reusable_widgets.dart';

var dataSnapshotValue;
AppLifecycleState appLifecycleState;
Map<String, dynamic> callingInfo = {};
int count = 0;

String uniqueValue = '';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String token;
DocumentSnapshot lastDocument;
