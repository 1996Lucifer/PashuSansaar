import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/login/login_screen.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'home_screen.dart';
import 'legacy_user/legacy_user_controller.dart';
import 'legacy_user/legacy_user_model.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  List<String> newVersion = [], currentVersion = [];
  final LegacyUserController _legacyUserController =
      Get.put(LegacyUserController());

  @override
  void initState() {
    super.initState();
    // _getInitialData();
    _checkLegacyUser();
  }

  _checkLegacyUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _userId = prefs.getString('userId') ?? '';
    String _accessToken = prefs.getString('accessToken') ?? '';

    if (_userId.isEmpty && _accessToken.isEmpty) {
      _getLegacyUser(prefs);
    } else {
      setState(() {
        isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        newVersion = prefs.getStringList('newVersion') ?? [];
        currentVersion = prefs.getStringList('currentVersion') ?? [];
        prefs.setInt('count', 0);
      });
    }
  }

  _getLegacyUser(prefs) async {
    LegacyUserModel legacyUserData = _legacyUserController.getLegacyUserData(
      number: FirebaseAuth.instance.currentUser.phoneNumber,
      legacyId: FirebaseAuth.instance.currentUser.uid,
    );
    setState(() {
      prefs.setString('accessToken', legacyUserData.accessToken);
      prefs.setString('refreshToken', legacyUserData.refreshToken);
      prefs.setInt('expires', legacyUserData.expires);
      prefs.setString('userId', legacyUserData.userId);
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      newVersion = prefs.getStringList('newVersion') ?? [];
      currentVersion = prefs.getStringList('currentVersion') ?? [];
      prefs.setInt('count', 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      home: isLoggedIn ? HomeScreen(selectedIndex: 0) : Login(),
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
