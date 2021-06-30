import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/domain/auth/auth_token_conf/auth_token_model.dart';
import 'package:pashusansaar/global_data/global_data.dart';

class AnimalSellingForm extends GetxController {
  var status = false.obs;

  fetchAnimalSellingFormData({
    int animalType,
    String animalBreed,
    int animalAge,
    int animalBayat,
    int animalMilk,
    int animalMilkCapacity,
    int animalPrice,
    int isRecentBayat,
    String recentBayatTime,
    int isPregnant,
    int pregnantTime,
    String userId,
    String moreInfo,
    List files,
    String accessToken,
  }) async {
    Map<String, dynamic> payload = {
      'animalType': animalType,
      'animalBreed': animalBreed,
      'animalAge': animalAge,
      'animalBayat': animalBayat,
      'animalMilk': animalMilk,
      'animalMilkCapacity': animalMilkCapacity,
      'animalPrice': animalPrice,
      'isRecentBayat': isRecentBayat,
      'recentBayatTime': recentBayatTime,
      'isPregnant': isPregnant,
      'pregnantTime': pregnantTime,
      'userId': userId,
      'moreInfo': moreInfo,
      "files": [
        // {"fileName": fileName1,"fileType":imagepng},
        // {"fileName": fileName1,"fileType":"image/png"},
        // {"fileName": fileName2,"fileType":"image/png"},
        // {"fileName": fileName3,"fileType":"video/mp4"}
      ]
    };

    String url = GlobalData.baseUrl + GlobalData.saveAnimals;

    Options options = new Options(
      headers: {
        "Authorization": accessToken,
      },
    );

    var res =
        await Dio().post(url, data: json.encode(payload), options: options);

    if (!res.isBlank) {
      try {
        if (res.statusCode == 200) {
          AuthTokenModel authTokenModel = AuthTokenModel.fromJson(res.data);
          GlobalData.userId = authTokenModel.userId;
          // print("_________check status 4 of res_____${authTokenModel.refreshToken}");
          // print("_________check status 4 of res_____${authTokenModel.success}");
          status.value = authTokenModel.success;
        } else {
          status.value = false;
        }
      } catch (e) {
        status.value = false;
        print("Exceptions user Login_______$e");
      }
    }
    return status.value;
  }
}
