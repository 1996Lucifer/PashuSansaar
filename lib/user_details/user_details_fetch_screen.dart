import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pashusansaar/domain/auth/otp_conf/otp_model.dart';
import 'package:pashusansaar/domain/auth/auth_token_conf/auth_token_controller.dart';
import 'package:pashusansaar/global_data/global_data.dart';
import 'package:pashusansaar/home_screen.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/global.dart';
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
     OtpModel otpModel;

  UserDetailsFetch({Key key, @required this.currentUser, @required this.mobile,})
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
  final AuthToken authController = Get.put(AuthToken());
  TextEditingController referralCodeController = new TextEditingController();
  TextEditingController zipCodeController = new TextEditingController();
  Map<String, dynamic> mobileInfo = {};
  LocationData _locate;
  LocationData add;

  String currentText = "";

  final formKey = GlobalKey<FormState>(debugLabel: 'userDetailsFetch');

  @override
  void initState() {
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showReferralData = !_showReferralData;
        });
      };
    // getLocationLocate();
    _determinePosition();
    loadAsset();
    super.initState();
  }

  // getLocationLocate() async {
  //   Location location = new Location();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   bool _serviceEnabled;
  //   PermissionStatus _permissionGranted;
  //   LocationData _locationData;
  //
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       setState(() {
  //         _zipCodeTextField = true;
  //       });
  //       await assignDeviceID();
  //       return;
  //     }
  //   }
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       setState(() {
  //         _zipCodeTextField = true;
  //       });
  //       await assignDeviceID();
  //       return;
  //     }
  //   }
  //   _locationData = await location.getLocation();
  //   final coordinates = new Coordinates(_locationData.longitude,_locationData.latitude);
  //   print("+++++++++${coordinates}++++++++++++++++");
  //   var addressesByGps =
  //   await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   var firstByGps = addressesByGps.first;
  //
  //
  //
  //   setState(() {
  //
  //     _locate = _locationData;
  //     prefs.setDouble("latitude", _locate.latitude);
  //     prefs.setDouble("longitude", _locate.longitude);
  //     prefs.setString("userAddress",firstByGps.featureName );
  //   });
  //   await assignDeviceID();
  // }






   _determinePosition() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        setState(() {
                  _zipCodeTextField = true;
                });
        return Future.error('Location permissions are denied');
      }

    }

    if (permission == LocationPermission.deniedForever) {

      setState(() {
        _zipCodeTextField = true;
      });
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');


    }


    Position position = await Geolocator.getCurrentPosition();
    var address = await placemarkFromCoordinates(position.latitude,position.longitude);

    // print("+++++++++${position.latitude}++++++++++++++++");
    // print("+++++++++${position.longitude}++++++++++++++++");
    // print("++++name+++++${address[0].name}++++++++++++++++");
    // print("+++country++++++${address[0].country}++++++++++++++++");
    //  print("++++locality++district+++${address[0].locality}++++++++++++++++");
    // print("+++subLocality++++++name+++++++userAddress+++++++++++++++++${address[0].subLocality}++++++++++++++++");
    // print("+++subAdministrativeArea++++++${address[0].subAdministrativeArea}++++++++++++++++");
    // print("+++postalCode+++zipCode+++${address[0].postalCode}++++++++++++++++");
    // print("++++administrativeArea+++++${address[0].administrativeArea}++++++++++++++++");
    // print("+++++isoCountryCode++++${address[0].isoCountryCode}++++++++++++++++");
    // print("+++street++++++${address[0].street}++++++++++++++++");

    setState(() {
      prefs.setDouble("latitude", position.latitude);
      prefs.setDouble("longitude", position.longitude);
      prefs.setString("userAddress", address[0].name+' '+address[0].subLocality);
      prefs.setString("zipCode", address[0].postalCode);
      prefs.setString("district", address[0].locality);

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

  storeFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = await FirebaseMessaging.instance.getToken();

    print(_token);

    FirebaseFirestore.instance
        .collection("fcmToken")
        .doc(widget.currentUser)
        .set({
      "id": widget.currentUser,
      'lat': prefs.getDouble('latitude').toString(),
      'long': prefs.getDouble('longitude').toString(),
      'userToken': _token
    }).catchError((err) {
      print(
        "errToken->" + err.toString(),
      );
      FirebaseFirestore.instance
          .collection('logger')
          .doc(widget.mobile)
          .collection('token')
          .doc()
          .set({
        'issue': err.toString(),
        'userId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser.uid,
        'date': DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
    });
  }

  loadAsset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var addresses =
        await Geocoder.local.findAddressesFromQuery(zipCodeController.text);
    var first = addresses.first;

    setState(() {
      prefs.setDouble("latitudeByZipCodeController", first.coordinates.latitude);
      prefs.setDouble("longitudeByZipCodeController", first.coordinates.longitude);
      prefs.setString("userAddressByZipCodeController", first.featureName);
      prefs.setString("userAddressByZipCodeController", first.postalCode);
      prefs.setString("userAddressByZipCodeController", first.featureName);
    });
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

                            await storeFCMToken();

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
                                            text: 'location_error'.tr,
                                            style: DefaultTextStyle.of(context)
                                                .style,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: prefs.getInt('count') ==
                                                          1
                                                      ? 'location_error_supportive_exit'
                                                          .tr
                                                      : 'location_error_supportive_again'
                                                          .tr,
                                                  style: DefaultTextStyle.of(
                                                          context)
                                                      .style),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                              child: Text(
                                                'Ok'.tr,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              onPressed: () {
                                                print("=====================${prefs.getString("userAddress").toString()}===============");
                                                if (prefs.getInt('count') == 1)
                                                  exit(0);
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
                                pr = new ProgressDialog(context,
                                    type: ProgressDialogType.Normal,
                                    isDismissible: false);
                               bool status=await authController.fetchAuthToken(
                                    mobileInfo: mobileInfo,
                                    name: nameController.text,
                                    apkVersion: prefs
                                        .getStringList('currentVersion')
                                        .join('.'),
                                    longitude:
                                    prefs.getDouble('longitude').toString(),
                                    latitude: prefs.getDouble('latitude').toString(),
                                    referredByCode:  referralCodeController.text.isNotEmpty
                                        ? referralCodeController.text
                                        .toUpperCase()
                                        : '',
                                    number: widget.mobile,zipCode: prefs.getString("zipCode").toString(),
                                 userAddress: prefs.getString("userAddress").toString(),
                                 cityName: prefs.getString("district").toString(),



                                  );
                               if(status=="fh"){
                                 Navigator.pushReplacement(
                                   context,
                                   MaterialPageRoute(
                                     builder: (context) =>
                                         HomeScreen(selectedIndex: 0),
                                   ),
                                 );
                               }





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
                                  'userId': FirebaseAuth.instance.currentUser ==
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
                          }
                        },
                      ),
                    ),
                  ),
                ]))));
  }
}
