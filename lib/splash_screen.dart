import 'package:pashusansaar/login_screen.dart';
import 'package:pashusansaar/user_details_fetch_screen.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import 'buy_animal/buy_animal.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    getLoginCheck();
  }

  getLoginCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    print('isLoggedIn===' + isLoggedIn.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      // home: UserDetailsFetch(currentUser: 'G6daWncSiobuilTshX9RUVjjv8f2', mobile: '+919997098955'),
      // home: isLoggedIn ? HomeScreen(selectedIndex: 0) : Login(),
      home: BuyAnimal(
        animalInfo: [],
        userName: '',
        userMobileNumber: '',
        userImage: '',
      ),
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
      backgroundColor: primaryColor,
    );
  }
}
