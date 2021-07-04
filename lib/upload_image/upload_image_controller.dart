import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:pashusansaar/upload_image/upload_image_model.dart';
import 'package:pashusansaar/utils/urls.dart';

class UploadImageController extends GetxController {
  uploadImage({
    List files,
    String token,
    String userId,
  }) async {
    Map<String, dynamic> payload = {
      "userId": userId,
      "files": files,
    };
    
    try {
      dio.Options options = new dio.Options(
        headers: {
          "Authorization": token,
        },
      );

      dio.Response res = await dio.Dio().post(
        GlobalUrl.baseUrl + GlobalUrl.uploadImage,
        data: json.encode(payload),
        options: options,
      );

      if (!res.isBlank) {
        UploadImageModel uploadImageData;
        if (res.statusCode == 200 || res.statusCode == 201) {
          uploadImageData = UploadImageModel.fromJson(res.data);
          return uploadImageData.urls;
        }
      } else {
        return [];
      }
    } catch (e) {
      print("Exceptions upload image _______$e");
      return [];
    }
  }
}
