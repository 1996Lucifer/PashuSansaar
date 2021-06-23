import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/global_data/global_data.dart';
import 'package:pashusansaar/refreshToken/refresh_token_model.dart';

class RefreshTokenController extends GetxController {
  var status = false.obs;
  var accessToken = ''.obs, refreshToken = ''.obs;
  var expires = 0.obs;

  getRefreshToken({
    String access,
    String refresh,
  }) async {
    Map<String, dynamic> payload = {'refreshToken': refresh};

    String url = GlobalData.baseUrl + GlobalData.refreshToken;

    Options options = new Options(
      headers: {
        "Authorization": access,
      },
    );

    try {
      var res =
          await Dio().post(url, data: json.encode(payload), options: options);
      if (!res.isBlank) {
        if (res.statusCode == 200) {
          RefreshTokenModel refreshTokenModel =
              RefreshTokenModel.fromJson(res.data);

          accessToken.value = refreshTokenModel.accessToken;
          refreshToken.value = refreshTokenModel.refreshToken;
          expires.value = refreshTokenModel.expires;

          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      print("Exceptions refresh token_______$e");
      return false;
    }
  }
}
