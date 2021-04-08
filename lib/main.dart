import 'package:flutter/scheduler.dart';
import 'package:pashusansaar/splash_screen.dart';
import 'package:pashusansaar/translation/message.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:url_launcher/url_launcher.dart' as URLauncher;
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final playStoreUrl =
      'https://play.google.com/store/apps/details?id=dj.pashusansaar';
  double newVersion, currentVersion;

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
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    currentVersion = double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      if (newVersion > currentVersion) {
        await _showVersionDialog(
            remoteConfig.getString('force_update_current_version'),
            info.version);
      }
    } catch (exception) {
      print(exception);
    }
  }

  _showVersionDialog(newVer, currentVer) async {
    await Future.delayed(Duration(milliseconds: 50));
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "नया अपडेट";
        String message =
            "एप का नया वर्शन ${newVer.toString()} उपलब्ध है| आपका एप वर्शन ${currentVer.toString()} है| कृपया एप अपडेट करे |";
        String btnLabel = "अपडेट करे";
        // String btnLabelCancel = "Later";
        return new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(
                btnLabel,
                style: TextStyle(color: primaryColor),
              ),
              onPressed: () async => await URLauncher.launch(playStoreUrl),
            ),
          ],
        );
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
        home: SplashScreen());
  }
}
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);

//     return GetMaterialApp(
//         onInit: () {
//           try {
//             versionCheck(context);
//           } catch (e) {
//             print(e);
//           }
//         },
//         title: 'PashuSansaar',
//         debugShowCheckedModeBanner: false,
//         translations: Messages(), // your translations
//         locale: Locale('hn', 'IN'),
//         // fallbackLocale: Locale('hn', 'IN'),
//         theme: ThemeData(
//             fontFamily: 'Mukta',
//             primaryColor: primaryColor,
//             buttonColor: primaryColor,
//             iconTheme: IconThemeData(color: primaryColor),
//             accentColor: primaryColor,
//             textSelectionTheme:
//                 TextSelectionThemeData(cursorColor: primaryColor),
//             indicatorColor: primaryColor,
//             scaffoldBackgroundColor: Colors.white),
//         home: SplashScreen());
//   }
// }
