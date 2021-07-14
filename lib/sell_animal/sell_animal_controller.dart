import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';

class SellAnimalController extends GetxController {
  saveAnimal({
    int animalType,
    String animalBreed,
    int animalAge,
    int animalBayat,
    int animalMilk,
    int animalMilkCapacity,
    int animalPrice,
    int isRecentBayat,
    int recentBayatTime,
    int isPregnant,
    int pregnantTime,
    String userId,
    String moreInfo,
    List files,
    String token,
  }) async {
    Map<String, dynamic> payload = {
      "animalType": animalType,
      "animalBreed": animalBreed,
      "animalAge": animalAge,
      "animalBayat": animalBayat,
      "animalMilk": animalMilk,
      "animalMilkCapacity": animalMilkCapacity,
      "animalPrice": animalPrice,
      "isRecentBayat": isRecentBayat,
      "recentBayatTime": recentBayatTime,
      "isPregnant": isPregnant,
      "pregnantTime": pregnantTime,
      "userId": userId,
      "moreInfo": moreInfo,
      "files": files,
    };

    bool status = false;

    try {
      String url = GlobalUrl.baseUrl + GlobalUrl.saveAnimals;

      dio.Options options = new dio.Options(
        headers: {
          "Authorization": token ?? '',
        },
      );


      print('payload is $payload');


      dio.Response res = await dio.Dio()
          .post(url, data: json.encode(payload), options: options);
      print('response will be called');

      if (res != null) {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          status = true;
        } else {
          status = false;
        }
      } else {
        status = false;
      }

      return status;
    } catch (e) {
      print("Exceptions save animal data_______$e");
      return status;
    }
  }
}
