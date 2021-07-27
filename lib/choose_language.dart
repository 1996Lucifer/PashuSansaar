import 'package:flutter/material.dart';
import 'package:pashusansaar/login/login_screen.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class ChooseLanguage extends StatefulWidget {
  @override
  _ChooseLanguageState createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {

  langFn(String lan, String loc) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('languageCode', lan);
      prefs.setString('languageCountryCode', loc);
      prefs.setBool('isLanguageSelected', true);
    });
    main();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 100.0),
          child: Column(
            children: [
              Text(
                'Choose Your Language: ',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: appPrimaryColor,
                  minimumSize: Size(100.0, 42.0),
                ),
                onPressed: () => langFn('en', 'US'),
                child: Text(
                  'English',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 10.0,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: appPrimaryColor,
                  minimumSize: Size(100.0, 42.0),
                ),
                onPressed: () => langFn('hn', 'IN'),
                child: Text(
                  'हिंदी',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
