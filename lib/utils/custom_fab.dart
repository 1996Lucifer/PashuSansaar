import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pashusansaar/buy_animal/animal_info_form.dart';

import 'colors.dart';

const double fabSize = 56;

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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: appPrimaryColor,
          ),
          height: fabSize,
          width: fabSize,
          child: Icon(
            Icons.chat,
            color: Colors.white,
          ),
        ),
      );
}
