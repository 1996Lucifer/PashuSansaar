import 'dart:convert';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pashusansaar/animal_description/animal_description_page.dart';
import 'package:pashusansaar/splash_screen.dart';
import 'package:pashusansaar/translation/message.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as URLauncher;
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'utils/reusable_widgets.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.max,
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  print('payLoad==>>' + message.toString());

  print('payLoad-notification==>>' + message.notification.toString());
  print('payLoad-data==>>' + message.data.toString());

  print('Handling a background message ${message.messageId}');
  // _goToDeeplyNestedView(message.data);
}

RemoteConfig remoteConfig;

Future _goToDeeplyNestedView(data) async {
  if (data != null && data['screen'] == 'DESCRIPTION_PAGE') {
    await Get.to(
      () => AnimalDescription(
        userId: data['userId'],
        uniqueId: data['uniqueId'],
      ),
    );
    // await navigatorKey.currentState.push(
    //   MaterialPageRoute(
    //     builder: (_) => AnimalDescription(
    //       userId: data['userId'],
    //       uniqueId: data['uniqueId'],
    //     ),
    //   ),
    // );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final playStoreUrl =
      'https://play.google.com/store/apps/details?id=dj.pashusansaar';
  List<String> newVersion, currentVersion;

  getMessageOpen() async =>
      await FirebaseMessaging.instance.getInitialMessage();

  Map<String, dynamic> dataPayload = {};

  @override
  void initState() {
    super.initState();

    getMessageOpen();

    var initialiseAndroidSettings =
        AndroidInitializationSettings('ic_notification');

    var initialisingSettings =
        InitializationSettings(android: initialiseAndroidSettings);

    flutterLocalNotificationsPlugin.initialize(initialisingSettings,
        onSelectNotification: (value) => _goToDeeplyNestedView(dataPayload));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('payLoad==12>>' + message.toString());
      RemoteNotification notification = message.notification;
      print('payLoad-notification==12>>' + notification.toString());
      print('payLoad-data==12>>' + message.data.toString());
      setState(() {
        dataPayload = message.data;
      });
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                priority: Priority.max,
                importance: Importance.max,
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) => _goToDeeplyNestedView(message.data));

    versionCheck(context);
  }

  initDynamicLink() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      final dynamicData = json.decode(deepLink?.queryParameters['data']);
      print("link1===>" + dynamicData.toString());

      if (deepLink != null && dynamicData != {} && dynamicData != null)
        // navigatorKey.currentState.push(
        //   MaterialPageRoute(
        //     builder: (_) => AnimalDescription(
        //       userId: dynamicData['userId'],
        //       uniqueId: dynamicData['uniqueId'],
        //     ),
        //   ),
        // );
        Get.to(
          () => AnimalDescription(
            userId: dynamicData['userId'],
            uniqueId: dynamicData['uniqueId'],
          ),
        );
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    final dynamicData = json.decode(deepLink?.queryParameters['data']);

    print("link2===>" + dynamicData.toString());

    if (deepLink != null && dynamicData != {} && dynamicData != null) {
      Get.to(
        () => AnimalDescription(
          userId: dynamicData['userId'],
          uniqueId: dynamicData['uniqueId'],
        ),
      );
      // navigatorKey.currentState.push(
      //   MaterialPageRoute(
      //     builder: (_) => AnimalDescription(
      //       userId: dynamicData['userId'],
      //       uniqueId: dynamicData['uniqueId'],
      //     ),
      //   ),
      // );
    }
  }

  double versionToDouble(_list) {
    return (((int.parse(_list[0])) * 100) +
        (int.parse(_list[1])) +
        ((int.parse(_list[2])) * 0.1));
  }

  versionCheck(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String _unique = ReusableWidgets.randomIDGenerator();

    // if (!_checkReferral) await initReferrerDetails(_unique);
    final PackageInfo info = await PackageInfo.fromPlatform();

    try {
      remoteConfig = await RemoteConfig.instance;
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();

      List<String> currentVersion = info.version.split('.');
      if (int.parse(currentVersion[0]) == 1 ||
          (prefs.getString('accessToken') ?? '').isEmpty) {
        await prefs.clear();
      }
      String minimumVersion = remoteConfig.getString('minimum_version');
      String nudgeVersion = remoteConfig.getString('nudge_version');

      if (minimumVersion.isNotEmpty && nudgeVersion.isNotEmpty) {
        double currentVersionDouble = versionToDouble(currentVersion);
        double minimumVersionDouble =
            versionToDouble(minimumVersion.split('.'));
        double nudgeVersionDouble = versionToDouble(nudgeVersion.split('.'));

        setState(() {
          prefs.setStringList('currentVersion', currentVersion);
          prefs.setStringList('minimumVersion', minimumVersion.split('.'));
          prefs.setStringList('nudgeVersion', nudgeVersion.split('.'));
          prefs.setString('referralUniqueValue', _unique);
        });

        if (currentVersionDouble < minimumVersionDouble) {
          await _showVersionDialog(
              minimumVersion.split('.'), currentVersion, true);
        } else if (currentVersionDouble < nudgeVersionDouble) {
          await _showVersionDialog(
              nudgeVersion.split('.'), currentVersion, false);
        }
      }
    } catch (e) {
      print(e);
      ReusableWidgets.loggerFunction(
        fileName: 'version_check',
        error: e.toString(),
        myNum: '',
        userId: prefs.getString('userId') ?? '',
      );
    }

    await initDynamicLink();
  }

  _showVersionDialog(
      List<String> newVer, List<String> currentVer, bool forceUpdate) async {
    await Future.delayed(Duration(milliseconds: 50));
    return showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (BuildContext context) {
        String title = "नया अपडेट";
        String message =
            "एप का नया वर्शन ${newVer.join('.')} उपलब्ध है| आपका एप वर्शन ${currentVer.join('.')} है| कृपया एप अपडेट करे |";
        String btnLabel = "अपडेट करे";
        String btnLabelCancel = "बाद में";
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              if (!forceUpdate) ...[
                RaisedButton(
                  color: appPrimaryColor,
                  child: Text(
                    btnLabelCancel,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              RaisedButton(
                color: appPrimaryColor,
                child: Text(
                  btnLabel,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async => await URLauncher.launch(playStoreUrl),
              ),
            ],
          ),
        );
      },
    );
  }

  bool logInBasedOnVersion;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
      title: 'PashuSansaar',
      debugShowCheckedModeBanner: false,
      translations: Messages(), // translations
      locale: Locale('hn', 'IN'),
      theme: ThemeData(
        fontFamily: 'Mukta',
        primaryColor: appPrimaryColor,
        buttonColor: appPrimaryColor,
        iconTheme: IconThemeData(color: appPrimaryColor),
        accentColor: appPrimaryColor,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: appPrimaryColor,
          selectionHandleColor: appPrimaryColor,
        ),
        indicatorColor: appPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: appPrimaryColor,
            ),
          ),
          // labelStyle: TextStyle(color: appPrimaryColor),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
