import 'package:pashusansaar/login/login_screen.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  List<String> newVersion = [], currentVersion = [];

  @override
  void initState() {
    super.initState();
    getLoginCheck();
  }

  getLoginCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      newVersion = prefs.getStringList('newVersion') ?? [];
      currentVersion = prefs.getStringList('currentVersion') ?? [];
      prefs.setInt('count', 0);
    });
    print('isLoggedIn===' + isLoggedIn.toString());
    print('newVersion===' + newVersion.toString());
    print('currentVersion===' + currentVersion.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      home: isLoggedIn &&
              ([0, 1].contains(newVersion[0].compareTo(currentVersion[0]))) &&
              ([0, 1].contains(newVersion[1].compareTo(currentVersion[1])))
          ? HomeScreen(selectedIndex: 0)
          : Login(),
      duration: 2000,
      imageSize: 200,
      imageSrc: "assets/images/cow.png",
      text: "PashuSansar            पशुसंसार",
      textType: TextType.ScaleAnimatedText,
      textStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 50.0,
      ),
      backgroundColor: appPrimaryColor,
    );
  }
}
