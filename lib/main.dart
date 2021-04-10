import 'package:flutter/scheduler.dart';
import 'package:pashusansaar/splash_screen.dart';
import 'package:pashusansaar/translation/message.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart' as URLauncher;
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
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

  @override
  void initState() {
    super.initState();
    try {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => versionCheck(context));

      // versionCheck(context);
    } catch (e) {
      print(e);
    }
  }

  versionCheck(context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      List<String> currentVersion1 = info.version.split('.');
      List<String> newVersion1 =
          remoteConfig.getString('force_update_current_version').split('.');

      setState(() {
        newVersion = newVersion1;
        currentVersion = currentVersion1;
      });
      if ((newVersion1[0].compareTo(currentVersion1[0]) == 1) ||
          (newVersion1[1].compareTo(currentVersion1[1]) == 1)) {
        await _showVersionDialog(newVersion1, currentVersion1, true);
      }
      if (newVersion1[2].compareTo(currentVersion1[2]) == 1)
        await _showVersionDialog(newVersion1, currentVersion1, false);
    } catch (exception) {
      print(exception);
    }
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
                forceUpdate
                    ? SizedBox.shrink()
                    : RaisedButton(
                        color: primaryColor,
                        child: Text(
                          btnLabelCancel,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                RaisedButton(
                  color: primaryColor,
                  child: Text(
                    btnLabel,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async => await URLauncher.launch(playStoreUrl),
                ),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
        title: 'PashuSansaar',
        debugShowCheckedModeBanner: false,
        translations: Messages(), // your translations
        locale: Locale('hn', 'IN'),
        // fallbackLocale: Locale('hn', 'IN'),
        theme: ThemeData(
            fontFamily: 'Mukta',
            primaryColor: primaryColor,
            buttonColor: primaryColor,
            iconTheme: IconThemeData(color: primaryColor),
            accentColor: primaryColor,
            textSelectionTheme:
                TextSelectionThemeData(cursorColor: primaryColor),
            indicatorColor: primaryColor,
            scaffoldBackgroundColor: Colors.white),
        home: SplashScreen(
            newVersion: newVersion, currentVersion: currentVersion));
  }
}
