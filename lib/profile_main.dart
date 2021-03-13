import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share/share.dart';
import 'home_screen.dart';
import 'utils/colors.dart';
import 'utils/reusable_widgets.dart';
import 'package:marquee/marquee.dart';

class ProfileMain extends StatefulWidget {
  Map profileData;
  ProfileMain({Key key, @required this.profileData}) : super(key: key);
  @override
  ProfileMainState createState() => ProfileMainState();
}

class ProfileMainState extends State<ProfileMain>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  ImagePicker _picker;
  String _base64Image = "";
  Map userInfo = {};
  ProgressDialog pr;

  @override
  void initState() {
    // TODO: implement initState
    populateData();
    super.initState();
  }

  populateData() {
    if (widget.profileData == {})
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('error'.tr),
                content: Text('problem_loading_data'.tr),
                actions: <Widget>[
                  FlatButton(
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
    else {
      setState(() {
        userInfo['name'] = widget.profileData['name'];
        userInfo['mobile'] = widget.profileData['mobile'];
        userInfo['image'] = widget.profileData['image'];
      });
    }
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
                // if (animalInfo['animalType'] == null)
                //   ReusableWidgets.showDialogBox(
                //     context,
                //     'error'.tr,
                //     Text('animal_type_error'.tr),
                //   );
                // else if (animalInfo['animalBreed'] == null)
                //   ReusableWidgets.showDialogBox(
                //     context,
                //     'error'.tr,
                //     Text('animal_breed_error'.tr),
                //   );

                pr = new ProgressDialog(context,
                    type: ProgressDialogType.Normal, isDismissible: false);

                pr.style(message: 'progress_dialog_message'.tr);
                pr.show();

                FirebaseFirestore.instance
                    .collection("userInfo")
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .update({
                  "name": userInfo['name'],
                  "image": userInfo['image']
                }).then(
                  (value) {
                    pr.hide();
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: Text('Success'.tr),
                              content: Text('Profile updated Successfully'.tr),
                              actions: <Widget>[
                                FlatButton(
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            ReusableWidgets.getAppBar(context, "app_name".tr, false, actions: [
          GestureDetector(
            onTap: () => Share.share(
                'पशुसंसार (पशु बेचने वाली फ्री ऐप) पर मेरे साथ जुड़ें। मेरा कोड ADFTR6 दर्ज करें और ₹50,000 जीतने का मौका पाएं। \n\n https://docs.google.com/spreadsheets/d/1PQertE_bd2Z0VfJf8G9HvYLmifqq0qGblrMlsnDzuLY/edit#gid=0')
            //AIzaSyDg5o_0j0MC5dueSVRYp4WkCjrJPQxm7pg
            ,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.share),
            ),
          )
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
                children: <Widget>[
                  new Container(
                    height: 200.0,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child:
                              new Stack(fit: StackFit.loose, children: <Widget>[
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                    width: 140.0,
                                    height: 140.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        image:
                                            // ExactAssetImage(
                                            //     'assets/images/profile.jpg'),
                                            userInfo["image"] == null
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
                                    EdgeInsets.only(top: 90.0, right: 100.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => chooseOption(),
                                      child: new CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 20.0,
                                        child: new Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                          ]),
                        )
                      ],
                    ),
                  ),
                  new Container(
                    color: Color(0xffFFFFFF),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 25.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 5.0),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Personal Information',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      _status
                                          ? _getEditIcon()
                                          : new Container(),
                                    ],
                                  )
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'name_label'.tr,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextFormField(
                                      initialValue: widget.profileData['name'],
                                      decoration: InputDecoration(
                                        hintText: 'name_hint'.tr,
                                      ),
                                      enabled: !_status,
                                      autofocus: !_status,
                                      onChanged: (String val) {
                                        userInfo['name'] = val;
                                      },
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'mobile_label'.tr,
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 2.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Flexible(
                                    child: new TextFormField(
                                      initialValue:
                                          widget.profileData['mobile'],
                                      decoration: InputDecoration(
                                          hintText: "mobile_hint".tr),
                                      enabled: false,
                                      // enabled: !_status,
                                    ),
                                  ),
                                ],
                              )),
                          !_status ? _getActionButtons() : new Container(),
                          saveButton()
                        ],
                      ),
                    ),
                  )
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

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text('save_button'.tr),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  // pr = new ProgressDialog(context,
                  //     type: ProgressDialogType.Normal, isDismissible: false);

                  // pr.style(message: 'progress_dialog_message'.tr);
                  // pr.show();

                  // FirebaseFirestore.instance
                  //     .collection("userInfo")
                  //     .doc(FirebaseAuth.instance.currentUser.uid)
                  //     .update({
                  //   "name": userInfo['name'],
                  //   "image": _base64Image
                  // }).then(
                  //   (value) {
                  //     pr.hide();
                  //     ReusableWidgets.showDialogBox(context, 'Success',
                  //         Text("Profile updated Successfully"));
                  //   },
                  // );
                  setState(() {
                    _status = !_status;
                    FocusScope.of(context).unfocus();
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return FlatButton(
        onPressed: () {
          setState(() {
            _status = false;
          });
        },
        child: Row(
          children: [
            Text(
              'change_info'.tr,
              style: TextStyle(color: primaryColor, fontSize: 15),
            ),
            SizedBox(
              width: 5,
            ),
            FaIcon(
              FontAwesomeIcons.edit,
              color: primaryColor,
              size: 16,
            )
          ],
        ));
  }
}
