import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';

import 'buy_animal_model.dart';

class BuyAnimalController extends GetxController {
  getAnimal({
    String userId,
    double latitude,
    double longitude,
    int distance,
    int animalType,
    int page,
    int minMilk,
    int maxMilk,
    String accessToken,
  }) async {
    Map<String, dynamic> payload = {
      "userId": userId,
      "latitude": latitude,
      "longitude": longitude,
      "animalType": animalType,
      "minMilk": minMilk,
      "maxMilk": maxMilk,
      "page": page,
      "distance": distance,
    };

    try {
      var response = await Dio().post(
        GlobalUrl.baseUrl + GlobalUrl.getAnimals,
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
        return buyAnimalData;
      }
    } on Exception catch (e) {
      print("Exceptions get animal _______$e");
      return BuyAnimalModel.fromJson({
        'success': false,
        'result': [],
        'page': null,
      });
    }
  }
}
