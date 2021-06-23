import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/domain/auth/auth_token_conf/auth_token_model.dart';
import 'package:pashusansaar/global_data/global_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthToken extends GetxController {
  var status = false.obs;
  var accessToken = ''.obs, refreshToken = ''.obs, userId = ''.obs;
  var expires = 0.obs;

  fetchAuthToken({
    String number,
    String apkVersion,
    Map<String, dynamic> mobileInfo,
    String name,
    String referredByCode,
    String latitude,
    String longitude,
    String cityName,
    String zipCode,
    String userAddress,
    String token,
  }) async {
    Map<String, dynamic> payload = {
      'mobile': number,
      'appVersion': apkVersion,
      'mobileInfo': mobileInfo,
      'name': name,
      'referredByCode': referredByCode,
      'latitude': latitude,
      'longitude': longitude,
      "district": cityName,
      "zipCode": zipCode,
      "userAddress": userAddress
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("______payload_____________$payload");
    print("_________bearerToken__________${token.toString()}");

    String url = GlobalData.baseUrl + GlobalData.registerUser;

    Options options = new Options(
      headers: {
        "Authorization": token ?? '',
      },
    );

    var res =
        await Dio().post(url, data: json.encode(payload), options: options);

    if (!res.isBlank) {
      try {
        if (res.statusCode == 200) {
          AuthTokenModel authTokenModel = AuthTokenModel.fromJson(res.data);

          accessToken.value = authTokenModel.accessToken;
          refreshToken.value = authTokenModel.refreshToken;
          userId.value = authTokenModel.userId;
          expires.value = authTokenModel.expires;

          status.value = true;
        } else {
          status.value = false;
        }
      } catch (e) {
        status.value = false;
        print("Exceptions user register data_______$e");
      }
    }
    return status.value;
  }
}
