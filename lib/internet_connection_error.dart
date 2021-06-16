import 'package:flutter/material.dart';

class NoInterNet extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(children: [
        Image.asset(
          'assets/images/no-internet-connection.jpg',
          height: 200,
          width: 200,
        ),
      ],),
    );
  }
}
