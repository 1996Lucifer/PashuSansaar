import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/domain/auth/auth_token_conf/auth_token_model.dart';
import 'package:pashusansaar/global_data/global_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthToken extends GetxController {
  var status = false.obs;

  fetchAuthToken(
      {String number,
      String apkVersion,
      Map<String, dynamic> mobileInfo,
      String name,
      String referredByCode,
      String latitude,
      String longitude,
      String cityName,
      String zipCode,
      String userAddress,
      }) async {
    Map<String, dynamic> payload = {
      'mobile': number,
      'appVersion': apkVersion,
      'mobileInfo': mobileInfo,
      'name': name,
      'referredByCode': referredByCode,
      'latitude': latitude,
      'longitude': longitude,
      "district":cityName,
      "zipCode":zipCode,
      "userAddress":userAddress
    };

     print("______payload_____________$payload");
    // print("_________bearerToken__________${GlobalData.authorizationToken}");

    String url = GlobalData.baseUrl + GlobalData.registerUser;

    Options options = new Options(
      headers: {
        "Authorization": GlobalData.authorizationToken,
      },
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var response1 =
        new Dio().post(url, data: json.encode(payload), options: options);
    // print("_________check status 2 of res_____${response1}");
    var res = await response1;
    // print("_________check status 3 of res_____$res");

    if (!res.isBlank) {
      try {
        if (res.statusCode == 200) {
          AuthTokenModel authTokenModel = AuthTokenModel.fromJson(res.data);
          GlobalData.userId= authTokenModel.userId;
          prefs.setString("accessToken", authTokenModel.accessToken);
          prefs.setString("refreshToken", authTokenModel.refreshToken);
          prefs.setString("userId", authTokenModel.userId);
          prefs.setInt("expires", authTokenModel.expires);
          // print("_________check status 4 of res_____${authTokenModel.refreshToken}");
          // print("_________check status 4 of res_____${authTokenModel.success}");
          status.value = authTokenModel.success;
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
