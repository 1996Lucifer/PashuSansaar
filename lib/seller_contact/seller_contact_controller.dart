import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';

class SellerContactController extends GetxController {
  getSellerContact({String animalId, String userId, List<Map> channel,String token,}) async {
    Map<String, dynamic> payload = {
      "animalId": animalId,
      "userId": userId,
      "channel": channel
    };

    try {
      var response = await Dio().post(
        GlobalUrl.baseUrl + GlobalUrl.getSellerContact,
        data: json.encode(payload),
        options: Options(
          headers: {
            "Authorization": token,
          },
        ),
      );

      if (response.data != null) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.data['sellerMobile'];
        }
      }
    } catch (e) {
      print("Getting seller contact number exception _______$e");
      return '';
    }
  }
}
