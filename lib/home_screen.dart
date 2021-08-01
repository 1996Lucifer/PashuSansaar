import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as locate;
import 'package:pashusansaar/buy_animal/buy_animal.dart';
import 'package:pashusansaar/buy_animal/buy_animal_model.dart';
import 'package:pashusansaar/my_animals/myAnimalModel.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'buy_animal/buy_animal_controller.dart';
import 'my_animals/myAnimalController.dart';
import 'profile_main.dart';
import 'refresh_token/refresh_token_controller.dart';
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

  List<Result> _animalInfo = [];
  List<MyAnimals> _sellingAnimalInfo = [];
  Map _profileData = {};
  Map _referralWinnerData = {};
  PageController _pageController;
  String _referralUniqueValue = '', _mobileNumber = '', _userName = '';
  bool _checkReferral = false;
  double lat = 0.0, long = 0.0;
  locate.LocationData _locate;

  final BuyAnimalController buyAnimalController =
      Get.put(BuyAnimalController());
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());
  final MyAnimalListController myAnimalListController =
      Get.put(MyAnimalListController());

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.selectedIndex);
    // updateData();
    checkInitialData();
    super.initState();
  }

  checkInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getDouble('latitude') == null || prefs.getDouble('longitude') == null
        ? getLocationLocate()
        : loginSetup();
  }

  getLocationLocate() async {
    locate.Location location = locate.Location();

    bool _serviceEnabled;
    locate.PermissionStatus _permissionGranted;
    locate.LocationData _locationData;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == locate.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != locate.PermissionStatus.granted) {
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

    await loginSetup();
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

  loginSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('isLoggedIn', true);
      prefs.setBool('alreadyUser', true);
      _referralUniqueValue = prefs.getString('referralUniqueValue');
      _checkReferral = prefs.getBool('checkReferral') ?? false;
      _mobileNumber = prefs.getString('mobileNumber');
      _userName = prefs.getString('userName') ?? '';

      lat = prefs.getDouble('latitude');
      long = prefs.getDouble('longitude');
    });

    getInitialInfo();
  }

  getInitialInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool status;
    pr.show();

    try {
      if (ReusableWidgets.isTokenExpired(prefs.getInt('expires') ?? 0)) {
        status = await refreshTokenController.getRefreshToken(
            refresh: prefs.getString('refreshToken') ?? '');
        if (status) {
          setState(() {
            prefs.setString(
                'accessToken', refreshTokenController.accessToken.value);
            prefs.setString(
                'refreshToken', refreshTokenController.refreshToken.value);
            prefs.setInt('expires', refreshTokenController.expires.value);
          });
        } else {
          print('Error getting token==' + status.toString());
        }
      }
    } catch (e) {
      pr.hide();
      ReusableWidgets.loggerFunction(
          fileName: 'home_screen_refreshToken',
          error: e.toString(),
          myNum: _mobileNumber,
          userId: prefs.getString('userId'));
      ReusableWidgets.showDialogBox(
        context,
        'warning'.tr,
        Text(
          'global_error'.tr,
        ),
      );
    }

    try {
      BuyAnimalModel data = await buyAnimalController.getAnimal(
        distance: 50000,
        latitude: lat,
        longitude: long,
        animalType: null,
        minMilk: null,
        maxMilk: null,
        page: 1,
        accessToken: prefs.getString('accessToken') ?? '',
        userId: prefs.getString('userId'),
      );

      setState(() {
        _animalInfo = data.result;
        prefs.setInt('page', data.page);
      });
      pr.hide();
    } catch (e) {
      pr.hide();
      ReusableWidgets.loggerFunction(
          fileName: 'home_screen_getAnimal',
          error: e.toString(),
          myNum: _mobileNumber,
          userId: prefs.getString('userId'));
      ReusableWidgets.showDialogBox(
        context,
        'warning'.tr,
        Text(
          'global_error'.tr,
        ),
      );
    }

    getAnimalSellingInfo();
  }

  getAnimalSellingInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool status;

    try {
      if (ReusableWidgets.isTokenExpired(prefs.getInt('expires') ?? 0)) {
        status = await refreshTokenController.getRefreshToken(
            refresh: prefs.getString('refreshToken') ?? '');
        if (status) {
          setState(() {
            prefs.setString(
                'accessToken', refreshTokenController.accessToken.value);
            prefs.setString(
                'refreshToken', refreshTokenController.refreshToken.value);
            prefs.setInt('expires', refreshTokenController.expires.value);
          });
        } else {
          print('Error getting token==' + status.toString());
        }
      }
    } catch (e) {
      ReusableWidgets.loggerFunction(
          fileName: 'home_screen_refreshToken',
          error: e.toString(),
          myNum: _mobileNumber,
          userId: prefs.getString('userId'));
      ReusableWidgets.showDialogBox(
        context,
        'warning'.tr,
        Text(
          'global_error'.tr,
        ),
      );
    }

    try {
      MyAnimalModel dataSellingInfo =
          await myAnimalListController.getAnimalList(
        userId: prefs.getString('userId'),
        token: prefs.getString('accessToken'),
        page: 1,
      );

      setState(() {
        _sellingAnimalInfo = dataSellingInfo.myAnimals;
      });
    } catch (e) {
      ReusableWidgets.loggerFunction(
          fileName: 'home_screen_getAnimalList',
          error: e.toString(),
          myNum: _mobileNumber,
          userId: prefs.getString('userId'));
      ReusableWidgets.showDialogBox(
        context,
        'warning'.tr,
        Text(
          'global_error'.tr,
        ),
      );
    }
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
              child:
                  new Text('no'.tr, style: TextStyle(color: appPrimaryColor)),
            ),
            new TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  new Text('yes'.tr, style: TextStyle(color: appPrimaryColor)),
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
              userName: _userName,
              userMobileNumber: _mobileNumber,
              userImage: _profileData['image'],
              latitude: lat,
              longitude: long,
            ),
            SellAnimalMain(
              sellingAnimalInfo: _sellingAnimalInfo,
              userName: _userName,
              userMobileNumber: _mobileNumber,
            ),
            ProfileMain(
              profileData: _profileData,
              sellingAnimalInfo: _sellingAnimalInfo,
              userName: _userName,
              userMobileNumber: _mobileNumber,
              refData: _referralWinnerData,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon:
                  Image.asset('assets/images/buy3.png', height: 25, width: 25),
              label: 'buy'.tr,
            ),
            BottomNavigationBarItem(
              icon:
                  Image.asset('assets/images/Sell.png', height: 25, width: 25),
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
      ),
    );
  }
}
