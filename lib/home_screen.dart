import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geodesy/geodesy.dart';
import 'package:intl/intl.dart';
import 'package:pashusansaar/buy_animal/buy_animal.dart';
import 'package:pashusansaar/main.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pashusansaar/utils/global.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_main.dart';
import 'sell_animal/sell_animal_main.dart';
import 'package:get/get.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geocoder/geocoder.dart' as geoCoder;
import 'dart:math' show cos, sqrt, asin;

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
  final geo = Geoflutterfire();
  PageController _pageController;
  String _referralUniqueValue = '', _mobileNumber = '', _lastAnimal = '';
  bool _checkReferral = false;
  double lat = 0.0, long = 0.0;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.selectedIndex);
    // checkForUpdate();
    loginSetup();
    super.initState();
  }

  Future<void> initReferrerDetails(mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var address = await geoCoder.Geocoder.local.findAddressesFromCoordinates(
        geoCoder.Coordinates(
            prefs.getDouble('latitude'), prefs.getDouble('longitude')));
    var first = address.first;
    try {
      Map<String, dynamic> referralInfo = {
        'userAddress':
            first.addressLine ?? (first.adminArea + ', ' + first.countryName),
        'dateOfUpdation': ReusableWidgets.dateTimeToEpoch(DateTime.now()),
        'userId': FirebaseAuth.instance.currentUser.uid,
        'userMobile': mobile
      };

      await FirebaseFirestore.instance
          .collection('referralData')
          .doc(_referralUniqueValue)
          .update(referralInfo)
          .then((value) => setState(() {
                prefs.setBool('checkReferral', true);
              }))
          .catchError((error) {
        print('e-referral--123->' + error.toString());
        FirebaseFirestore.instance
            .collection('logger')
            .doc(_mobileNumber)
            .collection('home-referralInner')
            .doc()
            .set({
          'issue': error.toString(),
          'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
          'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
        });
      });
    } catch (e) {
      print('e-referral--->' + e.toString());
      FirebaseFirestore.instance
          .collection('logger')
          .doc(_mobileNumber)
          .collection('home-referralOuter')
          .doc()
          .set({
        'issue': e.toString(),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
    }
  }

  loginSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool(
          'isLoggedIn', FirebaseAuth.instance.currentUser.uid.isNotEmpty);
      prefs.setBool(
          'alreadyUser', FirebaseAuth.instance.currentUser.uid.isNotEmpty);
      _referralUniqueValue = prefs.getString('referralUniqueValue');
      _checkReferral = prefs.getBool('checkReferral') ?? false;
      _mobileNumber = prefs.getString('mobileNumber');

      lat = prefs.getDouble('latitude');
      long = prefs.getDouble('longitude');
    });

    getInitialInfo();
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getInitialInfo() async {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    pr.style(message: 'progress_dialog_message'.tr);
    pr.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final now = DateTime.now();

      FirebaseFirestore.instance
          .collection('buyingAnimalList1')
          .where('dateOfSaving',
              isLessThanOrEqualTo: ReusableWidgets.dateTimeToEpoch(now))
          .orderBy('dateOfSaving', descending: true)
          .limit(20)
          .get()
          .then((value) {
        List _temp = [];
        value.docs.forEach((e) {
          _temp.addIf(
              e['isValidUser'] == 'Approved' &&
                  double.parse((Geodesy().distanceBetweenTwoGeoPoints(
                                  LatLng(lat, long),
                                  LatLng(
                                      e['userLatitude'], e['userLongitude'])) /
                              1000)
                          .toStringAsPrecision(2)) <=
                      50.0,
              e);

          print('=-=-=-' + e.reference.id);
          print('=-=-=->' + e.toString());
        });

        print('=-=-=-<>' + value.docs.last['dateOfSaving'].toString());

        setState(() {
          prefs.setString('lastAnimal', value.docs.last['dateOfSaving']);
          // _lastAnimal = value.docs.last['dateOfSaving'];
          _animalInfo = _temp;
          _animalInfo
              .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
        });

        pr.hide();
        print("=-=-=" + value.docs.length.toString());
      });
    } catch (e) {
      print('=-=Error-Home=->>>' + e.toString());
      FirebaseFirestore.instance
          .collection('logger')
          .doc(_mobileNumber)
          .collection('home-buying')
          .doc()
          .set({
        'issue': e.toString(),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
      pr.hide();
    }

    getAnimalSellingInfo();
  }

  getAnimalSellingInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      await FirebaseFirestore.instance
          .collection("animalSellingInfo")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('sellingAnimalList')
          .orderBy('dateOfSaving', descending: true)
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
        },
      );
    } catch (e) {
      FirebaseFirestore.instance
          .collection('logger')
          .doc(_mobileNumber)
          .collection('home')
          .doc('home-selling')
          .set({
        'issue': e.toString(),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
    }

    getProfileInfo();
  }

  getProfileInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection("userInfo")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get(GetOptions(source: Source.serverAndCache))
          .then(
        (value) {
          setState(() {
            _profileData = value.data();
          });
        },
      );
    } catch (e) {
      FirebaseFirestore.instance
          .collection('logger')
          .doc(_mobileNumber)
          .collection('home-profile')
          .doc()
          .set({
        'issue': e.toString(),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
    }
    if (!_checkReferral) initReferrerDetails(_profileData['mobile']);
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOutCirc);
    });
  }

  getScreenOnSelection() {
    switch (widget.selectedIndex) {
      case 0:
        return BuyAnimal(
            animalInfo: _animalInfo,
            userName: _profileData['name'],
            userMobileNumber: _profileData['mobile'],
            userImage: _profileData['image']);
        break;
      case 1:
        return SellAnimalMain(
            sellingAnimalInfo: _sellingAnimalInfo,
            userName: _profileData['name'],
            userMobileNumber: _profileData['mobile']);
        break;
      case 2:
        return ProfileMain(
            profileData: _profileData,
            sellingAnimalInfo: _sellingAnimalInfo,
            userName: _profileData['name'],
            userMobileNumber: _profileData['mobile']);
        break;
      default:
    }
  }

  Future<bool> _onWillPop() {
    if (widget.selectedIndex == 0) {
      return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('एप बंद करे ?'),
          content: new Text('क्या आप एप बंद करना चाहते हैं'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('no'.tr, style: TextStyle(color: primaryColor)),
            ),
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: new Text('yes'.tr, style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _pageController.animateToPage(0,
            duration: Duration(milliseconds: 500), curve: Curves.easeInOutCirc);
        widget.selectedIndex = 0;
      });
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                BuyAnimal(
                  animalInfo: _animalInfo,
                  userName: _profileData['name'],
                  userMobileNumber: _profileData['mobile'],
                  userImage: _profileData['image'],
                ),
                SellAnimalMain(
                    sellingAnimalInfo: _sellingAnimalInfo,
                    userName: _profileData['name'],
                    userMobileNumber: _profileData['mobile']),
                ProfileMain(
                    profileData: _profileData,
                    sellingAnimalInfo: _sellingAnimalInfo,
                    userName: _profileData['name'],
                    userMobileNumber: _profileData['mobile']),
              ]),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/buy3.png',
                    height: 25, width: 25),
                label: 'buy'.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/Sell.png',
                    height: 25, width: 25),
                label: 'sell'.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/profile.jpg',
                    height: 25, width: 25),
                label: 'profile'.tr,
              ),
            ],
            currentIndex: widget.selectedIndex,
            // selectedItemColor: themeColor,
            onTap: _onItemTapped,
          ),
        ));
  }
}
