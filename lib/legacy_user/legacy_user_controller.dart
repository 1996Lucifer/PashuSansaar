import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/legacy_user/legacy_user_model.dart';
import 'package:pashusansaar/utils/urls.dart';

class LegacyUserController extends GetxController {
  getLegacyUserData({
    String number,
    String legacyId,
  }) async {
    Map payload = {
      'mobile': number,
      'legacyID': legacyId,
    };

    String url = GlobalUrl.baseUrl + GlobalUrl.legacyUser;

    var response = await Dio().post(
      url,
      data: json.encode(payload),
    );

    if (response.data != null) {
      try {
        LegacyUserModel legacyUser;
        if (response.statusCode == 200 || response.statusCode == 201) {
          legacyUser = LegacyUserModel.fromJson(response.data);
        }
        return legacyUser;
      } catch (e) {
        print("Exceptions user Login_______$e");
        return LegacyUserModel.fromJson({
          "success": false,
          "accessToken": "",
          "refreshToken": "",
          "userId": "",
          "expires": null
        });
      }
    }
  }
}
