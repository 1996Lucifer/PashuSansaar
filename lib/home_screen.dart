import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pashusansaar/buy_animal/buy_animal.dart';
import 'package:pashusansaar/utils/global.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/push_notification_model.dart';
import 'profile_main.dart';
import 'sell_animal/sell_animal_main.dart';
import 'package:get/get.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

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

// registerNotification(){
//   PushNotification _notificationInfo;
//     // ...

//     // For handling the received notifications
//     FirebaseMessaging.instance.configure(
//       onMessage: (message) async {
//         print('onMessage received: $message');

//         // Parse the message received
//         PushNotification notification = PushNotification.fromJson(message);

//         setState(() {
//           _notificationInfo = notification;
//           _totalNotifications++;
//         });
//       },
//     );
// }

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.selectedIndex);

    loginSetup();
    super.initState();
  }

  getInitialInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // FirebaseFirestore.instance
    //     .collection("buyingAnimalList")
    //     .orderBy("dateOfSaving", descending: true)
    //     .get(GetOptions(source: Source.serverAndCache))
    //     .then(
    //   (value) {
    //     List _info = [];

    //     value.docs.forEach((element) {
    //       _info.add(element.data());
    //     });
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    pr.style(message: 'progress_dialog_message'.tr);
    pr.show();

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(
            collectionRef:
                FirebaseFirestore.instance.collection("buyingAnimalList"))
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
        _temp.addIf(e.reference.id != FirebaseAuth.instance.currentUser.uid, e);
        print('=-=-=-' + e.reference.id);
        print('=-=-=-' + e.toString());
      });
      setState(() {
        dataSnapshotValue = documentList[documentList.length - 1];
        _animalInfo = _temp;
      });

      print("=-=-=" + documentList.length.toString());
    });

    getAnimalSellingInfo();
  }

  // String _getDistance(lat1, long1, lat2, long2) {
  //   return (Geodesy().distanceBetweenTwoGeoPoints(
  //             LatLng(lat1, long1),
  //             LatLng(lat2, long2),
  //           ) /
  //           1000)
  //       .toStringAsFixed(0);
  // }

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
    // pr = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false);

    // pr.style(message: 'progress_dialog_message'.tr);
    // pr.show();

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
      _pageController.jumpToPage(index);
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
        return ProfileMain(profileData: _profileData);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
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
            ProfileMain(profileData: _profileData),
          ]
          // getScreenOnSelection(),
          ),
      // IndexedStack(
      //   children: [
      //     BuyAnimal(
      //       animalInfo: _animalInfo,
      //       userName: _profileData['name'],
      //       userMobileNumber: _profileData['mobile'],
      //       userImage: _profileData['image'],
      //     ),
      //     SellAnimalMain(
      //         sellingAnimalInfo: _sellingAnimalInfo,
      //         userName: _profileData['name'],
      //         userMobileNumber: _profileData['mobile']),
      //     ProfileMain(profileData: _profileData),
      //   ],
      //   index: widget.selectedIndex,
      // ),
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
