import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pashusansaar/sell_animal/sell_animal_form.dart';
import 'package:pashusansaar/sell_animal/sell_animal_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

// class SellAnimalMain extends StatefulWidget {
//   final List sellingAnimalInfo;
//   final String userName;
//   final String userMobileNumber;

//   SellAnimalMain(
//       {Key key,
//       @required this.sellingAnimalInfo,
//       @required this.userName,
//       @required this.userMobileNumber})
//       : super(key: key);

//   @override
//   _SellAnimalMainState createState() => _SellAnimalMainState();
// }

// class _SellAnimalMainState extends State<SellAnimalMain> {
//   ProgressDialog pr;
//   SharedPreferences prefs;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.sellingAnimalInfo.length == 0
//         ? SellAnimalForm(
//             userName: widget.userName,
//             userMobileNumber: widget.userMobileNumber)
//         : SellingAnimalInfo(
//             animalInfo: widget.sellingAnimalInfo,
//             userName: widget.userName,
//             userMobileNumber: widget.userMobileNumber);
//   }
// }

class SellAnimalMain extends StatelessWidget {
  final List sellingAnimalInfo;
  final String userName;
  final String userMobileNumber;

  SellAnimalMain(
      {Key key,
      @required this.sellingAnimalInfo,
      @required this.userName,
      @required this.userMobileNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sellingAnimalInfo.length == 0
        ? SellAnimalForm(
            key: key, userName: userName, userMobileNumber: userMobileNumber)
        : SellingAnimalInfo(
            key: key,
            animalInfo: sellingAnimalInfo,
            userName: userName,
            userMobileNumber: userMobileNumber,
            showExtraData: true);
  }
}
