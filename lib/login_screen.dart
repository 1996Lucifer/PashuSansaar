import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pashusansaar/otp_screen.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initialiseFirebaseInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
            ),
            Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/AppIcon.jpg',
                  height: 200,
                  width: 200,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "app_name".tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: Container(
                        child: TextFormField(
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.account_box),
                          border: OutlineInputBorder(),
                          labelText: 'mobile_label'.tr,
                          hintText: 'mobile_hint'.tr,
                          counterText: ""),
                      maxLength: 10,
                      autofocus: false,
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                    ))),
                SizedBox(
                  height: 20,
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
                      child: Text('login_button'.tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600)),
                      onPressed: () async {
                        if (phoneNumberController.text.isEmpty) {
                          ReusableWidgets.showDialogBox(context, 'error'.tr,
                              Text("error_empty_mobile".tr));
                        } else if (phoneNumberController.text.length < 10) {
                          ReusableWidgets.showDialogBox(context, 'error'.tr,
                              Text("error_length_mobile".tr));
                        } else {
                          await FirebaseFirestore.instance
                              .collection('otpCollection')
                              .doc(ReusableWidgets.randomCodeGenerator() +
                                  ReusableWidgets.randomIDGenerator())
                              .set({
                            'date': DateFormat()
                                .add_yMMMd()
                                .add_jm()
                                .format(DateTime.now()),
                            'mobileNumber': phoneNumberController.text
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      OTPScreen(phoneNumberController.text)));
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        )
            //   ],
            // )
            ));
  }
}
