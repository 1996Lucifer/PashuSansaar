import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/colors.dart';

import 'constants.dart';

class ReusableWidgets {
  static getAppBar(
      BuildContext context, String heading, bool automaticallyImplyLeading,
      {List<Widget> actions}) {
    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'assets/images/cow.png',
            width: 40,
            height: 40,
          ),
          SizedBox(
            width: 5,
          ),
          Text(heading),
        ],
      ),
      backgroundColor: primaryColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
    );
  }

  static showDialogBox(BuildContext context, String type, Widget content,
      {bool cta = false, bool barrierDismissible = true}) {
    return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  CloseButton(),
                ],
              ),
              content: content,
              actions: <Widget>[
                RaisedButton(
                    child: Text(
                      'Ok'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    padding: EdgeInsets.all(5.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    onPressed: () {
                      cta ? exit(0) : Navigator.pop(context);
                    }),
              ]);
        });
  }

  static String randomCodeGenerator() {
    const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        6, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static String randomIDGenerator() {
    const _chars = '1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        8, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static String dateTimeToEpoch(DateTime date) {
    return (((date.millisecondsSinceEpoch) / 1000).round().toString());
  }

  static String epochToDateTime(String epoch) {
    DateTime dateObj =
        DateTime.fromMillisecondsSinceEpoch(int.parse(epoch) * 1000);
    var date = DateFormat('dd MMM yyyy').add_jm().format(dateObj);
    return date.toString();
  }

  static String dateDifference(String date) {
    String suffix = '';
    String duration = '';
    var dateObj = DateTime.now()
        .difference(DateFormat('dd MMM yyyy').add_jm().parse(date));

    if (dateObj.inSeconds < 60) {
      duration = dateObj.inSeconds.toString();
      suffix = 'seconds_ago'.tr;
    } else if (dateObj.inMinutes < 60) {
      duration = dateObj.inMinutes.toString();
      suffix = 'minutes_ago'.tr;
    } else if (dateObj.inHours < 24) {
      duration = dateObj.inHours.toString();
      suffix = 'hours_ago'.tr;
    } else if (dateObj.inDays < 365 || dateObj.inDays < 366) {
      duration = dateObj.inDays.toString();
      suffix = 'days_ago'.tr;
    } else {
      duration = (dateObj.inDays / 365).floor().toString();
      suffix = 'years_ago'.tr;
    }
    return '${duration + ' ' + suffix}';
  }

  static removeEnglisgDataFromName(String str) {
    List<String> x = str.split(' (')[0].split(' ');
    String str1 = x.length > 2 ? x[0] + ' ' + x[1] : x.join(' ');

    return str1;
  }

  static mappingDistrict(String str) {
    String _local = '';
    if (hindiToEnglishDistrictMapping.containsKey(str)) {
      _local = hindiToEnglishDistrictMapping[str] ?? (str);
    } else {
      _local = str;
    }

    return _local;
  }
}
