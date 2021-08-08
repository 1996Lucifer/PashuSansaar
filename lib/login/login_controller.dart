import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';

class LoginController extends GetxController {
  var status = false.obs;

  requestOTP({String number}) async {
    Map payload = {
      'mobile': number,
    };

    String url = GlobalUrl.baseUrl + GlobalUrl.requestOTP;

    var response = await Dio().post(url, data: json.encode(payload));

    if (response.data != null) {
      try {
        var data = response.data;
        if (data['expires'] != null) {
          var expires = data['expires'];
          print('This is the response if data$expires');
          print('This is the response if data$data');
          status.value = true;
        } else {
          status.value = false;
        }
      } catch (e) {
        status.value = false;
        print("Exceptions user Login_______$e");
      }
    }
    return status.value;
  }
}
