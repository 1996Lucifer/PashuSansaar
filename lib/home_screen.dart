import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhenu/buy_animal/buy_animal.dart';
import 'package:dhenu/utils/reusable_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_main.dart';
import 'sell_animal/sell_animal_main.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  int selectedIndex;
  HomeScreen({Key key, @required this.selectedIndex}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProgressDialog pr;
  List _animalInfo = [], _sellingAnimalInfo = [];
  Map _profileData = {};

  @override
  void initState() {
    super.initState();
    loginSetup();
  }

  getInitialInfo() {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    pr.style(message: 'progress_dialog_message'.tr);
    pr.show();

    FirebaseFirestore.instance
        .collection("buyingAnimalList")
        // .orderBy('userAnimalPrice')
        .orderBy('userAnimalMilk', descending: false)
        .where('userAnimalMilk', isGreaterThan: '0')
        // .where('dateOfSaving',
        //     isLessThanOrEqualTo:
        //         ReusableWidgets.dateTimeToEpoch(DateTime.now()))
        .get(GetOptions(source: Source.serverAndCache))
        .then(
      (value) {
        List _info = [];
        value.docs.forEach((element) {
          _info.add(element.data());
        });

        setState(() {
          _animalInfo = _info;
        });
        // pr.hide();
      },
    );
    getAnimalSellingInfo();
  }

  getAnimalSellingInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    FirebaseFirestore.instance
        .collection("animalSellingInfo")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('sellingAnimalList')
        .get(GetOptions(source: Source.serverAndCache))
        .then(
      (value) {
        List _info = [];
        value.docs.forEach((element) {
          _info.add(element.data());
        });
        setState(() {
          _sellingAnimalInfo = _info;
          prefs.setString('animalDetails', jsonEncode(_info));
        });
        // pr.hide();
      },
    );
    getProfileInfo();
  }

  getProfileInfo() {
    FirebaseFirestore.instance
        .collection("userInfo")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get(GetOptions(source: Source.serverAndCache))
        .then(
      (value) {
        setState(() {
          _profileData = value.data();
        });
        pr.hide();
      },
    );
  }

  loginSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(
          'isLoggedIn', FirebaseAuth.instance.currentUser.uid.isNotEmpty);
      prefs.setBool(
          'alreadyUser', FirebaseAuth.instance.currentUser.uid.isNotEmpty);
    });

    getInitialInfo();
    // getAnimalSellingInfo();
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
    });
  }

  getScreenOnSelection() {
    switch (widget.selectedIndex) {
      case 0:
        return BuyAnimal(
            animalInfo: _animalInfo, userName: _profileData['name']);
        break;
      case 1:
        return SellAnimalMain(sellingAnimalInfo: _sellingAnimalInfo);
        break;
      case 2:
        return ProfileMain(profileData: _profileData);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
      body: getScreenOnSelection(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/buy3.png', height: 25, width: 25),
            label: 'buy'.tr,
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/Sell.png', height: 25, width: 25),
            label: 'sell'.tr,
          ),
          BottomNavigationBarItem(
            icon:
                Image.asset('assets/images/profile.jpg', height: 25, width: 25),
            label: 'profile'.tr,
          ),
        ],
        currentIndex: widget.selectedIndex,
        // selectedItemColor: themeColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
