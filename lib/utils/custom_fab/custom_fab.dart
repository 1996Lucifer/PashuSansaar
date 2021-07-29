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
        closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.red)),
        closedColor: appPrimaryColor,
        closedBuilder: (context, openContainer) => Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: appPrimaryColor,
            ),
            height: 100,
            width: 56,
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                'Kaisa Pashu Chahiye',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )

            // child: Icon(
            //   Icons.chat,
            //   color: Colors.white,
            // ),
            ),
      );
}
