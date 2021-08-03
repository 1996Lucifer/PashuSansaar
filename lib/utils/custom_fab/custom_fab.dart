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
          // margin: EdgeInsets.only(top: 12),
          height: 60,
          width: 60,
          child: Center(
            child: 
            Text(
              '🐄',
              style: TextStyle(color: Colors.white, fontSize: 30.0),
            ),
          ),

          // Center(
          //     child: FaIcon(
          //   FontAwesomeIcons.horse,
          //   color: Colors.white,
          // ))
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   // crossAxisAlignment: CrossAxisAlignment.stretch,
          //   children: [
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       // crossAxisAlignment: CrossAxisAlignment.stretch,
          //       children: [
          //         Text(
          //           'कैसा ',
          //           style: TextStyle(color: Colors.white, fontSize: 14.0),
          //         ),
          //         Text(
          //           '🐄',
          //           style: TextStyle(color: Colors.white, fontSize: 24.0),
          //         ),
          //       ],
          //     ),
          //     // Text(
          //     //   'चाहिये',
          //     //   style: TextStyle(color: Colors.white, fontSize: 14.0),
          //     // ),
          //   ],
          // ),
        ),
      );
}
