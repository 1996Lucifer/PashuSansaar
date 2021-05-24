import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:geodesy/geodesy.dart';
import 'package:intl/intl.dart';
import 'package:pashusansaar/buy_animal/buy_animal.dart';
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
// import 'dart:math' show cos, sqrt, asin;

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
  String _referralUniqueValue = '', _mobileNumber = '';
  // QueryDocumentSnapshot _lastAnimal;
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
          'userId': FirebaseAuth.instance.currentUser == null
              ? ''
              : FirebaseAuth.instance.currentUser.uid,
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
        'userId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser.uid,
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
    // updateData();
  }

  // updateData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   var addresses = await geoCoder.Geocoder.local.findAddressesFromCoordinates(
  //       geoCoder.Coordinates(25.5314475, 83.2280148));
  //   var first = addresses.first;

  //   print(first);

  // await FirebaseFirestore.instance
  //     .collection("buyingAnimalList1")
  //     .orderBy('dateOfSaving')
  //     .where('dateOfSaving', isLessThanOrEqualTo: '1621692916', isGreaterThanOrEqualTo: '1621555200')
  //     .get()
  //     .then((value) => value.docs.forEach((element) async {
  //           var addresses = await geoCoder.Geocoder.local
  //               .findAddressesFromCoordinates(geoCoder.Coordinates(
  //                   element['userLatitude'], element['userLongitude']));
  //           var first = addresses.first;
  //           // print((first.subAdminArea ?? first.locality));
  //           await FirebaseFirestore.instance
  //               .collection("buyingAnimalList1")
  //               .doc(element.reference.id)
  //               .update({
  //             'district': first.subAdminArea ?? first.locality,
  //             'zipCode': first.postalCode
  //           });
  //         }));

  // .where('uniqueId',
  //     isLessThanOrEqualTo: '10000000') // 00000000 - 10000000
  // .where('uniqueId',
  //     isGreaterThan: '10000000', isLessThanOrEqualTo: '20000000') // 30 - 31
  // .where('uniqueId',
  //     isGreaterThan: '20000000', isLessThanOrEqualTo: '30000000') // 30 - 31
  // .where('uniqueId',
  //     isGreaterThan: '30000000', isLessThanOrEqualTo: '40000000') // karna hai aaj
  // .where('uniqueId',
  //     isGreaterThan: '40000000', isLessThanOrEqualTo: '50000000') // karna hai aaj
  // .where('uniqueId',
  //     isGreaterThan: '50000000', isLessThanOrEqualTo: '60000000') // karna hai aaj
  // .where('uniqueId',
  //     isGreaterThan: '60000000', isLessThanOrEqualTo: '70000000') // karna hai aaj
  // .where('uniqueId',
  //     isGreaterThan: '70000000', isLessThanOrEqualTo: '80000000') // karna hai aaj
  // .where('uniqueId',
  //     isGreaterThan: '80000000', isLessThanOrEqualTo: '90000000') // karna hai aaj
  // .where('uniqueId', isGreaterThan: '90000000') // k

  // .get()
  // .then((value) => value.docs.forEach((element) async {}));
  // }

  getInitialInfo() async {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    pr.style(message: 'progress_dialog_message'.tr);
    pr.show();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      List district = [];
      RemoteConfig remoteConfig = await RemoteConfig.instance;
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      var address = await geoCoder.Geocoder.local.findAddressesFromCoordinates(
          geoCoder.Coordinates(
              prefs.getDouble('latitude'), prefs.getDouble('longitude')));
      var first = address.first;

      json
          .decode(remoteConfig.getValue("district_map").asString())
          .forEach((element) {
        district.addIf(element[first.subAdminArea ?? first.locality] != null,
            element[first.subAdminArea ?? first.locality]);
      });

      if (district.isEmpty) {
        Stream<List<DocumentSnapshot>> stream = geo
            .collection(
                collectionRef: FirebaseFirestore.instance
                    .collection("buyingAnimalList1")
                    .where('isValidUser', isEqualTo: 'Approved'))
            .within(
                center: geo.point(latitude: lat, longitude: long),
                radius: 50,
                field: 'position',
                strictMode: true);

        stream.listen((List<DocumentSnapshot> documentList) {
          pr.hide();
          // List _temp = [];
          // documentList.forEach((e) {
          //   // _temp.addIf(
          //   //     (e.reference.id.substring(8) !=
          //   //             FirebaseAuth.instance.currentUser.uid) &&
          //   //         (e['isValidUser'] == 'Approved'),
          //   //     e);
          //   _temp.addIf(e['isValidUser'] == 'Approved', e);
          //   print('=-=-=-' + e.reference.id);
          //   print('=-=-=-' + e.toString());
          // });
          setState(() {
            _animalInfo = documentList;
            // _animalInfo = _temp;
            _animalInfo
                .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
          });

          print("=-=-=" + documentList.length.toString());
        });
      } else {
        FirebaseFirestore.instance
            .collection('buyingAnimalList1')
            .orderBy('dateOfSaving', descending: true)
            .where('dateOfSaving',
                isLessThanOrEqualTo: ReusableWidgets.dateTimeToEpoch(now))
            .where('district', whereIn: district[0])
            .where('isValidUser', isEqualTo: 'Approved')
            .limit(25)
            .get(GetOptions(source: Source.serverAndCache))
            .then((value) {
          // List _temp = [];
          // value.docs.forEach((e) {
          // _temp.addIf(
          //     // e['isValidUser'] == 'Approved' &&
          //         double.parse((Geodesy().distanceBetweenTwoGeoPoints(
          //                         LatLng(lat, long),
          //                         LatLng(e['userLatitude'],
          //                             e['userLongitude'])) /
          //                     1000)
          //                 .toStringAsPrecision(2)) <=
          //             50.0,
          //     e);

          //   print('=-=-=-' + e.reference.id);
          //   print('=-=-=->' + e.toString());
          // });

          // print('=-=-=-<>' + value.docs.last['dateOfSaving'].toString());

          pr.hide();
          setState(() {
            lastDocument = value.docs.last['dateOfSaving'];
            districtList = district[0];
            _animalInfo = value.docs;
            // _animalInfo = _temp;
            _animalInfo
                .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
          });

          print("=-=-=" + value.docs.length.toString());
        });
      }
    } catch (e) {
      print('=-=Error-Home=->>>' + e.toString());
      pr.hide();

      FirebaseFirestore.instance
          .collection('logger')
          .doc(_mobileNumber)
          .collection('home-buying')
          .doc()
          .set({
        'issue': e.toString(),
        'userId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser.uid,
        'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
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
            _info.addIf(
                element.data()['isValidUser'] == 'Approved', element.data());
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
        'userId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser.uid,
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
        'userId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser.uid,
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
