import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';

import 'otp_model.dart';

class OtpController extends GetxController {
  var status = false.obs;
  var isUser = false.obs;
  var authorization = ''.obs;
  static var isUserPresent = false;

  verifyOTP({
    String number,
    String otp,
  }) async {
    Map payload = {
      'mobile': number,
      'value': otp,
    };

    String url = GlobalUrl.baseUrl + GlobalUrl.verifyOtp;

    try {
      var response = await Dio().post(url, data: json.encode(payload));

      if (response.data != null) {
        var data = response.data;
        if (response.statusCode == 200 || response.statusCode == 201) {
          OtpModel otpData = OtpModel.fromJson(data);

          isUser.value = false;
          status.value = otpData.success;
          authorization.value = otpData.authorizationToken;
          return otpData;
        } else if (response.statusCode == 211) {
          OtpModel otpData = OtpModel.fromJson(data);

          authorization.value = otpData.authorizationToken;
          isUser.value = true;
          isUserPresent = true;
          status.value = true;
          return otpData;
        }
      }
    } catch (e) {
      status.value = false;
      print("Exceptions user Login otp _______$e");
      return '';
    }
  }
}
