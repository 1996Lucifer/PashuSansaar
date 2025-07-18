import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:pashusansaar/home_screen.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';

class UserDetailsUpdate extends StatefulWidget {
  final String currentUser, mobile, name, referralCode;
  UserDetailsUpdate({
    Key key,
    @required this.currentUser,
    @required this.mobile,
    @required this.name,
    @required this.referralCode,
  }) : super(key: key);

  @override
  _UserDetailsUpdateState createState() => _UserDetailsUpdateState();
}

class _UserDetailsUpdateState extends State<UserDetailsUpdate> {
  var onTapRecognizer;
  bool _showReferralData = false, hasError = false, _zipCodeTextField = false;
  ProgressDialog pr;
  int count = 0;
  TextEditingController nameController = new TextEditingController();
  TextEditingController referralCodeController = new TextEditingController();
  TextEditingController zipCodeController = new TextEditingController();
  Map<String, dynamic> mobileInfo = {};
  LocationData _locate;

  String currentText = "";

  final formKey = GlobalKey<FormState>(debugLabel: 'UserDetailsUpdate');

  @override
  void initState() {
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showReferralData = !_showReferralData;
        });
      };

    getInitialData();
    super.initState();
  }

  getInitialData() async {
    setState(() {
      nameController.text = widget.name;
      referralCodeController.text = widget.referralCode;
    });
    await getLocationLocate();
  }

  getLocationLocate() async {
    Location location = new Location();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          _zipCodeTextField = true;
        });
        await assignDeviceID();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          _zipCodeTextField = true;
        });
        await assignDeviceID();
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _locate = _locationData;
      prefs.setDouble("latitude", _locate.latitude);
      prefs.setDouble("longitude", _locate.longitude);
    });
    await assignDeviceID();
  }

  assignDeviceID() async {
    String deviceType, deviceId, deviceName;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceType = "android";
        deviceId = build.androidId; //UUID for Android
        deviceName = build.model;
        setState(() {
          mobileInfo = {
            'deviceType': deviceType,
            'deviceId': deviceId,
            'deviceName': deviceName
          };
        });
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceType = "ios";
        deviceId = data.identifierForVendor; //UUID for iOS
        deviceName = data.model;
        setState(() {
          mobileInfo = {
            'deviceType': deviceType,
            'deviceId': deviceId,
            'deviceName': deviceName
          };
        });
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
  }

  storeFCMToken(SharedPreferences prefs) async {
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = await FirebaseMessaging.instance.getToken();
      Coordinates coordinates = Coordinates(
          prefs.getDouble('latitude'), prefs.getDouble('longitude'));

      print('coordinates===' + coordinates.toString());

      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);

      print('address===' + addresses.toString());
      var first = addresses.first;

      print(_token);
      FirebaseFirestore.instance
          .collection("fcmToken")
          .doc(widget.currentUser)
          .set({
        "id": widget.currentUser,
        'lat': prefs.getDouble('latitude').toString(),
        'long': prefs.getDouble('longitude').toString(),
        'userToken': _token,
        'district': ReusableWidgets.mappingDistrict(
          first.subAdminArea ?? first.locality ?? first.featureName,
        )
      });
    } catch (err) {
      print(
        "errToken->" + err.toString(),
      );
      FirebaseFirestore.instance
          .collection('logger')
          .doc(widget.mobile)
          .collection('token-update')
          .doc()
          .set({
        'issue': err.toString(),
        'userId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser.uid,
        'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
    }
  }

  loadAsset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var addresses =
          await Geocoder.local.findAddressesFromQuery(zipCodeController.text);
      var first = addresses.first;
      if (first.countryCode == "IN") {
        setState(() {
          prefs.setDouble("latitude", first.coordinates.latitude);
          prefs.setDouble("longitude", first.coordinates.longitude);
        });
      } else {
        ReusableWidgets.showDialogBox(
            context, 'warning'.tr, Text('invalid_zipcode_error'.tr));
      }
    } catch (e) {
      print('zipcode-error===>' + e.toString());
      ReusableWidgets.showDialogBox(
        context,
        'warning'.tr,
        Text(
          'invalid_zipcode_error'.tr,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ReusableWidgets.getAppBar(context, 'Enter Details', false),
        backgroundColor: Colors.grey[100],
        body: GestureDetector(
            onTap: () {
              return WidgetsBinding.instance.focusManager.primaryFocus
                  ?.unfocus();
            },
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView(children: <Widget>[
                  SizedBox(height: 30),
                  Container(
                    height: MediaQuery.of(context).size.height / 3.4,
                    child: Image.asset(
                      'assets/images/userDetail.png',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'enter_name'.tr,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(15),
                      child: TextFormField(
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.account_box,
                            ),
                            border: OutlineInputBorder(),
                            labelText: 'name_label'.tr,
                            hintText: 'name_hint'.tr,
                            counterText: ""),
                        autofocus: false,
                        controller: nameController,
                        keyboardType: TextInputType.text,
                      )),
                  Visibility(
                    visible: _zipCodeTextField,
                    child: Padding(
                        padding: EdgeInsets.all(15),
                        child: TextFormField(
                          maxLength: 6,
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.location_on,
                              ),
                              border: OutlineInputBorder(),
                              labelText: 'zipcode_label'.tr,
                              hintText: 'zipcode_hint'.tr,
                              counterText: ""),
                          autofocus: false,
                          controller: zipCodeController,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                        )),
                    replacement: SizedBox.shrink(),
                  ),
                  SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "have_referral_code".tr,
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                        children: [
                          TextSpan(
                              text: "click_here".tr,
                              recognizer: onTapRecognizer,
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible: _showReferralData,
                    child: Form(
                        key: formKey,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 30),
                            child: PinCodeTextField(
                              appContext: context,
                              pastedTextStyle: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              length: 6,
                              obscureText: false,
                              obscuringCharacter: '*',
                              blinkWhenObscuring: true,
                              animationType: AnimationType.fade,

                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeColor: primaryColor,
                                activeFillColor: Colors.white,
                                inactiveColor: primaryColor,
                                inactiveFillColor: Colors.white,
                                selectedColor: primaryColor,
                                selectedFillColor: Colors.white,
                              ),
                              cursorColor: Colors.black,
                              animationDuration: Duration(milliseconds: 300),
                              backgroundColor: Colors.white,
                              enableActiveFill: true,
                              controller: referralCodeController,
                              autoDisposeControllers: true,
                              keyboardType: TextInputType.text,
                              boxShadows: [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  color: Colors.black12,
                                  blurRadius: 10,
                                )
                              ],
                              onCompleted: (v) {
                                print("Completed");
                              },
                              // onTap: () {
                              //   print("Pressed");
                              // },
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  currentText = value.toUpperCase();
                                });
                              },
                              beforeTextPaste: (text) {
                                print("Allowing to paste $text");
                                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                //but you ca show anything you want here, like your pop up saying wrong paste format or etc
                                return true;
                              },
                            ))),
                    replacement: SizedBox.shrink(),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 5,
                        color: primaryColor,
                        child: Text('proceed_button'.tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          if (nameController.text.isEmpty) {
                            ReusableWidgets.showDialogBox(context, 'error'.tr,
                                Text("error_empty_name".tr));
                          } else if (nameController.text.length < 3) {
                            ReusableWidgets.showDialogBox(context, 'error'.tr,
                                Text("error_length_name".tr));
                          } else if (_zipCodeTextField &&
                              zipCodeController.text.isEmpty) {
                            ReusableWidgets.showDialogBox(context, 'error'.tr,
                                Text("error_empty_zipcode".tr));
                          } else if (_zipCodeTextField &&
                              zipCodeController.text.length < 6) {
                            ReusableWidgets.showDialogBox(context, 'error'.tr,
                                Text("error_length_zipcode".tr));
                          } else {
                            pr = new ProgressDialog(context,
                                type: ProgressDialogType.Normal,
                                isDismissible: false);

                            pr.style(message: 'progress_dialog_message'.tr);
                            pr.show();

                            Future.delayed(Duration(seconds: 2))
                                .then((value) async {
                              pr.hide();
                              if (_zipCodeTextField &&
                                  zipCodeController.text.isNotEmpty)
                                await loadAsset();

                              await storeFCMToken(prefs);

                              if (prefs.getDouble('latitude') == null ||
                                  prefs.getDouble('longitude') == null) {
                                return showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return AlertDialog(
                                          title: Text('warning'.tr),
                                          content: RichText(
                                            text: TextSpan(
                                                text: prefs.getInt('count') == 1
                                                    ? 'location_error_supportive_exit'
                                                        .tr
                                                    : 'location_error_supportive_again'
                                                        .tr,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16)),
                                          ),
                                          actions: <Widget>[
                                            ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                primaryColor)),
                                                child: Text(
                                                  'Ok'.tr,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                onPressed: () {
                                                  if (prefs.getInt('count') ==
                                                      1)
                                                    SystemNavigator.pop();
                                                  else {
                                                    setState(() {
                                                      _zipCodeTextField = true;
                                                      prefs.setInt('count', 1);
                                                    });
                                                    Navigator.pop(context);
                                                  }
                                                }),
                                          ]);
                                    });
                              } else {
                                try {
                                  pr.show();
                                  FirebaseFirestore.instance
                                      .collection("userInfo")
                                      .doc(widget.currentUser)
                                      .update({
                                    "name": nameController.text,
                                    "mobileInfo": mobileInfo,
                                    'latitude':
                                        prefs.getDouble('latitude').toString(),
                                    'longitude':
                                        prefs.getDouble('longitude').toString(),
                                    'enteredReferralCode':
                                        referralCodeController.text.isNotEmpty
                                            ? referralCodeController.text
                                                .toUpperCase()
                                            : '',
                                    'appVersion': prefs
                                        .getStringList('currentVersion')
                                        .join('.'),
                                    'dateOfCreation': FirebaseAuth.instance
                                        .currentUser.metadata.creationTime
                                        .toString(),
                                    'dateOfUpdation': FirebaseAuth.instance
                                        .currentUser.metadata.lastSignInTime
                                        .toString(),
                                    'zipcode': zipCodeController.text ?? ''
                                  }).then((result) {
                                    pr.hide().then(
                                          (isHidden) => Get.off(
                                            () => HomeScreen(
                                              selectedIndex: 0,
                                            ),
                                          ),
                                          // return Navigator.pushReplacement(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         HomeScreen(selectedIndex: 0),
                                          //   ),
                                          // );
                                        );
                                  });
                                } catch (err) {
                                  // pr.hide();
                                  print(
                                    "err->" + err.toString(),
                                  );
                                  FirebaseFirestore.instance
                                      .collection('logger')
                                      .doc(widget.mobile)
                                      .collection('userDetails')
                                      .doc()
                                      .set({
                                    'issue': err.toString(),
                                    'userId': FirebaseAuth
                                                .instance.currentUser ==
                                            null
                                        ? ''
                                        : FirebaseAuth.instance.currentUser.uid,
                                    'date': DateFormat()
                                        .add_yMMMd()
                                        .add_jm()
                                        .format(DateTime.now()),
                                  });
                                }
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ]))));
  }
}
