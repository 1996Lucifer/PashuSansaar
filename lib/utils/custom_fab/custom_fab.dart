import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pashusansaar/buy_animal/animal_info_form.dart';

import '../colors.dart';

const double fabSize = 100;

class CustomFABWidget extends StatelessWidget {
  final String userMobileNumber, userName;

  const CustomFABWidget({
    Key key,
    @required this.userMobileNumber,
    @required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => OpenContainer(
        transitionDuration: Duration(seconds: 2),
        openBuilder: (context, _) => AnimalInfoForm(
          userMobileNumber: userMobileNumber,
          userName: userName,
        ),
        closedShape: CircleBorder(),
        closedColor: appPrimaryColor,
        closedBuilder: (context, openContainer) => Container(
          // key: UniqueKey(),
          height: 60,
          width: 60,
          child: Center(
            child: Image.asset(
              'assets/images/postBuyer.png',
              width: 45,
              height: 45,
            ),
          ),
        ),
      );
}
