import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pashusansaar/home_screen.dart';
import 'package:pashusansaar/login/login_controller.dart';
import 'package:pashusansaar/otp/otp_controller.dart';
import 'package:pashusansaar/otp/otp_model.dart';
import 'package:pashusansaar/user_details/user_details_update_screen.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_details/user_details_fetch_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_countdown_timer/index.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  OTPScreen(this.phoneNumber);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  var onTapRecognizer;

  TextEditingController textEditingController = TextEditingController();
  String _verificationCode;
  int _resendToken;

  StreamController<ErrorAnimationType> errorController;

  bool hasError = false, _startTimer = false;
  String currentText = "";
  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'otpScaffoldKey');
  final formKey = GlobalKey<FormState>(debugLabel: 'otpFormStateKey');
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
  CountdownTimerController countdownTimerController;
  final OtpController otpController = Get.put(OtpController());
  final LoginController loginController = Get.put(LoginController());
  OtpModel otpContResponse;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        try {
          loginController.requestOTP(number: widget.phoneNumber);

          countdownTimerController =
              CountdownTimerController(endTime: endTime, onEnd: onEnd);
          setState(() {
            _startTimer = true;
          });
          return ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('OTP भेजा गया है')));
        } catch (e) {
          ReusableWidgets.showDialogBox(
            context,
            'warning'.tr,
            Text(
              'global_error'.tr,
            ),
          );
        }
      },
    );

    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
      try{
        loginController.requestOTP(number: widget.phoneNumber);
        countdownTimerController = CountdownTimerController(
          endTime: DateTime.now().millisecondsSinceEpoch + 1000 * 60,
          onEnd: onEnd,
        );

        setState(() {
          _startTimer = true;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('OTP पुनः भेजा गया है')));

        // Navigator.pop(context);
      } catch (e) {
        ReusableWidgets.showDialogBox(
          context,
          'warning'.tr,
          Text(
            'global_error'.tr,
          ),
        );
      }
      };
    errorController = StreamController<ErrorAnimationType>();
    checkUserLoginState();
    super.initState();
  }

  void onEnd() {
    print('onEnd');
  }

  checkUserLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('mobileNumber', widget.phoneNumber);
    });
  }

  textWidget() => RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "did_not_receive_code".tr,
          style: TextStyle(color: Colors.black54, fontSize: 15),
          children: [
            TextSpan(
              text: "resend_button".tr,
              // recognizer: TapGestureRecognizer()..onTap(),
              recognizer: onTapRecognizer,
              style: TextStyle(
                  color: appPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            // WidgetSpan(
            //     child: _startTimer ? Text('Hello') : Text('.'))
          ],
        ),
      );

  @override
  void dispose() {
    errorController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            SizedBox(height: 30),
            Container(
              height: MediaQuery.of(context).size.height / 3.4,
              child: Image.asset(
                'assets/images/AppIcon.jpg',
                height: 200,
                width: 200,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'phone_title'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: RichText(
                text: TextSpan(
                    text: "enter_code".tr,
                    children: [
                      TextSpan(
                          text: widget.phoneNumber,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                    style: TextStyle(color: Colors.black54, fontSize: 15)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: formKey,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                  child: PinCodeTextField(
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: appPrimaryColor,
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
                      activeColor: appPrimaryColor,
                      activeFillColor: Colors.white,
                      inactiveColor: appPrimaryColor,
                      inactiveFillColor: Colors.white,
                      selectedColor: appPrimaryColor,
                      selectedFillColor: Colors.white,
                    ),

                    cursorColor: Colors.black,
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: Colors.white,
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
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
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      print("Allowing to paste $text");
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                hasError ? "empty_cell_error".tr : "",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            !_startTimer
                ? textWidget()
                : Center(
                    child: CountdownTimer(
                      controller: countdownTimerController,
                      onEnd: onEnd,
                      endTime: endTime,
                      textStyle: TextStyle(
                          color: appPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      endWidget: textWidget(),
                    ),
                  ),
            SizedBox(width: 10),
            SizedBox(
              height: 14,
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  padding: EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 5,
                  color: appPrimaryColor,
                  child: Text(
                    "verify_button".tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    formKey.currentState.validate();
                    // conditions for validating
                    if (currentText.length != 6 &&
                        currentText != _verificationCode) {
                      errorController.add(ErrorAnimationType.shake);

                      setState(() {
                        hasError = true;
                      });
                    } else {
                      setState(() {
                        hasError = false;
                      });
                      try {
                        var otpResponse = await otpController.verifyOTP(
                          number: widget.phoneNumber,
                          otp: textEditingController.text,
                        );
                        setState(() {
                          otpContResponse = otpResponse;
                        });
                        if (OtpController.isUserPresent) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserDetailsUpdate(
                                        mobile: widget.phoneNumber,
                                        name: otpContResponse.name,
                                        zipcode: otpContResponse.zipCode,
                                        referralCode: '',
                                        currentUser: '',
                                      )));
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserDetailsFetch(
                                        mobile: widget.phoneNumber,
                                      )));
                        }
                      } catch (e) {
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('invalid_otp'.tr)));
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
