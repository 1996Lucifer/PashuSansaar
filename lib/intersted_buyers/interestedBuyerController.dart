import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';

import 'interestedBuyerModel.dart';

class InterestedBuyerController extends GetxController {
  interstedBuyers({String animalId, String userId,int page, String token,}) async {
    Map<String, dynamic> payload = {
      "animalId": animalId,
      "userId": userId,
      "page": page
    };

    try {
      var response = await Dio().post(
        GlobalUrl.baseUrl + GlobalUrl.interestedBuyers,
        data: json.encode(payload),
        options: Options(
          headers: {
            "Authorization": token,
          },
        ),
      );

      if (response.data != null) {
        InterestedBuyerModel interstedBuyersData;
        if (response.statusCode == 200 || response.statusCode == 201) {
          interstedBuyersData = InterestedBuyerModel.fromJson(response.data);
        }
        return interstedBuyersData.interestedBuyers;
      }
    } catch (e) {
      print("Getting my animal list exception _______$e");
      return [];
    }
  }
}
