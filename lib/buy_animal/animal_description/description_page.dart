import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geodesy/geodesy.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class AnimalDescription extends StatefulWidget {
  final animalInfo;
  final lat;
  final lon;


  AnimalDescription({Key key, @required this.animalInfo,@required this.lat,@required this.lon});

  @override
  _AnimalDescriptionState createState() => _AnimalDescriptionState();
}

int _current = 0;
String whatsappText = '';
String whatsappUrl = '';
File fileUrl;


class _AnimalDescriptionState extends State<AnimalDescription> {




  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              _infoText1(),
              SizedBox(
                height: 5,
              ),
              // Text(_distanceBetweenTwoCoordinates()),
               _distanceTimeMethod(),
              SizedBox(
                height: 10,
              ),
              _animalImage(),
              SizedBox(
                height: 10,
              ),
              _infoText2(),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _getCallButton(),
                  _getWhatsAppButton(),
                  _getShareButton(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText1() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: widget.animalInfo['userAnimalMilk'],
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  children: [
                    TextSpan(
                      text: ' ',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: "litre_milk".tr,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: ', ',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: bayaatMapping(
                          widget.animalInfo['userAnimalPregnancy']),
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: ', ',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: '₹ ' + widget.animalInfo['userAnimalPrice'],
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ])),
        ),
      ],
    );
  }

  getPositionBasedOnLatLong(double lat, double long) async {
    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    return first.locality ?? first.featureName;
  }

  Widget _distanceTimeMethod() {
    String val = '';
    // List _list = widget.animalInfo;

    return StatefulBuilder(builder: (context, setState1) {
      getPositionBasedOnLatLong(widget.animalInfo['userLatitude'],
              widget.animalInfo['userLongitude'])
          .then((result) {
        setState1(() {
          val = result;
        });
      });

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.clock,
              color: Colors.grey[500],
              size: 13,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: ' ' +
                      ReusableWidgets.dateDifference(
                          ReusableWidgets.epochToDateTime(
                              widget.animalInfo['dateOfSaving'])),
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  children: [
                    TextSpan(
                      text: ' | ',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ]),
            ),
            Icon(
              Icons.location_on_outlined,
              color: Colors.grey[500],
              size: 13,
            ),
            val.runes.length > 20
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: val.toString(),
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                  )
                : RichText(
                    text: TextSpan(
                        text: val.toString(),
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                            fontSize: 13))),
            RichText(
              text: TextSpan(
                text: ' (',
                style: TextStyle(
                    color: Colors.grey[500],
                    // fontWeight: FontWeight.bold,
                    fontSize: 13),
                children: [
                  TextSpan(
                    text: _distanceBetweenTwoCoordinates() + ' ' + 'km'.tr,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  TextSpan(
                    text: ' )',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  )
                ],
              ),
            ),
          ],
        ),
      );
      // });
    });
  }

  String _distanceBetweenTwoCoordinates() {
    return (Geodesy().distanceBetweenTwoGeoPoints(
              LatLng(widget.lat, widget.lon),
              LatLng(widget.animalInfo['userLatitude'],
                  widget.animalInfo['userLongitude']),
            ) /
            1000)
        .toStringAsFixed(0);
  }

  Widget _infoText2() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        widget.animalInfo['userAnimalDescription'] ?? "",
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 14.5),
      ),
    );
  }

  Widget _getCallButton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: darkSecondaryColor),
      ),
      color: secondaryColor,
      onPressed: () => launch("tel://${widget.animalInfo}"),
      icon: Icon(
        Icons.phone,
        color: Colors.white,
      ),
      label: Text(
        'call',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _getWhatsAppButton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: darkGreenColor)),
      color: darkGreenColor,
      onPressed: () async {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // var addresses = await Geocoder.local.findAddressesFromCoordinates(
        //     Coordinates(
        //         prefs.getDouble('latitude'), prefs.getDouble('longitude')));
        // var first = addresses.first;
        // String whatsappUrl = '';
        // callingInfo['userIdCurrent'] = FirebaseAuth.instance.currentUser.uid;
        // callingInfo['userIdOther'] = widget.animalInfo['userId'];
        // callingInfo['otherListId'] = widget.animalInfo['uniqueId'];
        // callingInfo['channel'] = "whatsapp";
        // callingInfo['userAddress'] = widget.animalInfo['userAddress'];
        // callingInfo["userAnimalDescription"] =
        // widget.animalInfo['userAnimalDescription'];
        // callingInfo["userAnimalType"] =
        //     widget.animalInfo['userAnimalType'] ?? "";
        // callingInfo["userAnimalTypeOther"] =
        //     widget.animalInfo['userAnimalTypeOther'] ?? "";
        // callingInfo["userAnimalAge"] =
        //     widget.animalInfo['userAnimalAge'] ?? "";
        // callingInfo["userAddress"] = widget.animalInfo['userAddress'];
        // callingInfo["userName"] = widget.animalInfo['userName'];
        // callingInfo["userAnimalPrice"] =
        //     widget.animalInfo['userAnimalPrice'] ?? "0";
        // callingInfo["userAnimalBreed"] =
        //     widget.animalInfo['userAnimalBreed'] ?? "";
        // callingInfo["userMobileNumber"] =
        // widget.animalInfo['userMobileNumber'];
        // callingInfo["userAnimalMilk"] =
        //     widget.animalInfo['userAnimalMilk'] ?? "";
        // callingInfo["userAnimalPregnancy"] =
        //     widget.animalInfo['userAnimalPregnancy'] ?? "";
        // callingInfo["image1"] = widget.animalInfo == null ||
        //     widget.animalInfo['image1'] == ""
        //     ? ""
        //     : widget.animalInfo['image1'];
        // callingInfo["image2"] = widget.animalInfo['image2'] == null ||
        //     widget.animalInfo['image2'] == ""
        //     ? ""
        //     : widget.animalInfo['image2'];
        // callingInfo["image3"] = widget.animalInfo['image3'] == null ||
        //     widget.animalInfo['image3'] == ""
        //     ? ""
        //     : widget.animalInfo['image3'];
        // callingInfo["image4"] = widget.animalInfo['image4'] == null ||
        //     widget.animalInfo['image4'] == ""
        //     ? ""
        //     :widget.animalInfo['image4'];
        // callingInfo["dateOfSaving"] =
        //     ReusableWidgets.dateTimeToEpoch(DateTime.now());
        // callingInfo['isValidUser'] = widget.animalInfo['isValidUser'];
        // callingInfo['extraInfo'] = widget.animalInfo['extraInfo'] ?? {};

        // FirebaseFirestore.instance
        //     .collection("callingInfo")
        //     .doc(callingInfo['otherListId'])
        //     .collection('interestedBuyers')
        //     .doc(FirebaseAuth.instance.currentUser.uid)
        //     .set({
        //   'userName': widget.userName,
        //   'userMobileNumber': widget.userMobileNumber,
        //   "userAddress":
        //       first.addressLine ?? (first.adminArea + ', ' + first.countryName),
        //   'userIdCurrent': FirebaseAuth.instance.currentUser.uid,
        //   'userIdOther': widget.animalInfo['userId'],
        //   'otherListId': widget.animalInfo['uniqueId'],
        //   'channel': "whatsapp",
        //   "dateOfSaving": ReusableWidgets.dateTimeToEpoch(DateTime.now())
        // }, SetOptions(merge: true));

        // FirebaseFirestore.instance
        //     .collection("myCallingInfo")
        //     .doc(FirebaseAuth.instance.currentUser.uid)
        //     .collection('myCalls')
        //     .doc(callingInfo['otherListId'])
        //     .set(callingInfo, SetOptions(merge: true));

        whatsappText = 'नमस्कार भाई साहब, मैंने आपका पशु देखा पशुसंसार पे और आपसे आगे बात करना चाहता हूँ. कब बात कर सकते हैं? ${widget.animalInfo['userName']}, ${_distanceBetweenTwoCoordinates()} \n\nपशुसंसार सूचना - ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन  एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है';
        whatsappUrl =
            "https://api.whatsapp.com/send/?phone=+91 ${widget.animalInfo['userMobileNumber']}&text=$whatsappText";
        await UrlLauncher.canLaunch(whatsappUrl) != null
            ? UrlLauncher.launch(Uri.encodeFull(whatsappUrl))
            : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    '${widget.animalInfo['userMobileNumber']} is not present in Whatsapp'),
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 8),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ));
      },
      icon: FaIcon(
        FontAwesomeIcons.whatsapp,
        color: Colors.white,
        size: 14,
      ),
      label: Text(
        'message'.tr,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _getShareButton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: violetColor)),
      color: violetColor,
      onPressed: () {
        Share.shareFiles([fileUrl.path],
            mimeTypes: ['images/png'],
            text:
            "नस्ल: ${widget.animalInfo['userAnimalBreed']}\nजानकारी: ${widget.animalInfo['userAnimalDescription']}\nदूध(प्रति दिन): ${widget.animalInfo['userAnimalMilk']} Litre\n\nऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar} \n\n",
            subject: 'पशु की जानकारी');
      },
      icon: Icon(Icons.share, color: Colors.white, size: 14),
      label: Text(
        'share'.tr,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _animalImage() {
    Size size = MediaQuery.of(context).size;
    List _images=[
      widget.animalInfo['image1'],
      widget.animalInfo['image2'],
      widget.animalInfo['image3'],
      widget.animalInfo['image4'],
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0),
      height: size.width * 0.57,
      width: size.width,
      child:CarouselSlider(
        options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.9,
            viewportFraction: 1.0,
            pageSnapping: false,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) => setState(() {})),
        items: [
          widget.animalInfo['image1'],
          widget.animalInfo['image2'],
          widget.animalInfo['image3'],
          widget.animalInfo['image4'],
        ].map(
              (i) {
            return Builder(
              builder: (BuildContext context) {
                return i.length > 1000
                    ? Image.memory(
                  base64Decode('$i'),
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                )
                // : Image.file(fileUrl);
                    : Image.network(
                  '$i',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                );
              },
            );
          },
        ).toList(),
      ),
    );

    // GestureDetector(
    //   onTap: () {
    //     return Navigator.of(context).push(
    //       PageRouteBuilder(
    //         opaque: true,
    //         pageBuilder: (BuildContext context, _, __) =>
    //             StatefulBuilder(
    //               builder: (context, setState) {
    //                 return Column(
    //                   children: [
    //                     CarouselSlider(
    //                       options: CarouselOptions(
    //                           height: MediaQuery.of(context).size.height * 0.9,
    //                           viewportFraction: 1.0,
    //                           pageSnapping: false,
    //                           initialPage: 0,
    //                           enableInfiniteScroll: true,
    //                           reverse: false,
    //                           autoPlay: true,
    //                           autoPlayInterval: Duration(seconds: 3),
    //                           autoPlayAnimationDuration: Duration(milliseconds: 800),
    //                           autoPlayCurve: Curves.fastOutSlowIn,
    //                           enlargeCenterPage: true,
    //                           scrollDirection: Axis.horizontal,
    //                           onPageChanged: (index, reason) => setState(() {})),
    //                       items: [
    //                         widget.animalInfo['image1'],
    //                         widget.animalInfo['image2'],
    //                         widget.animalInfo['image3'],
    //                         widget.animalInfo['image4'],
    //                       ].map(
    //                             (i) {
    //                           return Builder(
    //                             builder: (BuildContext context) {
    //                               return i.length > 1000
    //                                   ? Image.memory(
    //                                 base64Decode('$i'),
    //                                 fit: BoxFit.cover,
    //                                 height: double.infinity,
    //                                 width: double.infinity,
    //                                 alignment: Alignment.center,
    //                               )
    //                               // : Image.file(fileUrl);
    //                                   : Image.network(
    //                                 '$i',
    //                                 fit: BoxFit.cover,
    //                                 height: double.infinity,
    //                                 width: double.infinity,
    //                                 alignment: Alignment.center,
    //                               );
    //                             },
    //                           );
    //                         },
    //                       ).toList(),
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         widget.animalInfo['image1'],
    //                         widget.animalInfo['image2'],
    //                         widget.animalInfo['image3'],
    //                         widget.animalInfo['image4'],
    //                       ].map((url) {
    //                         int indexData = [
    //                           widget.animalInfo['image1'],
    //                           widget.animalInfo['image2'],
    //                           widget.animalInfo['image3'],
    //                           widget.animalInfo['image4'],
    //                         ].indexOf(url);
    //                         return Container(
    //                           width: 8.0,
    //                           height: 8.0,
    //                           margin: EdgeInsets.symmetric(
    //                               vertical: 10.0, horizontal: 2.0),
    //                           decoration: BoxDecoration(
    //                             shape: BoxShape.circle,
    //                             color: _current == indexData
    //                                 ? Color.fromRGBO(255, 255, 255, 1)
    //                                 : Color.fromRGBO(255, 255, 255, 0.4),
    //                           ),
    //                         );
    //                       }).toList(),
    //                     ),
    //                   ],
    //                 );
    //               },
    //             ),
    //       ),
    //     );
    //   },
    //   child: Container(
    //     height: 200.0,
    //     decoration: BoxDecoration(
    //       image: DecorationImage(
    //           fit: BoxFit.cover,
    //           image: _images[0].length > 1000
    //               ? MemoryImage(base64.decode(_images[0]))
    //               : NetworkImage(_images[0])),
    //       borderRadius: BorderRadius.all(Radius.circular(8.0)),
    //       color: Colors.redAccent,
    //     ),
    //   ),
    // ),

  }






  removingNumberFromBayaat(String bayaat) {
    return bayaat.split('').reversed.skip(4).toList().reversed.join('');
  }

  bayaatMapping(bayaat) {
    String bayaaat = '';
    switch (bayaat) {
      case 'ब्यायी नहीं (0)':
        bayaaat = removingNumberFromBayaat('zero'.tr);
        break;
      case 'पहला (1)':
        bayaaat = removingNumberFromBayaat('first'.tr) +
            ' ' +
            'animal_is_pregnant'.tr;
        break;
      case 'दूसरा (2)':
        bayaaat = removingNumberFromBayaat('second'.tr) +
            ' ' +
            'animal_is_pregnant'.tr;
        break;
      case 'तीसरा (3)':
        bayaaat = removingNumberFromBayaat('third'.tr) +
            ' ' +
            'animal_is_pregnant'.tr;
        break;
      case 'चौथा (4)':
        bayaaat = removingNumberFromBayaat('fourth'.tr) +
            ' ' +
            'animal_is_pregnant'.tr;
        break;
      case 'पांचवा (5)':
        bayaaat = removingNumberFromBayaat('fifth'.tr) +
            ' ' +
            'animal_is_pregnant'.tr;
        break;
      case 'छठा (6)':
        bayaaat = removingNumberFromBayaat('sixth'.tr) +
            ' ' +
            'animal_is_pregnant'.tr;
        break;
      case 'सातवाँ (7)':
        bayaaat = removingNumberFromBayaat('seventh'.tr) +
            ' ' +
            'animal_is_pregnant'.tr;
        break;
      default:
        bayaaat = '';
        break;
    }

    return bayaaat;
  }
}
