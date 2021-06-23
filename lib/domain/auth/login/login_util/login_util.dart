import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/domain/auth/otp_conf/otp_model.dart';
import 'package:pashusansaar/global_data/global_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  var status = false.obs;

  fetchUser({String number}) async {
    Map payload = {
      'mobile': number,
    };

    String url = GlobalData.baseUrl + GlobalData.requestOTP;

    var response = await Dio().post(url, data: json.encode(payload));

    if (response.data != null) {
      try {
        var data = response.data;
        if (data['expires'] != null) {
          var expires = data['expires'];
          print('This is the risponse if data$expires');
          print('This is the risponse if data$data');
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

class OtpController extends GetxController {
  var status = false.obs;
  var isUser = false.obs;
  var authorization = ''.obs;

  fetchOtpVerify({
    String number,
    String otp,
  }) async {
    Map payload = {
      'mobile': number,
      'value': otp,
    };

    String url = GlobalData.baseUrl + GlobalData.verifyOtp;

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
