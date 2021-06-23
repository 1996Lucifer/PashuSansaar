import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/global_data/global_data.dart';

import 'buying_animal_model.dart';

class BuyAnimalController extends GetxController {
  getAnimal(
      {double latitude,
      double longitude,
      int distance,
      int animalType,
      int page,
      int minMilk,
      int maxMilk,
      String accessToken,
      String refreshToken}) async {
    Map<String, dynamic> payload = {
      "latitude": latitude,
      "longitude": longitude,
      "animalType": animalType,
      "minMilk": minMilk,
      "maxMilk": maxMilk,
      "page": page
    };

    try {
      var response = await Dio().post(
        GlobalData.baseUrl + GlobalData.getAnimals,
        data: json.encode(payload),
        options: Options(
          headers: {
            "Authorization": accessToken,
          },
        ),
      );

      if (response.statusCode >= 420 && response.statusCode <= 430) {}

      if (response.data != null) {
        BuyAnimalModel buyAnimalData;
        if (response.statusCode == 200 || response.statusCode == 201) {
          buyAnimalData = BuyAnimalModel.fromJson(response.data);
        }
        return buyAnimalData.result;
      }
    } catch (e) {
      print("Exceptions get animal _______$e");
      return [];
    }
  }
}
