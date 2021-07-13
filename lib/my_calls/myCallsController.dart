import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/my_calls/myCallsModel.dart';
import 'package:pashusansaar/utils/urls.dart';

class MyCallListController extends GetxController {
  getCallList({String userId, String token, int page}) async {
    Map<String, dynamic> payload = {
      "userId": userId,
      "page": page,
    };

    try {
      var response = await Dio().post(
        GlobalUrl.baseUrl + GlobalUrl.getCallList,
        data: json.encode(payload),
        options: Options(
          headers: {
            "Authorization": token,
          },
        ),
      );

      if (response.data != null) {
        MyCallsModel myCallData;
        if (response.statusCode == 200 || response.statusCode == 201) {
          myCallData = MyCallsModel.fromJson(response.data);
        }
        return myCallData.myCalls;
      }
    } catch (e) {
      print("Getting my call list exception _______$e");
      return [];
    }
  }
}
