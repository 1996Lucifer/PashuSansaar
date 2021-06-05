import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pashusansaar/address_auto_complete/model/auto_address_model.dart';

class AutoSaeachUtil {
  static List<AutoComplete> autoCompleteList = [];

  static Future<List<AutoComplete>> fetchAddressData({location}) async {
    String _location = location;
    String url =
        'http://www.mapquestapi.com/search/v3/prediction?key=0EBTxXBnrVP2CRrL8EcNcv6sXUgRbx3h&collection=address,adminArea,category&q=$_location&countryCode=IN';
    print("Api hit");
    try {
      final response = await http.get(Uri.parse(url));
      var daautoCompleteListta = jsonDecode(response.body);
      List<dynamic> list = daautoCompleteListta['results']
          .map((result) => new AutoComplete.fromJson(result))
          .toList();
      autoCompleteList.clear();
      for (int b = 0; b < list.length; b++) {
        AutoComplete autoCompleteModel = list[b] as AutoComplete;

        autoCompleteList.add(autoCompleteModel);
      }

      print("This is the Name ${daautoCompleteListta['results'][0]['name']}.");
    } catch (e) {
      print("Exception________$e");
    }
    return autoCompleteList;
  }
}
