import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pashusansaar/my_calls/myCallsController.dart';
import 'package:pashusansaar/refresh_token/refresh_token_controller.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pashusansaar/utils/constants.dart';
import 'utils/reusable_widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class MyCalledList extends StatefulWidget {
  @override
  _MyCalledListState createState() => _MyCalledListState();
}

class _MyCalledListState extends State<MyCalledList> {
  int _current = 0;
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());
  final MyCallListController myCallListController =
      Get.put(MyCallListController());

  List myCallList = [];
  bool _isLoadingScreen = false;
  SharedPreferences prefs;

  getInitialInfo() async {
    prefs = await SharedPreferences.getInstance();
    bool status;
    setState(() {
      _isLoadingScreen = true;
    });

    try {
      if (ReusableWidgets.isTokenExpired(prefs.getInt('expires') ?? 0)) {
        status = await refreshTokenController.getRefreshToken(
            refresh: prefs.getString('refreshToken') ?? '');
        if (status) {
          setState(() {
            prefs.setString(
                'accessToken', refreshTokenController.accessToken.value);
            prefs.setString(
                'refreshToken', refreshTokenController.refreshToken.value);
            prefs.setInt('expires', refreshTokenController.expires.value);
          });
        } else {
          print('Error getting token==' + status.toString());
        }
      }
    } catch (e) {
      ReusableWidgets.showDialogBox(
        context,
        'warning'.tr,
        Text(
          'global_error'.tr,
        ),
      );
    }

    try {
      List data = await myCallListController.getCallList(
        userId: prefs.getString('userId'),
        token: prefs.getString('accessToken'),
        page: 1,
      );

      print('user id is: ${prefs.getString('userId')}');
      print('token id is: ${prefs.getString('accessToken')}');

      setState(() {
        myCallList = data;
      });
    } catch (e) {
      ReusableWidgets.showDialogBox(
        context,
        'warning'.tr,
        Text(
          'global_error'.tr,
        ),
      );
    }
    setState(() {
      _isLoadingScreen = false;
    });
  }

  Row _buildInfowidget(_list) {
    var formatter = intl.NumberFormat('#,##,000');
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: _list.userName,
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  children: [
                    TextSpan(
                      text:
                          ' ${(_list.animalType == 1 || _list.animalType == 2 || _list.animalType == 6 || _list.animalType == 8 || _list.animalType == 10) ? " की" : "का"} ',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: _list.animalBreed == 'not_known'.tr
                          ? ""
                          : _list.animalBreed,
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
                      text: _list.animalType.toString() == 'other_animal'.tr
                          ? "no type"
                          : ((_list.animalType <= 4
                              ? intToAnimalTypeMapping[_list.animalType] + ', '
                              : intToAnimalOtherTypeMapping[_list.animalType].toString()) +
                                  ', '),
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: 'age'.tr,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: ': ${_list.animalAge} ${'year'.tr}\n',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: '₹ ',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: formatter.format(
                              int.parse(_list.animalPrice.toString())) ??
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
    _list.animalId.files
        .forEach((img) => _images.addIf(img.fileName != null, img.fileName));

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
                                    : Image.network(
                                        '$i',
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace stackTrace) {
                                          return Center(
                                            child: Icon(
                                              Icons.error,
                                              size: 60,
                                            ),
                                          );
                                        },
                                      );
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    _images[0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent loadingProgress,
                    ) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
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
                    //'time',
                    "${ReusableWidgets.dateDifference(_list.updatedAt)} देखा",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  _descriptionText(animalInfo) {
    String animalBreedCheck = (animalInfo.animalBreed == 'not_known'.tr)
        ? ""
        : animalInfo.animalBreed;
    String animalTypeCheck = (animalInfo.animalType >= 5)
        ? intToAnimalOtherTypeMapping[animalInfo.animalType]
        : intToAnimalTypeMapping[animalInfo.animalType];

    String desc = '';

    if (animalInfo.animalType >= 3) {
      desc = 'animalTypeAge'.trParams({
        'animalBreed': animalBreedCheck,
        'animalTypeCheck': animalTypeCheck,
        'animalAge': animalInfo.animalAge.toString()
      });
    } else {
      desc = 'animalTypeAge'.trParams({
        'animalBreed': animalBreedCheck,
        'animalTypeCheck': animalTypeCheck,
        'animalAge': animalInfo.animalAge.toString()
      });
      if (animalInfo.recentBayatTime != null) {
        desc = desc +
            'animalRecentBayatTime'.trParams({
              'recentBayatTime':
              intToRecentBayaatTime[animalInfo.recentBayatTime],
            });
      }
      if (animalInfo.pregnantTime != null) {
        desc = desc +
            'animalPregnantTime'.trParams(
                {'pregnantTime': intToPregnantTime[animalInfo.pregnantTime]});
      }
      if (animalInfo.animalMilkCapacity != null) {
        desc = desc +
            'animalMilkCapacity'.trParams(
                {'milkCapacity': animalInfo.animalMilkCapacity.toString()});
      }
    }
    return desc + (animalInfo.moreInfo ?? "");
  }

  _extraInfoWidget(_list, width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RaisedButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: darkGreenColor)),
            color: darkGreenColor,
            onPressed: () async {
              String whatsappUrl = '';
              String whatsappText = '';

              whatsappText = 'whatsAppText'.trParams({
                'userName': _list.userName,
                'district': _list.userAddress,
              });
              whatsappUrl =
                  "https://api.whatsapp.com/send/?phone=+91 ${_list.mobile} &text=$whatsappText";
              await UrlLauncher.canLaunch(whatsappUrl) != null
                  ? UrlLauncher.launch(Uri.encodeFull(whatsappUrl))
                  : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('${_list.mobile} is not present in Whatsapp'),
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ));
            },
            icon: FaIcon(FontAwesomeIcons.whatsapp,
                color: Colors.white, size: 14),
            label: Text(
              'message'.tr,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          SizedBox(width: 5),
          RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: violetColor)),
              color: violetColor,
              onPressed: () async {
                String qParams = json.encode({
                  "uniqueId": _list.sId,
                  "userId": prefs.getString('userId'),
                  "screen": "DESCRIPTION_PAGE",
                });

                final DynamicLinkParameters parameters = DynamicLinkParameters(
                    uriPrefix: "https://pashusansaar.page.link",
                    link: Uri.parse(
                        "https://www.pashu-sansaar.com/?data=$qParams"),
                    androidParameters: AndroidParameters(
                      packageName: 'dj.pashusansaar',
                      minimumVersion: 21,
                    ),
                    dynamicLinkParametersOptions: DynamicLinkParametersOptions(
                      shortDynamicLinkPathLength:
                          ShortDynamicLinkPathLength.unguessable,
                    ),
                    navigationInfoParameters:
                        NavigationInfoParameters(forcedRedirectEnabled: true));

                final shortDynamicLink = await parameters.buildShortLink();
                final Uri shortUrl = shortDynamicLink.shortUrl;

                Share.share(_list.animalType == 1 ||
                    _list.animalType == 2
                    ? 'shareTextFemale'.trParams({
                  'animalBreed': _list.animalBreed,
                  'description': _descriptionText(_list) ??
                      'infoNotAvailable'.tr,
                  'milkCapacity':
                  _list.animalMilkCapacity.toString(),
                  'url': shortUrl.toString()
                })
                    : 'shareTextMale'.trParams({
                  'animalBreed': _list.animalBreed,
                  'description': _descriptionText(_list) ??
                      'infoNotAvailable'.tr,
                  'url': shortUrl.toString()
                }),
                    subject: 'animalInfo'.tr);

              },
              icon: Icon(Icons.share, color: Colors.white, size: 14),
              label: Text('share'.tr,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14))),
          SizedBox(width: 5),
          RaisedButton.icon(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: darkSecondaryColor)),
            color: secondaryColor,
            onPressed: () async {
              return UrlLauncher.launch('tel:+91 ${_list.mobile}');
            },
            icon: Icon(
              Icons.call,
              color: Colors.white,
              size: 14,
            ),
            label: Text(
              'call'.tr,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
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
        child: _list.animalType > 2
            ? null
            : Column(
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
                        width: width * 0.425,
                        height: 50,
                        child: Column(
                          children: [
                            Text('milkPerDay'.tr,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            _list.animalMilkCapacity == null
                                ? Text("-")
                                : Text('${_list.animalMilkCapacity} ${'litre'.tr}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500))
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
                            Text('animal_is_pregnant'.tr,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                                intToAnimalBayaatMapping[_list.animalBayat] ??
                                    "-",
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
                            Text('when_Bayat'.tr,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                              _list.isRecentBayat == false ||
                                      _list.isRecentBayat == 'no'.tr
                                  ? 'noBayat'.tr
                                  : intToRecentBayaatTime[
                                          _list.recentBayatTime] ??
                                      "-",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            )
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
                            Text('when_Pregnant'.tr,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                              _list.isPregnant == null ||
                                      _list.isPregnant == 'no'.tr ||
                                      _list.isPregnant == false
                                  ? 'noPregnant'.tr
                                  : intToPregnantTime[_list.pregnantTime] ??
                                      "-",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
      );

  @override
  void initState() {
    super.initState();
    getInitialInfo();
  }

  //<<<<<<<<<<<<<<<<<New build>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
      body: (_isLoadingScreen)
          ? Center(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white),
                  height: 100,
                  width: 100,
                  child: Center(child: CircularProgressIndicator())))
          : (myCallList == null || myCallList.isEmpty
              ? Center(
                  child: Text('notContactedYet'.tr,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
              : Container(
                  margin: EdgeInsets.all(10),
                  child: ListView.separated(
                    cacheExtent: 99,
                    itemCount: myCallList.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _buildInfowidget(myCallList[index].animalId),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 5.0),
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
                                        myCallList[index]
                                                    .animalId
                                                    .userAddress ==
                                                null
                                            ? 'addressNotAvailable'.tr
                                            : myCallList[index]
                                                .animalId
                                                .userAddress,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w200,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            _animalImageWidget(myCallList[index]),
                            _extraInfoWidget(myCallList[index].animalId, width),
                            _extraInfoWidget1(
                                myCallList[index].animalId, width),
                          ],
                        ),
                      );
                    },
                  ),
                )),
    );
  }
}
