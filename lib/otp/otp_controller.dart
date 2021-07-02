import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';

import 'otp_model.dart';

class OtpController extends GetxController {
  var status = false.obs;
  var isUser = false.obs;
  var authorization = ''.obs;

  verifyOTP({
    String number,
    String otp,
  }) async {
    Map payload = {
      'mobile': number,
      'value': otp,
    };

    String url = GlobalUrl.baseUrl + GlobalUrl.verifyOtp;

    var response = await Dio().post(url, data: json.encode(payload));

    if (response.data != null) {
      try {
        var data = response.data;
        if (response.statusCode == 200 || response.statusCode == 201) {
          OtpModel otpData = OtpModel.fromJson(data);

          isUser.value = false;
          status.value = otpData.success;
          authorization.value = otpData.authorizationToken;
        } else if (response.statusCode == 211) {
          OtpModel otpData = OtpModel.fromJson(data);

          authorization.value = otpData.authorizationToken;
          isUser.value = true;
          status.value = true;
        }
        return isUser.value;
      } catch (e) {
        status.value = false;
        print("Exceptions user Login otp _______$e");
      }
    }
    print("this is the ststus $status");
    return status.value;
  }
}
