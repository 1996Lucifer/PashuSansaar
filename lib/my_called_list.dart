import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:share/share.dart';

import 'utils/reusable_widgets.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class MyCalledList extends StatefulWidget {
  MyCalledList({Key key}) : super(key: key);

  @override
  _MyCalledListState createState() => _MyCalledListState();
}

class _MyCalledListState extends State<MyCalledList> {
  int _current = 0;

  Row _buildInfowidget(_list) {
    var formatter = intl.NumberFormat('#,##,000');
    return Row(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: _list['userName'],
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  children: [
                    TextSpan(
                      text: ' की ',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: _list['userAnimalBreed'] == 'not_known'.tr
                          ? ""
                          : _list['userAnimalBreed'],
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: ' ',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: _list['userAnimalType'] == 'other_animal'.tr
                          ? _list['userAnimalTypeOther']
                          : _list['userAnimalType'],
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: ', ₹ ',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: formatter
                              .format(int.parse(_list['userAnimalPrice'])) ??
                          0,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ]),
            ),
          ),
        ),
      ],
    );
  }

  Padding _animalImageWidget(_list) {
    List<String> _images = [];
    [
      _list['image1'],
      _list['image2'],
      _list['image3'],
      _list['image4'],
    ].forEach((element) =>
        _images.addIf(element != null && element.isNotEmpty, element));
    return Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8, bottom: 4),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                return Navigator.of(context).push(PageRouteBuilder(
                  opaque: true,
                  pageBuilder: (BuildContext context, _, __) =>
                      StatefulBuilder(builder: (context, setState) {
                    return Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                              height: MediaQuery.of(context).size.height * 0.9,
                              viewportFraction: 1.0,
                              initialPage: 0,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 3),
                              autoPlayAnimationDuration:
                                  Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                              scrollDirection: Axis.horizontal,
                              onPageChanged: (index, reason) => setState(() {
                                    _current = index;
                                  })),
                          items: _images.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return i.length > 1000
                                    ? Image.memory(base64Decode('$i'))
                                    : Image.network('$i');
                              },
                            );
                          }).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _images.map((url) {
                            int indexData = _images.indexOf(url);
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _current == indexData
                                    ? Color.fromRGBO(255, 255, 255, 1)
                                    : Color.fromRGBO(255, 255, 255, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }),
                ));
              },
              child: Container(
                height: 200.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _images[0].length > 1000
                          ? MemoryImage(base64.decode(_images[0]))
                          : NetworkImage(_images[0])),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: Colors.redAccent,
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: Opacity(
                opacity: 0.5,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.transparent)),
                    color: Colors.black,
                    onPressed: () => null,
                    icon: FaIcon(FontAwesomeIcons.clock,
                        color: Colors.white, size: 16),
                    label: Text(
                        "${ReusableWidgets.dateDifference(ReusableWidgets.epochToDateTime(_list['dateOfSaving']))} देखा",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13))),
              ),
            )
          ],
        ));
  }

  _extraInfoWidget(_list, width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              String whatsappText =
                  "नस्ल: ${_list['userAnimalBreed']}\nजानकारी: ${_list['userAnimalDescription']}\nदूध(प्रति दिन): ${_list['userAnimalMilk']} Litre\n\nऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar";
              String whatsappUrl =
                  "https://api.whatsapp.com/send/?text=$whatsappText";
              await UrlLauncher.launch(Uri.encodeFull(whatsappUrl));
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              width: width * 0.44,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.whatsapp,
                      size: 16, color: darkGreenColor),
                  SizedBox(width: 5),
                  Text("शेयर करे")
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () =>
                UrlLauncher.launch('tel:+91 ${_list['userMobileNumber']}'),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 1.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              width: width * 0.4,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.phoneAlt,
                    color: secondaryColor,
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text('संपर्क करे')
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bayaatMapping(bayaat) {
    String bayaaat = '';
    if (["0", "1", "2", "3", "4", "5", "6", "7"].contains(bayaat)) {
      switch (bayaat) {
        case '0':
          bayaaat = 'zero'.tr;
          break;
        case '1':
          bayaaat = 'first'.tr + ' ' + 'animal_is_pregnant'.tr;

          break;
        case '2':
          bayaaat = 'second'.tr + ' ' + 'animal_is_pregnant'.tr;

          break;
        case '3':
          bayaaat = 'third'.tr + ' ' + 'animal_is_pregnant'.tr;

          break;
        case '4':
          bayaaat = 'fourth'.tr + ' ' + 'animal_is_pregnant'.tr;

          break;
        case '5':
          bayaaat = 'fifth'.tr + ' ' + 'animal_is_pregnant'.tr;

          break;
        case '6':
          bayaaat = 'sixth'.tr + ' ' + 'animal_is_pregnant'.tr;

          break;
        case '7':
          bayaaat = 'seventh'.tr + ' ' + 'animal_is_pregnant'.tr;

          break;
      }
    } else
      bayaaat = bayaat;

    return bayaaat;
  }

  _extraInfoWidget1(_list, width) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[500]),
                  color: Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                width: width * 0.285,
                height: 50,
                child: Column(
                  children: [
                    Text('उम्र',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${_list['userAnimalAge']} साल',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500))
                  ],
                ),
              ),
              SizedBox(width: 5),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[500]),
                  color: Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                width: width * 0.285,
                height: 50,
                child: Column(
                  children: [
                    Text('दूध (प्रति दिन)',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${_list['userAnimalMilk']} लीटर',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500))
                  ],
                ),
              ),
              SizedBox(width: 5),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[500]),
                  color: Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                width: width * 0.285,
                height: 50,
                child: Column(
                  children: [
                    Text('ब्यात',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(bayaatMapping(_list['userAnimalPregnancy']),
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500))
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[500]),
                  color: Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                width: width * 0.425,
                height: 50,
                child: Column(
                  children: [
                    Text('कब ब्यायी थी?',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(
                        _list['extraInfo'] == null ||
                                _list['extraInfo'] == {} ||
                                _list['extraInfo']['alreadyPregnantYesNo'] ==
                                    null ||
                                _list['extraInfo']['alreadyPregnantYesNo'] ==
                                    'no'.tr
                            ? 'ब्यायी नहीं है'
                            : _list['extraInfo']['animalAlreadyGivenBirth'],
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500))
                  ],
                ),
              ),
              SizedBox(width: 5),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[500]),
                  color: Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                width: width * 0.425,
                height: 50,
                child: Column(
                  children: [
                    Text('कब से गर्भवती है ?',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(
                        _list['extraInfo'] == null ||
                                _list['extraInfo'] == {} ||
                                _list['extraInfo']['isPregnantYesNo'] == null ||
                                _list['extraInfo']['isPregnantYesNo'] == 'no'.tr
                            ? 'गर्भवती नहीं है'
                            : _list['extraInfo']['animalIfPregnant'],
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500))
                  ],
                ),
              ),
            ],
          )
        ],
      ));

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: height - AppBar().preferredSize.height - 38,
              child: PaginateFirestore(
                  // physics: NeverScrollableScrollPhysics(),
                  itemsPerPage: 10,
                  initialLoader: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: primaryColor,
                    ),
                  ),
                  bottomLoader: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: primaryColor,
                    ),
                  ),
                  emptyDisplay: Center(
                    child: Text(
                      'किसी ग्राहक को अभी तक संपर्क नहीं किया है',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  itemBuilderType:
                      PaginateBuilderType.listView, // listview and gridview
                  itemBuilder: (index, context, documentSnapshot) =>
                      documentSnapshot.data() == null
                          ? Center(
                              child: Text(
                              'किसी ग्राहक को अभी तक संपर्क नहीं किया है',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ))
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                  key: Key(documentSnapshot.data()['uniqueId']),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 5,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildInfowidget(
                                            documentSnapshot.data()),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, bottom: 5.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.grey[500],
                                                size: 13,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Text(
                                                    documentSnapshot
                                                        .data()['userAddress'],
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w200,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _animalImageWidget(
                                            documentSnapshot.data()),
                                        _extraInfoWidget(
                                            documentSnapshot.data(), width),
                                        _extraInfoWidget1(
                                            documentSnapshot.data(), width),
                                      ]))),
                  query: FirebaseFirestore.instance
                      .collection('myCallingInfo')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .collection('myCalls')
                      .orderBy('dateOfSaving', descending: true),
                  isLive: false // to fetch real-time data
                  ),
            )
          ]),
        ));
  }
}
