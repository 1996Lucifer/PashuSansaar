import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pashusansaar/buy_animal/buy_animal.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final geo = Geoflutterfire();
  PageController _pageController;
  String _referralUniqueValue = '';
  bool _checkReferral = false;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.selectedIndex);
    // _notificationChannel();
    loginSetup();
    super.initState();
  }

  _notificationChannel() async {
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    var x = initialMessage?.data['type'];
    print('notification===>>' + x.toString());
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
        'dateOfSaving': ReusableWidgets.dateTimeToEpoch(DateTime.now()),
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
      });

      // setState(() {
      //   prefs.setBool('checkReferral', true);
      // });
    } catch (e) {
      print('e-referral--->' + e.toString());
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
    });

    getInitialInfo();
  }

  getInitialInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    pr.style(message: 'progress_dialog_message'.tr);
    pr.show();

    try {
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(
              collectionRef:
                  FirebaseFirestore.instance.collection("buyingAnimalList1"))
          .within(
              center: geo.point(
                  latitude: prefs.getDouble('latitude'),
                  longitude: prefs.getDouble('longitude')),
              radius: 50,
              field: 'position',
              strictMode: true);

      stream.listen((List<DocumentSnapshot> documentList) {
        List _temp = [];
        documentList.forEach((e) {
          _temp.addIf(
              (e.reference.id.substring(8) !=
                      FirebaseAuth.instance.currentUser.uid) &&
                  (e['isValidUser'] == 'Approved'),
              e);
          print('=-=-=-' + e.reference.id);
          print('=-=-=-' + e.toString());
        });
        setState(() {
          _animalInfo = _temp;
          _animalInfo
              .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
        });

        print("=-=-=" + documentList.length.toString());
        pr.hide();
      });
    } catch (e) {
      print('=-=Error-Home-=->>>' + e.toString());
      pr.hide();
    }

    getAnimalSellingInfo();
  }

  getAnimalSellingInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // FirebaseFirestore.instance.clearPersistence();
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
    getProfileInfo();
  }

  getProfileInfo() async {
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
    if (!_checkReferral) initReferrerDetails(_profileData['mobile']);
    // else
    //   pr.hide();
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
          userImage: _profileData['image'],
        );
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
            selectedItemColor: primaryColor,
            onTap: _onItemTapped,
          ),
        ));
  }
}
