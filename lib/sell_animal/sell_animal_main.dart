import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhenu/sell_animal/sell_animal_form.dart';
import 'package:dhenu/sell_animal/sell_animal_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class SellAnimalMain extends StatefulWidget {
  final List sellingAnimalInfo;
  final String userName;
  SellAnimalMain(
      {Key key, @required this.sellingAnimalInfo, @required this.userName})
      : super(key: key);

  @override
  _SellAnimalMainState createState() => _SellAnimalMainState();
}

class _SellAnimalMainState extends State<SellAnimalMain> {
  // List _animalInfo = [];
  // int lengthOfInfo = 0;
  ProgressDialog pr;
  SharedPreferences prefs;

  @override
  void initState() {
    // getInitialInfo();
    super.initState();
  }

  // getInitialInfo() async {
  //   // await Firebase.initializeApp();
  //   prefs = await SharedPreferences.getInstance();
  //   pr = new ProgressDialog(context,
  //       type: ProgressDialogType.Normal, isDismissible: false);

  //   pr.style(message: 'progress_dialog_message'.tr);
  //   // pr.show();

  //   FirebaseFirestore.instance
  //       .collection("animalSellingInfo")
  //       .doc(FirebaseAuth.instance.currentUser.uid)
  //       .collection('sellingAnimalList')
  //       .get()
  //       .then(
  //     (value) {
  //       List _info = [];
  //       value.docs.forEach((element) {
  //         _info.add(element.data());
  //       });
  //       setState(() {
  //         // _animalInfo = _info;
  //         // lengthOfInfo = _animalInfo.length;
  //         // prefs.setString('animalDetails', jsonEncode(_info));
  //       });
  //       // pr.hide();
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return widget.sellingAnimalInfo.length == 0
        ? SellAnimalForm(
            userName: widget.userName,
          )
        : SellingAnimalInfo(
            animalInfo: widget.sellingAnimalInfo,
            userName: widget.userName,
          );
  }
}
