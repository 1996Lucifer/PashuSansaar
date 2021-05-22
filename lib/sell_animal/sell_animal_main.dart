import 'package:pashusansaar/sell_animal/sell_animal_form.dart';
import 'package:pashusansaar/sell_animal/sell_animal_info.dart';
import 'package:flutter/material.dart';

class SellAnimalMain extends StatelessWidget {
  final List sellingAnimalInfo;
  final String userName;
  final String userMobileNumber;

  SellAnimalMain(
      {Key key,
      @required this.sellingAnimalInfo,
      @required this.userName,
      @required this.userMobileNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sellingAnimalInfo.length == 0
        ? SellAnimalForm(userName: userName, userMobileNumber: userMobileNumber)
        : SellingAnimalInfo(
            animalInfo: sellingAnimalInfo,
            userName: userName,
            userMobileNumber: userMobileNumber,
            showExtraData: true);
  }
}
