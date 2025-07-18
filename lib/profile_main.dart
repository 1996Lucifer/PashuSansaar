import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'my_called_list.dart';
import 'sell_animal/sell_animal_info.dart';
import 'utils/colors.dart';
import 'utils/reusable_widgets.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

// ignore: must_be_immutable
class ProfileMain extends StatefulWidget {
  Map profileData;
  Map refData;
  final List sellingAnimalInfo;
  final String userName;
  final String userMobileNumber;

  ProfileMain({
    Key key,
    @required this.profileData,
    @required this.refData,
    @required this.sellingAnimalInfo,
    @required this.userName,
    @required this.userMobileNumber,
  }) : super(key: key);
  @override
  ProfileMainState createState() => ProfileMainState();
}

class ProfileMainState extends State<ProfileMain>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final FocusNode myFocusNode = FocusNode();
  ImagePicker _picker;
  String _base64Image = "", _currentVersion = '';
  Map userInfo = {};
  ProgressDialog pr;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    populateData();
    super.initState();
  }

  populateData() async {
    if (widget.profileData == null || widget.profileData.isEmpty) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('error'.tr),
                content: Text('problem_loading_data'.tr),
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        'Ok'.tr,
                        style: TextStyle(color: primaryColor),
                      ),
                      onPressed: () {
                        // pr.hide();
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                selectedIndex: 0,
                              ),
                            ));
                      }),
                ]);
          });
    } else {
      // pr.show();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var address = await Geocoder.local.findAddressesFromCoordinates(
          Coordinates(
              prefs.getDouble('latitude'), prefs.getDouble('longitude')));
      var first = address.first;

      setState(() {
        userInfo['name'] = widget.profileData['name'];
        userInfo['mobile'] = widget.profileData['mobile'];
        userInfo['image'] = widget.profileData['image'];
        userInfo['address'] =
            first.addressLine ??
            (first.adminArea +
                ' ' +
                first.postalCode +
                ', ' +
                first.countryName);
        _currentVersion = prefs.getStringList('currentVersion').join('.');
      });
      // getCallingInfo();
    }
    // pr.hide();
  }

  Future<void> _choose() async {
    try {
      if (_picker == null) {
        _picker = ImagePicker();
      }
      var file = await _picker.getImage(source: ImageSource.camera);

      switch (file) {
        case null:
          return null;
          break;
        default:
          File compressedFile = await FlutterNativeImage.compressImage(
              file.path,
              quality: 90,
              targetWidth: 500,
              targetHeight: 500);

          setState(() {
            _base64Image = base64Encode(
              compressedFile.readAsBytesSync(),
            );
            userInfo['image'] = _base64Image;
          });
      }

      if (userInfo['image'] != null || userInfo['image'] != '') {
        pr = new ProgressDialog(context,
            type: ProgressDialogType.Normal, isDismissible: false);

        pr.style(message: 'progress_dialog_message'.tr);
        pr.show();

        FirebaseFirestore.instance
            .collection("userInfo")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({"image": userInfo['image']}).then(
          (value) {
            pr.hide();
            return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      title: Text('Success'.tr),
                      content: Text('प्रोफाइल फोटो अपलोड कर दिया गया है |'),
                      actions: <Widget>[
                        TextButton(
                            child: Text(
                              'Ok'.tr,
                              style: TextStyle(color: primaryColor),
                            ),
                            onPressed: () => Navigator.pop(context)),
                      ]);
                });
          },
        );
      }
    } catch (e) {}
  }

  Future<void> _chooseFromGallery() async {
    try {
      if (_picker == null) {
        _picker = ImagePicker();
      }
      var file = await _picker.getImage(source: ImageSource.gallery);

      switch (file) {
        case null:
          return null;
          break;
        default:
          File compressedFile = await FlutterNativeImage.compressImage(
              file.path,
              quality: 90,
              targetWidth: 500,
              targetHeight: 500);

          setState(() {
            _base64Image = base64Encode(
              compressedFile.readAsBytesSync(),
            );
            userInfo['image'] = _base64Image;
          });
      }
      if (userInfo['image'] != null || userInfo['image'] != '') {
        pr = new ProgressDialog(context,
            type: ProgressDialogType.Normal, isDismissible: false);

        pr.style(message: 'progress_dialog_message'.tr);
        pr.show();

        FirebaseFirestore.instance
            .collection("userInfo")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({"image": userInfo['image']}).then(
          (value) {
            pr.hide();
            return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      title: Text('Success'.tr),
                      content: Text('प्रोफाइल फोटो अपलोड कर दिया गया है |'),
                      actions: <Widget>[
                        TextButton(
                            child: Text(
                              'Ok'.tr,
                              style: TextStyle(color: primaryColor),
                            ),
                            onPressed: () => Navigator.pop(context)),
                      ]);
                });
          },
        );
      }
    } catch (e) {}
  }

  chooseOption() => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Choose From..',
          ),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          _choose();
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(" Capture from camera")
                    ],
                  ),
                  onTap: () {
                    _choose();
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () {
                          _chooseFromGallery();
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(" Choose from gallery")
                    ],
                  ),
                  onTap: () {
                    _chooseFromGallery();
                    Navigator.of(context).pop();
                  },
                ),
              ]),
        );
      });

  Padding saveButton() => Padding(
        padding: EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity,
          child: RaisedButton(
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 5,
              // color: themeColor,
              child: Text(
                'save_button'.tr,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                pr = new ProgressDialog(context,
                    type: ProgressDialogType.Normal, isDismissible: false);

                pr.style(message: 'progress_dialog_message'.tr);
                pr.show();

                FirebaseFirestore.instance
                    .collection("userInfo")
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .update({
                  // "name": userInfo['name'],
                  "image": userInfo['image']
                }).then(
                  (value) {
                    pr.hide();
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: Text('Success'.tr),
                              content:
                                  Text('प्रोफाइल फोटो अपलोड कर दिया गया है |'),
                              actions: <Widget>[
                                TextButton(
                                    child: Text(
                                      'Ok'.tr,
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(
                                              selectedIndex: 0,
                                            ),
                                          ));
                                    }),
                              ]);
                        });
                  },
                );
              }),
        ),
      );

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            ReusableWidgets.getAppBar(context, "app_name".tr, false, actions: [
          GestureDetector(
            onTap: () => ReusableWidgets.showDialogBox(
                context, 'info'.tr, Text('ver_info'.tr)),
            child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(
                  child: Text(
                    'v' + _currentVersion,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                )),
          ),
          GestureDetector(
            onTap: () => Share.share(
                'पशुसंसार (पशु बेचने वाली फ्री ऐप) पर मेरे साथ जुड़ें। मेरा कोड ADFTR6 दर्ज करें और ₹50,000 जीतने का मौका पाएं। \n\n ऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar'),
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.share),
            ),
          ),
        ]),
        body: new Container(
          color: Colors.white,
          child: new ListView(
            children: <Widget>[
              Container(
                height: 20,
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                          'सूचना -',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        )),
                    Expanded(
                      flex: 7,
                      child: Marquee(
                        text:
                            ' ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है',
                        pauseAfterRound: Duration(seconds: 1),
                        blankSpace: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    height: 200.0,
                    color: Colors.white,
                    child: new Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: new Stack(fit: StackFit.loose, children: <
                                Widget>[
                              new Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Container(
                                      width: 120.0,
                                      height: 120.0,
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: new DecorationImage(
                                          image: userInfo["image"] == null
                                              ? ExactAssetImage(
                                                  'assets/images/profile.jpg')
                                              : MemoryImage(base64Decode(
                                                  userInfo["image"])),
                                          fit: BoxFit.cover,
                                        ),
                                      )),
                                ],
                              ),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: 70.0, right: 90.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () => chooseOption(),
                                        child: new CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 18.0,
                                          child: new Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            ]),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                userInfo['name'] == null
                                    ? Text('progress_dialog_message'.tr)
                                    : Row(
                                        children: [
                                          Icon(Icons.account_circle_outlined),
                                          SizedBox(width: 5),
                                          Text(userInfo['name'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                SizedBox(height: 5),
                                userInfo['mobile'] == null
                                    ? Text('progress_dialog_message'.tr)
                                    : Row(
                                        children: [
                                          Icon(Icons.call),
                                          SizedBox(width: 5),
                                          Text(userInfo['mobile'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                SizedBox(height: 5),
                                userInfo['address'] == null
                                    ? Text('progress_dialog_message'.tr)
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.location_on_outlined),
                                          SizedBox(width: 5),
                                          Expanded(
                                              child: Text(userInfo['address'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14))),
                                        ],
                                      ),
                              ]),
                        ))
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SellingAnimalInfo(
                                      animalInfo: widget.sellingAnimalInfo,
                                      userName: widget.userName,
                                      userMobileNumber: widget.userMobileNumber,
                                      showExtraData: false),
                                ),
                              ),
                              child: Card(
                                color: Colors.grey[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("मेरे पशु",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyCalledList(
                                      // animalInfo: widget.sellingAnimalInfo,
                                      // userName: widget.userName,
                                      // userMobileNumber: widget.userMobileNumber,
                                      // showExtraData: false
                                      ),
                                ),
                              ),
                              child: Card(
                                color: Colors.grey[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("मेरे कॉल्स",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () async {
                        return await UrlLauncher.launch(Uri.encodeFull(
                            "https://api.whatsapp.com/send/?phone=+91 9910981230"));
                      },
                      child: DottedBorder(
                        strokeWidth: 2,
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        padding: EdgeInsets.all(6),
                        color: Colors.grey[500],
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: RichText(
                                    // overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: greyColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      text:
                                          'अगर कोई भी शिकायत या सुझाव हो तो व्हाट्सप्प पर हमसे संपर्क करें',
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: darkGreenColor,
                                      size: 40,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () => Share.share(
                          'पशुसंसार (पशु बेचने वाली फ्री ऐप) पर मेरे साथ जुड़ें। मेरा कोड ADFTR6 दर्ज करें और ₹10,000 जीतने का मौका पाएं। \n\n ऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar'),
                      child: DottedBorder(
                        strokeWidth: 2,
                        borderType: BorderType.RRect,
                        radius: Radius.circular(12),
                        padding: EdgeInsets.all(6),
                        color: Colors.grey[500],
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                          child: Container(
                            height: 60,
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: RichText(
                                    // overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: greyColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      text:
                                          'पशुसंसार एप को अपने पशुपालक दोस्तों से शेयर करे और हर हफ्ते ₹10000 जीतने का मौका पाए',
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: FaIcon(
                                      FontAwesomeIcons.shareAlt,
                                      color: primaryColor,
                                      size: 40,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DottedBorder(
                          strokeWidth: 2,
                          borderType: BorderType.RRect,
                          radius: Radius.circular(12),
                          padding: EdgeInsets.all(6),
                          color: Colors.grey[500],
                          child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: RichText(
                                          // overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                              style: TextStyle(
                                                  color: greyColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                              text: 'referral_winner'.trParams({
                                                'name':
                                                    '${widget.refData['name']}',
                                                'place':
                                                    '${widget.refData['address']}'
                                              })),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: FaIcon(
                                            FontAwesomeIcons.trophy,
                                            color: goldenColor,
                                            size: 40,
                                          ))
                                    ],
                                  ))))),
                ],
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }
}
