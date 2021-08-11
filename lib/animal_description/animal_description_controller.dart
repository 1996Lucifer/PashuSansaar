import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/animal_description/animal_description_model.dart';
import 'package:pashusansaar/utils/urls.dart';

class AnimalDescriptionController extends GetxController {
  animalDescription(
      {String animalId,
      String userId,
      String senderUserId,
      String accessToken}) async {
    Map<String, dynamic> payload = {
      "animalId": animalId,
      "senderuserId": senderUserId,
      "userId": userId,
    };

    AnimalDescriptionModel animalDescriptionData;

    try {
      var response = await Dio().post(
        GlobalUrl.baseUrl + GlobalUrl.animalDescription,
        data: json.encode(payload),
        options: Options(
          headers: {
            "Authorization": accessToken,
          },
        ),
      );

        animalDescriptionData = AnimalDescriptionModel.fromJson(response.data);
        print('animal description is $animalDescriptionData');
        if (response.statusCode == 200 || response.statusCode == 201) {
          return animalDescriptionData.animal;
        }

    } catch (e) {
      print("Getting exception in getting animal description _______$e");
      return null;
    }
  }
}
