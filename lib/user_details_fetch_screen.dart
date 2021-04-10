import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
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
// import 'package:geoflutterfire/geoflutterfire.dart' as geoFire;

class UserDetailsFetch extends StatefulWidget {
  final String currentUser, mobile;
  UserDetailsFetch({Key key, @required this.currentUser, @required this.mobile})
      : super(key: key);

  @override
  _UserDetailsFetchState createState() => _UserDetailsFetchState();
}

class _UserDetailsFetchState extends State<UserDetailsFetch> {
  var onTapRecognizer;
  bool _showReferralData = false, hasError = false, _zipCodeTextField = false;
  ProgressDialog pr;
  int count = 0;
  TextEditingController nameController = new TextEditingController();
  TextEditingController referralCodeController = new TextEditingController();
  TextEditingController zipCodeController = new TextEditingController();
  Map<String, dynamic> mobileInfo = {};
  LocationData _locate;
  // Map _profileData = {};

  // final geo = geoFire.Geoflutterfire();

  String currentText = "";

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showReferralData = !_showReferralData;
        });
      };
    // getInitialData();
    getLocationLocate();
    super.initState();
  }

  // getInitialData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   pr = new ProgressDialog(context,
  //       type: ProgressDialogType.Normal, isDismissible: false);

  //   pr.style(message: 'progress_dialog_message'.tr);
  //   pr.show();

  //   FirebaseFirestore.instance
  //       .collection("userInfo")
  //       .doc(FirebaseAuth.instance.currentUser.uid)
  //       .get(GetOptions(source: Source.serverAndCache))
  //       .then(
  //     (value) {
  //       setState(() {
  //         _profileData = value.data();
  //         prefs.setString('profileData', jsonEncode(_profileData));
  //       });
  //       pr.hide();
  //     },
  //   );

  //   if (_profileData.isEmpty)
  //     getLocationLocate();
  //   else
  //     Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => HomeScreen(selectedIndex: 0)));
  // }

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

  loadAsset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var addresses =
        await Geocoder.local.findAddressesFromQuery(zipCodeController.text);
    var first = addresses.first;

    setState(() {
      prefs.setDouble("latitude", first.coordinates.latitude);
      prefs.setDouble("longitude", first.coordinates.longitude);
    });

    // pr = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false);
    // pr.style(message: 'progress_dialog_message'.tr);
    // pr.show();
    // final myData = await rootBundle.loadString("assets/file/zipcode.csv");
    // List<List<dynamic>> data = CsvToListConverter().convert(myData);

    // for (int i = 0; i <= data.length - 1; i++) {
    //   if (data[i][0].toString() == zipCodeController.text) {
    //     setState(() {
    //       prefs.setDouble("latitude", data[i][1]);
    //       prefs.setDouble("longitude", data[i][2]);
    //     });
    //   } else {
    //     setState(() {
    //       prefs.setDouble("latitude", 0.0);
    //       prefs.setDouble("longitude", 0.0);
    //     });
    //   }
    // }
    // pr.hide();
    // return true;
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
                            prefixIcon: Icon(Icons.account_box),
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
                              prefixIcon: Icon(Icons.location_on),
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
                              autoDisposeControllers: false,
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
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();

                            if (_zipCodeTextField &&
                                zipCodeController.text.isNotEmpty)
                              await loadAsset();
                            pr = new ProgressDialog(context,
                                type: ProgressDialogType.Normal,
                                isDismissible: false);
                            pr.style(message: 'progress_dialog_message'.tr);
                            pr.show();
                            FirebaseFirestore.instance
                                .collection("userInfo")
                                .doc(widget.currentUser)
                                .set({
                              "currentUser": widget.currentUser,
                              "name": nameController.text,
                              "mobile": widget.mobile,
                              "mobileInfo": mobileInfo,
                              // 'position': geoFire.Geoflutterfire()
                              //     .point(
                              //         latitude: prefs.getDouble('latitude'),
                              //         longitude: prefs.getDouble('longitude'))
                              //     .data,
                              'latitude':
                                  prefs.getDouble('latitude').toString(),
                              'longitude':
                                  prefs.getDouble('longitude').toString(),
                              'referralCode':
                                  ReusableWidgets.randomCodeGenerator(),
                              'enteredReferralCode': referralCodeController
                                      .text.isNotEmpty
                                  ? referralCodeController.text.toUpperCase()
                                  : '',
                              'alreadyUser': true
                            }).then((result) {
                              pr.hide();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen(selectedIndex: 0)));
                            }).catchError(
                                    (err) => print("err->" + err.toString()));
                          }
                        },
                      ),
                    ),
                  ),
                ]))));
  }
}
