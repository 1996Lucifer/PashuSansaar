import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
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
  Map _referralWinnerData = {};
  final geo = Geoflutterfire();
  PageController _pageController;
  String _referralUniqueValue = '', _mobileNumber = '';
  bool _checkReferral = false;
  double lat = 0.0, long = 0.0;
  LocationData _locate;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.selectedIndex);
    // updateData();
    checkInitialData();
    super.initState();
  }

//https://docs.google.com/spreadsheets/d/10M_tCvCNEjvsBPO3wg2hou9oF5lZikaH5C31kHXn4XU/edit#gid=0
//https://script.google.com/macros/s/AKfycbwzLm_QkArFGt2y-3Aa-RvSeZQY7hLVOpBXHrRjjU-QzQHRDpmUnCaUH5efwvrq1IXe/exec
// AKfycbwzLm_QkArFGt2y-3Aa-RvSeZQY7hLVOpBXHrRjjU-QzQHRDpmUnCaUH5efwvrq1IXe

  // updateData() async {
  //   var addresses =
  //       await geoCoder.Geocoder.local.findAddressesFromQuery("621719");
  //   var first = addresses.first;

  //   Map<String, dynamic> data = {
  //     "addressLine": first.addressLine,
  //     "adminArea": first.adminArea,
  //     "coordinates": first.coordinates.toString(),
  //     "countryCode": first.countryCode,
  //     "countryName": first.countryName,
  //     "featureName": first.featureName,
  //     "locality": first.locality,
  //     "postalCode": first.postalCode,
  //     "subAdminArea": first.subAdminArea,
  //     "subLocality": first.subLocality
  //   };

  //   print(data);

  // FirebaseFirestore.instance
  //     .collection('userInfo')
  //     .limit(500)
  //     .get()
  //     .then((value) {
  //   value.docs.forEach((element) async {
  //     if (element['latitude'] != "null" || element['longitude'] != "null") {
  //       var addresses = await geoCoder.Geocoder.local
  //           .findAddressesFromCoordinates(geoCoder.Coordinates(
  //               double.parse(element['latitude']),
  //               double.parse(element['longitude'])));
  //       var first = addresses.first;

  //       Map<String, dynamic> data = {
  //         "addressLine": first.addressLine,
  //         "adminArea": first.adminArea,
  //         "coordinates": first.coordinates.toString(),
  //         "countryCode": first.countryCode,
  //         "countryName": first.countryName,
  //         "featureName": first.featureName,
  //         "locality": first.locality,
  //         "postalCode": first.postalCode,
  //         "subAdminArea": first.subAdminArea,
  //         "subLocality": first.subLocality
  //       };

  //       await FirebaseFirestore.instance
  //           .collection('addressCollection')
  //           .doc(element.reference.id)
  //           .set(data);
  //     }
  //   });
  // });
  // }

  checkInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getDouble('latitude') == null || prefs.getDouble('longitude') == null
        ? getLocationLocate()
        : loginSetup();
  }

  getLocationLocate() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    pr.show();
    _locationData = await location.getLocation();

    setState(() {
      _locate = _locationData;
      prefs.setDouble("latitude", _locate.latitude);
      prefs.setDouble("longitude", _locate.longitude);
    });

    try {
      FirebaseFirestore.instance
          .collection('userInfo')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({
        'latitude': _locate.latitude,
        'longitude': _locate.longitude,
      }).then((value) async {
        pr.hide();
        await loginSetup();
      });
    } catch (e) {
      FirebaseFirestore.instance
          .collection('logger')
          .doc(_mobileNumber)
          .collection('home-location')
          .doc()
          .set({
        'issue': e.toString(),
        'userId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser.uid,
        'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
      pr.hide();
      await loginSetup();
    }

    // await loginSetup();
  }

  Future<void> initReferrerDetails(mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var address = await geoCoder.Geocoder.local.findAddressesFromCoordinates(
        geoCoder.Coordinates(
            prefs.getDouble('latitude'), prefs.getDouble('longitude')));
    var first = address.first;
    try {
      Map<String, dynamic> referralInfo = {
        'userAddress': first.addressLine ??
            (first.adminArea +
                ' ' +
                first.postalCode +
                ', ' +
                first.countryName),
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

  _getDistrictList() async {
    pr.show();

    SharedPreferences prefs = await SharedPreferences.getInstance();

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

    setState(() {
      districtList = district.isEmpty ? [] : district[0];
    });

    getInitialInfo();
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

    _getDistrictList();
    // dataUpdation();
  }

  // dataUpdation() async {
  //   await FirebaseFirestore.instance.collection("userInfo").get().then(
  //     (value) {
  //       value.docs.forEach((element) {
  //         FirebaseFirestore.instance
  //             .collection("userInfo")
  //             .doc(element.reference.id)
  //             .update({
  //               'dateOfCreation': FirebaseAuth.instance.
  //             });
  //       });
  //     },
  //   );
  // }

  getInitialInfo() async {
    try {
      final now = DateTime.now();

      if (districtList.isEmpty) {
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
          // List _temp = [];
          // documentList.forEach((e) {
          //   _temp.addIf(e['isValidUser'] == 'Approved', e);
          // });
          setState(() {
            _animalInfo = documentList;
            _animalInfo
                .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
          });
          pr.hide();
          // if (pr.isShowing()) pr.hide();
        });
      } else {
        FirebaseFirestore.instance
            .collection('buyingAnimalList1')
            .orderBy('dateOfSaving', descending: true)
            .where('dateOfSaving',
                isLessThanOrEqualTo: ReusableWidgets.dateTimeToEpoch(now))
            .where('district', whereIn: districtList)
            .where('isValidUser', isEqualTo: 'Approved')
            .limit(25)
            .get(GetOptions(source: Source.serverAndCache))
            .asStream()
            .listen((value) {
          setState(() {
            lastDocument = value.docs.last['dateOfSaving'];
            _animalInfo = value.docs;
            _animalInfo
                .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
          });
          pr.hide();
          // if (pr.isShowing()) pr.hide();
        });
      }
    } catch (e) {
      print('=-=Error-Home=->>>' + e.toString());
      // if (pr.isShowing()) pr.hide();

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

    print('=-=-==-=' + pr.isShowing().toString());

    // if (pr.isShowing()) pr.hide();

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

    getReferralWinnerInfo();
  }

  getReferralWinnerInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection("referralWinner")
          .limit(1)
          .orderBy('dateOfSaving', descending: true)
          .get(GetOptions(source: Source.serverAndCache))
          .then(
        (value) {
          setState(() {
            _referralWinnerData = value.docs[0].data();
          });
        },
      );
    } catch (e) {
      FirebaseFirestore.instance
          .collection('logger')
          .doc(_mobileNumber)
          .collection('home-profile-main')
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

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOutCirc);
    });
  }

  Future<bool> _onWillPop() {
    if (widget.selectedIndex == 0) {
      return showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('एप बंद करे ?'),
          content: new Text('क्या आप एप बंद करना चाहते हैं'),
          actions: <Widget>[
            new TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('no'.tr, style: TextStyle(color: primaryColor)),
            ),
            new TextButton(
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
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    pr.style(message: 'progress_dialog_message'.tr);
    // if (pr.isShowing()) pr.hide();

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
                    latitude: lat,
                    longitude: long),
                SellAnimalMain(
                    sellingAnimalInfo: _sellingAnimalInfo,
                    userName: _profileData['name'],
                    userMobileNumber: _profileData['mobile']),
                ProfileMain(
                  profileData: _profileData,
                  sellingAnimalInfo: _sellingAnimalInfo,
                  userName: _profileData['name'],
                  userMobileNumber: _profileData['mobile'],
                  refData: _referralWinnerData,
                ),
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
            selectedItemColor: primaryColor,
            onTap: _onItemTapped,
          ),
        ));
  }
}
