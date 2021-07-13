import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/my_animals/myAnimalModel.dart';
import 'package:pashusansaar/utils/urls.dart';

class MyAnimalListController extends GetxController {
  getAnimalList({String userId, String token, int page}) async {
    Map<String, dynamic> payload = {
      "userId": userId,
      "page": page,
    };

    try {
      var response = await Dio().post(
        GlobalUrl.baseUrl + GlobalUrl.getAnimalList,
        data: json.encode(payload),
        options: Options(
          headers: {
            "Authorization": token,
          },
        ),
      );

      if (response.data != null) {
        MyAnimalModel myAnimalData;
        if (response.statusCode == 200 || response.statusCode == 201) {
          myAnimalData = MyAnimalModel.fromJson(response.data);
        }
        return myAnimalData.myAnimals;
      }
    } catch (e) {
      print("Getting my animal list exception _______$e");
      return [];
    }
  }
}
