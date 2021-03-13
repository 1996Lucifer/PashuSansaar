import 'package:dhenu/splash_screen.dart';
import 'package:dhenu/translation/message.dart';
import 'package:dhenu/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
        title: 'Dhenu',
        debugShowCheckedModeBanner: false,
        translations: Messages(), // your translations
        locale: Locale('hn', 'IN'),
        // fallbackLocale: Locale('hn', 'IN'),
        theme: ThemeData(
            fontFamily: 'Mukta',
            primaryColor: primaryColor,
            // colorScheme: ColorScheme(
            //     primary: primaryColor,
            //     // primaryVariant: primaryVariant,
            //     secondary: secondaryColor,
            //     // secondaryVariant: secondaryVariant,
            //     surface: surface,
            //     // background: background,
            //     // error: error,
            //     // onPrimary: onPrimary,
            //     onSecondary: secondaryColor,
            //     onSurface: primaryColor,
            //     // onBackground: onBackground,
            //     // onError: onError,
            //     brightness: Brightness.light
            //     ),
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
