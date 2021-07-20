import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:core';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:pashusansaar/buy_animal/buy_animal_model.dart';
import 'package:pashusansaar/refresh_token/refresh_token_controller.dart';
import 'package:pashusansaar/seller_contact/seller_contact_controller.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/constants.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geodesy/geodesy.dart';
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share/share.dart';
import 'package:pashusansaar/utils/constants.dart' as constant;
import 'package:geoflutterfire/geoflutterfire.dart' as geoFire;
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:animations/animations.dart';
import 'package:pashusansaar/utils/custom_fab.dart';

import 'animal_info_form.dart';
import 'buy_animal_controller.dart';

class BuyAnimal extends StatefulWidget {
  List<Result> animalInfo;
  final String userName;
  final String userMobileNumber;
  final String userImage;
  final double latitude, longitude;
  BuyAnimal({
    Key key,
    @required this.animalInfo,
    @required this.userName,
    @required this.userMobileNumber,
    @required this.userImage,
    @required this.latitude,
    @required this.longitude,
  }) : super(key: key);

  @override
  _BuyAnimalState createState() => _BuyAnimalState();
}

class _BuyAnimalState extends State<BuyAnimal>
    with AutomaticKeepAliveClientMixin {
  var formatter = intl.NumberFormat('#,##,000');
  final geo = geoFire.Geoflutterfire();

  int perPage = 10,
      _index = 0,
      _value,
      _valueRadius,
      _current = 0,
      _page,
      animalType,
      minMilk,
      maxMilk,
      _distance;
  Map<String, dynamic> _filterDropDownMap = {};
  ProgressDialog pr;
  double _latitude = 0.0, _longitude = 0.0, _filterLat, _filterLong;
  String _filterAnimalType,
      desc = '',
      _userLocality = '',
      whatsappText = '',
      directory = '',
      url1 = '',
      url2 = '',
      url3 = '',
      url4 = '';
  TextEditingController _locationController = TextEditingController();
  ScrollController _scrollController =
      ScrollController(keepScrollOffset: false);
  bool _isCardVisible = false;
  File fileUrl;
  final SellerContactController sellerContactController =
      Get.put(SellerContactController());
  final BuyAnimalController buyAnimalController =
      Get.put(BuyAnimalController());
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());

  static GlobalKey previewContainer =
      new GlobalKey(debugLabel: 'previewController');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _getInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getNextSetOfBuyingAnimal();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getNextSetOfBuyingAnimal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      bool status;

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

      BuyAnimalModel data = await buyAnimalController.getAnimal(
        latitude: _filterLat ?? _latitude,
        longitude: _filterLong ?? _longitude,
        animalType: animalType,
        minMilk: minMilk,
        maxMilk: maxMilk,
        distance: _distance ?? 50000,
        page: _page,
        accessToken: prefs.getString('accessToken') ?? '',
        userId: prefs.getString('userId'),
      );

      List<Result> _temp = widget.animalInfo;
      data.result.forEach((element) => _temp.add(element));

      setState(() {
        widget.animalInfo = _temp;
        // _isCardVisible = widget.animalInfo.length % 5 == 0;
        prefs.setInt('page', data.page);
      });
    } catch (e) {
      print('=-=Error-Re-Buying-=->>>' + e.toString());
    }
  }

  takeScreenShot(String uniqueId) async {
    pr.style(message: 'शेयर किया जा रहा है');
    pr.show();
    RenderRepaintBoundary boundary =
        previewContainer.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    File imgFile = new File('$directory/pashu_$uniqueId.png');
    await imgFile.writeAsBytes(pngBytes);

    setState(() {
      fileUrl = imgFile;
    });

    pr.hide();
  }

  // dataDeleteion() async {
  //   await FirebaseFirestore.instance
  //       .collection('buyingAnimalList1')
  //       .doc()
  //       .get()
  //       .then((value) => value.reference.delete());
  // }

  _getInitialData() async {
    Future.delayed(Duration(seconds: 7)).then((value) => setState(() {
          _isCardVisible = widget.animalInfo.length % 5 == 0;
        }));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userLocality = prefs.getString('district');
      _page = prefs.getInt('page') ?? 1;
      if (widget.latitude == 0.0 || widget.longitude == 0.0) {
        _latitude = prefs.getDouble('latitude');
        _longitude = prefs.getDouble('longitude');
      } else {
        _latitude = widget.latitude;
        _longitude = widget.longitude;
      }
    });
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

  getPositionBasedOnLatLong(double lat, double long) async {
    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    return first.subAdminArea ?? first.locality ?? first.featureName;
  }

  Row _buildInfowidget(int index) {
    List _list = widget.animalInfo;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: RichText(
            textAlign: TextAlign.center,
            text: _list[index].animalType == 1 || _list[index].animalType == 2
                ? TextSpan(
                    text: _list[index].animalMilk.toString(),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
                            intToAnimalBayaatMapping[_list[index].animalBayat],
                          ),
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
                          text: '₹ ' +
                                  formatter.format(_list[index].animalPrice) ??
                              0,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ])
                : TextSpan(
                    text: _list[index].animalBreed == 'not_known'.tr
                        ? ""
                        : ReusableWidgets.removeEnglishDataFromName(
                            _list[index].animalBreed),
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
                          text: _list[index].animalType == 5
                              ? intToAnimalTypeMapping[5]
                              : intToAnimalTypeMapping[_list[index].animalType],
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        TextSpan(
                          text: ', ₹ ' +
                                  formatter.format(_list[index].animalPrice) ??
                              0,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ]),
          ),
        ),
      ],
    );
  }

  _animalTypeDropDown() => StatefulBuilder(
      builder: (context, setState) => Column(children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                'animal_type'.tr,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: DropdownSearch<String>(
                mode: Mode.MENU,
                showSelectedItem: true,
                items: constant.animalType,
                label: 'animal_type'.tr,
                hint: 'animal_type'.tr,
                selectedItem: _filterAnimalType,
                onChanged: (String type) {
                  setState(() {
                    _filterAnimalType = type;
                    _filterDropDownMap['filter1'] = type;
                  });
                },
                dropdownSearchDecoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
              ),
            )
          ]));

  _animalMilkSilder() => StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            Text("Milk Quantity"),
            Wrap(
                children: filterMilkValue
                    .map((e) => Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ChoiceChip(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: appPrimaryColor),
                            label: Text(
                              e,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _value == filterMilkValue.indexOf(e)
                                      ? Colors.white
                                      : appPrimaryColor),
                            ),
                            selectedColor: appPrimaryColor,
                            selected: _value == filterMilkValue.indexOf(e),
                            onSelected: (bool selected) {
                              setState(() {
                                _value = selected
                                    ? filterMilkValue.indexOf(e)
                                    : null;

                                _filterDropDownMap['filter2'] = _value;
                                if (!selected) {
                                  _filterDropDownMap.remove('filter2');
                                }
                              });
                            },
                          ),
                        ))
                    .toList()),
          ],
        ),
      );

  _radiusLocation() => StatefulBuilder(
        builder: (context, setState1) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8),
              child: Text("कितनी दुरी तक के पशु दिखाए"),
            ),
            Wrap(
                children: radius
                    .map((e) => Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ChoiceChip(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: appPrimaryColor),
                            label: Text(
                              e,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _valueRadius == radius.indexOf(e)
                                      ? Colors.white
                                      : appPrimaryColor),
                            ),
                            selectedColor: appPrimaryColor,
                            selected: _valueRadius == radius.indexOf(e),
                            onSelected: (bool selected) {
                              setState1(() {
                                _valueRadius =
                                    selected ? radius.indexOf(e) : null;
                              });
                            },
                          ),
                        ))
                    .toList()),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    pr.style(message: 'progress_dialog_message'.tr);

    return SafeArea(
      child: RepaintBoundary(
        key: previewContainer,
        child: Scaffold(
          backgroundColor: Colors.grey[100],
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: AnimatedOpacity(
            opacity: !_isCardVisible ? 1.0 : 0.0,
            duration: Duration(seconds: 3),
            child: CustomFABWidget(
              userMobileNumber: widget.userMobileNumber,
              userName: widget.userName,
            ),
          ),
          body: Stack(
            children: [
              widget.animalInfo == null || widget.animalInfo.length == 0
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                          'जानकारी उपलब्ध नहीं है| कोई और चुनाव करके कोशिश करे |',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          )),
                    ))
                  : Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ListView.builder(
                            key: ObjectKey(widget.animalInfo[0]),
                            padding: EdgeInsets.only(bottom: 60),
                            controller: _scrollController,
                            physics: BouncingScrollPhysics(),
                            itemCount: _page == null
                                ? widget.animalInfo.length
                                : widget.animalInfo.length + 1,
                            itemBuilder: (context, index) {
                              if (index >= widget.animalInfo.length) {
                                return Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ],
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8, top: 8),
                                child: Card(
                                  key: Key(index.toString()),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfowidget(index),
                                      _distanceTimeMethod(index),
                                      _animalImageWidget(index),
                                      _animalDescriptionMethod(index),
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 1.0,
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          height: 80,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(children: [
                                              Image.asset(
                                                  'assets/images/profile.jpg',
                                                  width: 40,
                                                  height: 40),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  widget.animalInfo[index]
                                                      .userName  ?? "",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              RaisedButton.icon(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                    side: BorderSide(
                                                        color:
                                                            darkSecondaryColor)),
                                                color: secondaryColor,
                                                onPressed: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  var addresses = await Geocoder
                                                      .local
                                                      .findAddressesFromCoordinates(
                                                          Coordinates(
                                                              prefs.getDouble(
                                                                  'latitude'),
                                                              prefs.getDouble(
                                                                  'longitude')));
                                                  var first = addresses.first;

                                                  int
                                                      myNum =
                                                      await sellerContactController
                                                          .getSellerContact(
                                                              animalId: widget
                                                                  .animalInfo[
                                                                      index]
                                                                  .sId,
                                                              userId: prefs
                                                                  .getString(
                                                                      'userId'),
                                                              token: prefs
                                                                  .getString(
                                                                      'accessToken'),
                                                              channel: [
                                                        {
                                                          "contactMedium":
                                                              "Call"
                                                        }
                                                      ]);

                                                  print(
                                                      'userId is ${prefs.getString('userId')}');
                                                  print(
                                                      'token is ${prefs.getString('accessToken')}');

                                                  return UrlLauncher.launch(
                                                      'tel:+91 $myNum');
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              RaisedButton.icon(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                    side: BorderSide(
                                                        color: darkGreenColor)),
                                                color: darkGreenColor,
                                                onPressed: () async {
                                                  String whatsappUrl = '';
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  var addresses = await Geocoder
                                                      .local
                                                      .findAddressesFromCoordinates(
                                                          Coordinates(
                                                              prefs.getDouble(
                                                                  'latitude'),
                                                              prefs.getDouble(
                                                                  'longitude')));
                                                  var first = addresses.first;

                                                  int
                                                      myNum =
                                                      await sellerContactController
                                                          .getSellerContact(
                                                              animalId: widget
                                                                  .animalInfo[
                                                                      index]
                                                                  .sId,
                                                              userId: prefs
                                                                  .getString(
                                                                      'userId'),
                                                              token: prefs
                                                                  .getString(
                                                                      'accessToken'),
                                                              channel: [
                                                        {
                                                          "contactMedium":
                                                              "Whatsapp"
                                                        }
                                                      ]);

                                                  whatsappText =
                                                      'नमस्कार भाई साहब, मैंने आपका पशु देखा पशुसंसार पे और आपसे आगे बात करना चाहता हूँ. कब बात कर सकते हैं? ${widget.userName}, ${prefs.getString('district')} \n\nपशुसंसार सूचना - ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन  एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है';
                                                  whatsappUrl =
                                                      "https://api.whatsapp.com/send/?phone=+91 $myNum &text=$whatsappText";
                                                  await UrlLauncher.canLaunch(
                                                              whatsappUrl) !=
                                                          null
                                                      ? UrlLauncher.launch(
                                                          Uri.encodeFull(
                                                              whatsappUrl))
                                                      : ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                          content: Text(
                                                              '$myNum is not present in Whatsapp'),
                                                          duration: Duration(
                                                              milliseconds:
                                                                  300),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                        ));
                                                },
                                                icon: FaIcon(
                                                    FontAwesomeIcons.whatsapp,
                                                    color: Colors.white,
                                                    size: 14),
                                                label: Text(
                                                  'message'.tr,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              opacity: _isCardVisible ? 1.0 : 0.0,
                              duration: Duration(seconds: 3),
                              child: Visibility(
                                visible: _isCardVisible,
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: OpenContainer(
                                    closedElevation: 0,
                                    transitionDuration: Duration(seconds: 2),
                                    openBuilder: (context, _) => AnimalInfoForm(
                                      userMobileNumber: widget.userMobileNumber,
                                      userName: widget.userName,
                                    ),
                                    closedShape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    closedColor: Theme.of(context).primaryColor,
                                    closedBuilder: (context, openContainer) =>
                                        Container(
                                      height: 220,
                                      width: 150,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: RawMaterialButton(
                                                  onPressed: () => setState(() {
                                                    _isCardVisible = false;
                                                  }),
                                                  elevation: 2.0,
                                                  fillColor: Colors.white,
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 20.0,
                                                    color: appPrimaryColor,
                                                  ),
                                                  shape: CircleBorder(),
                                                  constraints: BoxConstraints(
                                                      minWidth: 30,
                                                      minHeight: 30),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text(
                                                  'कौन सा पशु खरीदना चाहते है ?',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 22,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: double.infinity,
                                                  child: RaisedButton(
                                                    shape: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    color: Colors.white,
                                                    onPressed: null,
                                                    disabledColor: Colors.white,
                                                    disabledTextColor:
                                                        appPrimaryColor,
                                                    child: Row(
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios_sharp,
                                                            color:
                                                                appPrimaryColor,
                                                          ),
                                                          Text(
                                                            'हमें बताये',
                                                            style: TextStyle(
                                                              color:
                                                                  appPrimaryColor,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ]),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: Text("जगह बदले"),
                                  content: StatefulBuilder(
                                      builder: (context, setState) {
                                    return Container(
                                      height: 200,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            TextField(
                                              maxLength: 6,
                                              controller: _locationController,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                counterText: '',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                icon: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  width: 10,
                                                  height: 10,
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                hintText: "ज़िपकोड डाले",
                                                contentPadding: EdgeInsets.only(
                                                    left: 8.0, top: 16.0),
                                              ),
                                            ),
                                            _radiusLocation()
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text(
                                          'Ok'.tr,
                                          style:
                                              TextStyle(color: appPrimaryColor),
                                        ),
                                        onPressed: () async {
                                          if (_locationController.text.length ==
                                              0)
                                            ReusableWidgets.showDialogBox(
                                                context,
                                                'error'.tr,
                                                Text(
                                                    'error_length_zipcode'.tr));
                                          else {
                                            if (_locationController
                                                    .text.length <
                                                6)
                                              ReusableWidgets.showDialogBox(
                                                  context,
                                                  'error'.tr,
                                                  Text('error_length_zipcode'
                                                      .tr));
                                            else {
                                              try {
                                                var address = await Geocoder
                                                    .local
                                                    .findAddressesFromQuery(
                                                        _locationController
                                                            .text);

                                                var first = address.first;
                                                setState(() {
                                                  _userLocality =
                                                      first.subAdminArea ??
                                                          first.locality ??
                                                          first.featureName;
                                                  _filterLat = first
                                                      .coordinates.latitude;
                                                  _filterLong = first
                                                      .coordinates.longitude;
                                                });
                                                _getLocationBasedList(
                                                    context, first);
                                              } catch (e) {
                                                print('locationerro==> ' +
                                                    e.toString());
                                                Navigator.of(context).pop();
                                                Flushbar(
                                                  message:
                                                      "no_animal_present".tr,
                                                  duration:
                                                      Duration(seconds: 2),
                                                )..show(context);
                                              }
                                            }
                                          }
                                        }),
                                  ]);
                            });
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[400])),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7.0),
                          child: Center(
                              child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Icon(Icons.location_on,
                                      size: 14, color: Colors.black),
                                ),
                                TextSpan(
                                    text: " $_userLocality",
                                    style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          )),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                              child: _filterBottomSheet(), height: 250),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          )).then((value) => setState(() {})),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[400])),
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7.0),
                          child: Center(
                              child: RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: FaIcon(FontAwesomeIcons.dog,
                                      size: 14, color: Colors.black),
                                ),
                                TextSpan(
                                    text: " " + "animal_filter".tr + "  ",
                                    style: TextStyle(color: Colors.black)),
                                WidgetSpan(
                                  child: CircleAvatar(
                                    backgroundColor: appPrimaryColor,
                                    radius: 10,
                                    child: Center(
                                      child: Text(
                                          _filterDropDownMap == null ||
                                                  _filterDropDownMap == {}
                                              ? '0'
                                              : _filterDropDownMap.length
                                                  .toString(),
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
                        ),
                        // color: Colors.grey[100],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getLocationBasedList(BuildContext context, Address first) async {
    int _radiusData = _valueRadius == 0
        ? 25
        : _valueRadius == 1
            ? 50
            : _valueRadius == 2
                ? 75
                : _valueRadius == 3
                    ? 75
                    : 50;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool status;
      pr.show();

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
          ReusableWidgets.showDialogBox(
              context, 'warning'.tr, Text('Error getting token'));
        }
      }

      BuyAnimalModel data = await buyAnimalController.getAnimal(
        latitude: _filterLat,
        longitude: _filterLong,
        distance: _radiusData * 1000,
        animalType: animalType,
        minMilk: minMilk,
        maxMilk: maxMilk,
        page: 1,
        accessToken: prefs.getString('accessToken') ?? '',
        userId: prefs.getString('userId') ?? '',
      );

      setState(() {
        widget.animalInfo = data.result;
        prefs.setInt('page', data.page);
        _distance = _radiusData * 1000;
      });

      pr.hide();
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      print('=-=Error-=->>>' + e.toString());
    }
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
      desc =
      'ये $animalBreedCheck $animalTypeCheck ${animalInfo.animalAge} साल ${(animalInfo.animalType == 6 || animalInfo.animalType == 8 || animalInfo.animalType == 10) ? " की" : "का"} है। ';
    } else {
      desc =
      'ये $animalBreedCheck $animalTypeCheck ${animalInfo.animalAge} साल की है। ';
      if (animalInfo.recentBayatTime != null) {
        desc = desc +
            'यह ${intToRecentBayaatTime[animalInfo.recentBayatTime]} ब्यायी है। ';
      }
      if (animalInfo.pregnantTime != null) {
        desc =
            desc + 'यह अभी ${intToPregnantTime[animalInfo.pregnantTime]} है। ';
      }
      if (animalInfo.animalMilkCapacity != null) {
        desc = desc +
            'पिछले बार के हिसाब से दूध कैपेसिटी ${animalInfo.animalMilkCapacity} लीटर है। ';
      }
    }
    return desc + (animalInfo.moreInfo ?? "");
  }

  Padding _animalDescriptionMethod(int index) {
    List _list = widget.animalInfo;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        // "description to be added",
        _descriptionText(_list[index]),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 14.5),
      ),
    );
  }

  Padding _animalImageWidget(int index) {
    List _list = widget.animalInfo;

    // List<String> _images = ['assets/images/AppIcon.jpg'];
    List<String> _images = [];
    _list[index]
        .files
        .forEach((elem) => _images.addIf(elem.fileName != null, elem.fileName));

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
                          autoPlayInterval: Duration(seconds: 4),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, reason) => setState(() {
                            _current = index;
                          }),
                        ),
                        items: _images.map((i) {
                          return InteractiveViewer(
                            boundaryMargin: const EdgeInsets.all(20.0),
                            minScale: 0.1,
                            maxScale: 1.6,
                            child:
                                // Image.asset('$i')
                                Image.network(
                              '$i',
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                            ),
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
                  // image:
                  // AssetImage(_images[0]),
                  image: NetworkImage(_images[0]),
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: Colors.redAccent,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: violetColor)),
                color: violetColor,
                onPressed: () async {
                  String qParams = json.encode({
                    "uniqueId": _list[index].sId,
                    "userId": _list[index].userId,
                    "screen": "DESCRIPTION_PAGE",
                  });

                  final DynamicLinkParameters parameters =
                      DynamicLinkParameters(
                          uriPrefix: "https://pashusansaar.page.link",
                          link: Uri.parse(
                              "https://www.pashu-sansaar.com/?data=$qParams"),
                          androidParameters: AndroidParameters(
                            packageName: 'dj.pashusansaar',
                            minimumVersion: 21,
                          ),
                          dynamicLinkParametersOptions:
                              DynamicLinkParametersOptions(
                            shortDynamicLinkPathLength:
                                ShortDynamicLinkPathLength.unguessable,
                          ),
                          navigationInfoParameters: NavigationInfoParameters(
                              forcedRedirectEnabled: true));

                  final shortDynamicLink = await parameters.buildShortLink();
                  final Uri shortUrl = shortDynamicLink.shortUrl;

                  // await takeScreenShot(_list[index]['uniqueId']);

                  // Share.share(
                  //     "नस्ल: ${_list[index].animalBreed}\nजानकारी: description\nदूध(प्रति दिन): ${_list[index].animalMilk} Litre\n\nऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar}",
                  //     subject: 'animal_info'.tr);

                  // Share.shareFiles([fileUrl.path],
                  //     mimeTypes: ['images/png'],
                  //     text:
                  //         // "नस्ल: ${_list[index]['userAnimalBreed']}\nजानकारी: ${_list[index]['userAnimalDescription']}\nदूध(प्रति दिन): ${_list[index]['userAnimalMilk']} Litre\n\nऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar}",
                  //         "नस्ल: ${_list[index]['userAnimalBreed']}\nजानकारी: ${_list[index]['userAnimalDescription']}\nदूध(प्रति दिन): ${_list[index]['userAnimalMilk']} Litre\n\nपशु देखे: ${shortUrl.toString()}",
                  //     subject: 'पशु की जानकारी');

                  Share.share(shortUrl.toString());
                },
                icon: Icon(Icons.share, color: Colors.white, size: 14),
                label: Text('share'.tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14))),
          )
        ],
      ),
    );
  }

  _distanceTimeMethod(int index) {
    String val = '';
    List _list = widget.animalInfo;

    return StatefulBuilder(builder: (context, setState1) {
      getPositionBasedOnLatLong(_list[index].latitude, _list[index].longitude)
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
                      ReusableWidgets.dateDifference(_list[index].createdAt),
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
                    text: _distanceBetweenTwoCoordinates(
                            _list[index].latitude, _list[index].longitude) +
                        ' ' +
                        'km'.tr,
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

  String _distanceBetweenTwoCoordinates(double lat, double long) {
    return (Geodesy().distanceBetweenTwoGeoPoints(
              LatLng(_filterLat ?? _latitude, _filterLong ?? _longitude),
              LatLng(lat, long),
            ) /
            1000)
        .toStringAsFixed(0);
  }

  _filterBottomSheet() {
    return StatefulBuilder(
        builder: (context, setState) => Row(
              children: [
                Column(
                  children: [
                    GestureDetector(
                        onTap: () => setState(() => _index = 0),
                        child: Container(
                          width: 120,
                          height: 125,
                          color: _index == 0 ? appPrimaryColor : Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Text('animal_type'.tr,
                                    style: _index == 0
                                        ? TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)
                                        : TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                              ),
                              Center(
                                child: Text(
                                    _filterDropDownMap['filter1'] == null
                                        ? " "
                                        : "\u2022 " +
                                            ' ' +
                                            _filterDropDownMap['filter1'],
                                    style: _index == 0
                                        ? TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)
                                        : TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          )),
                              ),
                            ],
                          ),
                        )),
                    Center(
                      child: SizedBox(width: 1),
                    ),
                    GestureDetector(
                        onTap: () => setState(() => _index = 1),
                        child: Container(
                            width: 120,
                            height: 125,
                            color: _index == 1 ? appPrimaryColor : Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Text('animal_milk_per_day'.tr,
                                      style: _index == 1
                                          ? TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)
                                          : TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            )),
                                ),
                                Center(
                                  child: Text(
                                      _filterDropDownMap['filter2'] == null
                                          ? " "
                                          : "\u2022 " +
                                                  ' ' +
                                                  filterMilkValue.elementAt(
                                                      _filterDropDownMap[
                                                          'filter2']) ??
                                              '',
                                      style: _index == 1
                                          ? TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)
                                          : TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            )),
                                ),
                              ],
                            )

                            // Center(
                            //   child: Text('animal_milk_per_day'.tr,
                            //       style: _index == 1
                            //           ? TextStyle(
                            //               fontSize: 15,
                            //               fontWeight: FontWeight.bold,
                            //               color: Colors.white)
                            //           : TextStyle(
                            //               fontSize: 15,
                            //               fontWeight: FontWeight.w500,
                            //             )),
                            // ),
                            )),
                  ],
                ),
                SizedBox(
                  width: 3,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Visibility(
                          visible: _index == 0,
                          child: _animalTypeDropDown(),
                          replacement: _animalMilkSilder(),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RaisedButton(
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  bool status;
                                  pr.show();

                                  if (ReusableWidgets.isTokenExpired(
                                      prefs.getInt('expires') ?? 0)) {
                                    status = await refreshTokenController
                                        .getRefreshToken(
                                            refresh: prefs.getString(
                                                    'refreshToken') ??
                                                '');
                                    if (status) {
                                      setState(() {
                                        prefs.setString(
                                            'accessToken',
                                            refreshTokenController
                                                .accessToken.value);
                                        prefs.setString(
                                            'refreshToken',
                                            refreshTokenController
                                                .refreshToken.value);
                                        prefs.setInt(
                                            'expires',
                                            refreshTokenController
                                                .expires.value);
                                      });
                                    } else {
                                      ReusableWidgets.showDialogBox(
                                          context,
                                          'warning'.tr,
                                          Text('Error getting token'));
                                    }
                                  }

                                  BuyAnimalModel data =
                                      await buyAnimalController.getAnimal(
                                    latitude: _latitude,
                                    longitude: _longitude,
                                    animalType: null,
                                    minMilk: null,
                                    maxMilk: null,
                                    page: 1,
                                    accessToken:
                                        prefs.getString('accessToken') ?? '',
                                    userId: prefs.getString('userId'),
                                  );

                                  setState(() {
                                    _filterDropDownMap.remove('filter1');
                                    _filterDropDownMap.remove('filter2');
                                    _value = _filterAnimalType =
                                        animalType = minMilk = maxMilk = null;
                                    widget.animalInfo = data.result;
                                    prefs.setInt('page', data.page);
                                  });

                                  pr.hide().then(
                                        (value) => Navigator.of(context).pop(),
                                      );
                                },
                                child: Text(
                                  'कैंसिल',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              RaisedButton(
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    pr.show();
                                    int _minMilk, _maxMilk;
                                    List<String> _getMinMaxMilk = [];
                                    bool status;
                                    if (_filterDropDownMap
                                        .containsKey('filter2')) {
                                      if (_filterDropDownMap['filter2'] == 3) {
                                        _getMinMaxMilk = filterMilkValue[
                                                _filterDropDownMap['filter2']]
                                            .split(' ');
                                        _minMilk = 21;
                                        _maxMilk = 70;
                                      } else {
                                        _getMinMaxMilk = filterMilkValue[
                                                _filterDropDownMap['filter2']]
                                            .split('-');
                                        _minMilk = int.parse(_getMinMaxMilk[0]);
                                        _maxMilk = int.parse(
                                            _getMinMaxMilk[1].split(' ')[0]);
                                      }
                                    }

                                    if (ReusableWidgets.isTokenExpired(
                                        prefs.getInt('expires') ?? 0)) {
                                      status = await refreshTokenController
                                          .getRefreshToken(
                                              refresh: prefs.getString(
                                                      'refreshToken') ??
                                                  '');
                                      if (status) {
                                        setState(() {
                                          prefs.setString(
                                              'accessToken',
                                              refreshTokenController
                                                  .accessToken.value);
                                          prefs.setString(
                                              'refreshToken',
                                              refreshTokenController
                                                  .refreshToken.value);
                                          prefs.setInt(
                                              'expires',
                                              refreshTokenController
                                                  .expires.value);
                                        });
                                      } else {
                                        ReusableWidgets.showDialogBox(
                                            context,
                                            'warning'.tr,
                                            Text('Error getting token'));
                                      }
                                    }

                                    BuyAnimalModel data =
                                        await buyAnimalController.getAnimal(
                                      latitude: _filterLat ?? _latitude,
                                      longitude: _filterLong ?? _longitude,
                                      distance: _distance ?? 50000,
                                      animalType: animalTypeMapping[
                                          _filterDropDownMap['filter1']],
                                      minMilk: minMilk,
                                      maxMilk: maxMilk,
                                      page: 1,
                                      accessToken:
                                          prefs.getString('accessToken') ?? '',
                                      userId: prefs.getString('userId'),
                                    );

                                    setState(() {
                                      widget.animalInfo = data.result;
                                      prefs.setInt('page', data.page);
                                      minMilk = _minMilk;
                                      maxMilk = _maxMilk;
                                      animalType = animalTypeMapping[
                                          _filterDropDownMap['filter1']];
                                    });
                                    pr.hide().then(
                                          (value) =>
                                              Navigator.of(context).pop(),
                                        );
                                  },
                                  child: Text('ओके',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ));
  }
}
