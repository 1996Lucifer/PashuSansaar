import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pashusansaar/splash_screen.dart';
import 'package:pashusansaar/translation/message.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'life_cycle_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseFirestore.instance.clearPersistence();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return LifeCycleManager(
        child: GetMaterialApp(
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
            home: SplashScreen()));
  }
}
