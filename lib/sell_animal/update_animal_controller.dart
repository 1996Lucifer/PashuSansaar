import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';

class UpdateAnimalController extends GetxController {
  updateAnimal({
    int animalType,
    String animalBreed,
    int animalAge,
    int animalBayat,
    int animalMilk,
    int animalMilkCapacity,
    int animalPrice,
    bool isRecentBayat,
    int recentBayatTime,
    bool isPregnant,
    int pregnantTime,
    int animalHasBaby,
    String userId,
    String moreInfo,
    List files,
    String token,
    String animalId,
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
      "animalId": animalId,
      "animalHasBaby": animalHasBaby,
    };

    bool status = false;

    try {
      String url = GlobalUrl.baseUrl + GlobalUrl.updateAnimal;

      dio.Options options = new dio.Options(
        headers: {
          "Authorization": token ?? '',
        },
      );

      print('payload is=--$payload');

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
      print("Exceptions update animal data_______$e");
      return status;
    }
  }
}
