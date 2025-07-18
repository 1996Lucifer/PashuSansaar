import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:core';
import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/constants.dart';
import 'package:pashusansaar/utils/custom_fab_button.dart';
import 'package:pashusansaar/utils/global.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geodesy/geodesy.dart';
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share/share.dart';
import 'package:pashusansaar/utils/constants.dart' as constant;
import 'package:geoflutterfire/geoflutterfire.dart' as geoFire;
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import 'animal_info_form.dart';

class BuyAnimal extends StatefulWidget {
  List animalInfo;
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
  int _index = 0, _value, _valueRadius;
  int perPage = 10;
  final geo = geoFire.Geoflutterfire();

  int _current = 0;
  Map<String, dynamic> _filterDropDownMap = {};
  ProgressDialog pr;
  double _latitude = 0.0, _longitude = 0.0;
  String _filterAnimalType;
  List _infoList = [];
  List _tempAnimalList = [], _resetFilterData = [];
  String desc = '';
  String _userLocality = '';
  TextEditingController _locationController = TextEditingController();
  String whatsappText = '';
  ScrollController _scrollController =
      ScrollController(keepScrollOffset: false);
  String directory = '';
  String url1 = '', url2 = '', url3 = '', url4 = '';
  bool _isLoading = false, _isVisible = false, _isCardVisible = false;

  File fileUrl;

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
        if (lastDocument.isNotEmpty) _getNextSetOfBuyingAnimal();
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
    try {
      setState(() {
        _isLoading = true;
      });
      FirebaseFirestore.instance
          .collection('buyingAnimalList1')
          .orderBy('dateOfSaving', descending: true)
          .where('dateOfSaving', isLessThan: lastDocument)
          .where('district', whereIn: districtList)
          .where('isValidUser', isEqualTo: 'Approved')
          .limit(25)
          .get()
          .then((value) {
        List _temp =
            _tempAnimalList.isEmpty ? widget.animalInfo : _tempAnimalList;
        value.docs.forEach((e) {
          _temp.add(e);
        });

        setState(() {
          lastDocument = value.docs.last['dateOfSaving'];
          _isLoading = false;
          if (_tempAnimalList.isEmpty) {
            widget.animalInfo = _temp;
            widget.animalInfo
                .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
            _isCardVisible = widget.animalInfo.length % 5 == 0;
            _isVisible = false;
          } else {
            _tempAnimalList = _temp;
            _tempAnimalList
                .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
          }
        });

        print("=-=-=" + value.docs.length.toString());
      });
    } catch (e) {
      print('=-=Error-Re-Buying-=->>>' + e.toString());
      FirebaseFirestore.instance
          .collection('logger')
          .doc(widget.userMobileNumber)
          .collection('home-re-buying')
          .doc()
          .set({
        'issue': e.toString(),
        'userId': FirebaseAuth.instance.currentUser == null
            ? ''
            : FirebaseAuth.instance.currentUser.uid,
        'date': intl.DateFormat().add_yMMMd().add_jm().format(DateTime.now()),
      });
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future.delayed(Duration(seconds: 7)).then((value) => setState(() {
          _isCardVisible = widget.animalInfo.length % 5 == 0;
        }));
    setState(() {
      // _isCardVisible = widget.animalInfo.length % 5 == 0;

      if (widget.latitude == 0.0 || widget.longitude == 0.0) {
        _latitude = prefs.getDouble('latitude');
        _longitude = prefs.getDouble('longitude');
      } else {
        _latitude = widget.latitude;
        _longitude = widget.longitude;
      }
    });
    getLatLong();
  }

  getLatLong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final coordinates = new Coordinates(_latitude, _longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    setState(() {
      _userLocality = ReusableWidgets.mappingDistrict(
          first.subAdminArea ?? first.locality ?? first.featureName);
      prefs.setString('place', _userLocality);
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
    List _list =
        _tempAnimalList.length != 0 ? _tempAnimalList : widget.animalInfo;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: RichText(
            textAlign: TextAlign.center,
            text:
                (constant.animalType.indexOf(_list[index]['userAnimalType']) ==
                            0 ||
                        constant.animalType
                                .indexOf(_list[index]['userAnimalType']) ==
                            1)
                    ? TextSpan(
                        text: _list[index]['userAnimalMilk'],
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
                                  _list[index]['userAnimalPregnancy']),
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
                                      formatter.format(int.parse(
                                          _list[index]['userAnimalPrice'])) ??
                                  0,
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ])
                    : TextSpan(
                        text: _list[index]['userAnimalBreed'] == 'not_known'.tr
                            ? ""
                            : ReusableWidgets.removeEnglisgDataFromName(
                                _list[index]['userAnimalBreed']),
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
                              text: _list[index]['userAnimalType'] ==
                                      'other_animal'.tr
                                  ? _list[index]['userAnimalTypeOther']
                                  : _list[index]['userAnimalType'],
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            TextSpan(
                              text: ', ₹ ' +
                                      formatter.format(int.parse(
                                          _list[index]['userAnimalPrice'])) ??
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
                            side: BorderSide(color: primaryColor),
                            label: Text(
                              e,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _value == filterMilkValue.indexOf(e)
                                      ? Colors.white
                                      : primaryColor),
                            ),
                            selectedColor: primaryColor,
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
                            side: BorderSide(color: primaryColor),
                            label: Text(
                              e,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _valueRadius == radius.indexOf(e)
                                      ? Colors.white
                                      : primaryColor),
                            ),
                            selectedColor: primaryColor,
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
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: AnimatedOpacity(
            opacity: !_isCardVisible ? 1.0 : 0.0,
            duration: Duration(seconds: 3),
            child: CustomFABWidget(
              userMobileNumber: widget.userMobileNumber,
              userName: widget.userName,
            ),
          ),
          backgroundColor: Colors.grey[100],
          body: Stack(
            children: [
              _tempAnimalList.length == 0 && widget.animalInfo.length == 0
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
                      child: _tempAnimalList.length != 0
                          ? Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                ListView.builder(
                                    key: ObjectKey(_tempAnimalList[0]),
                                    padding: EdgeInsets.only(bottom: 60),
                                    controller: _scrollController,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (context, index) => Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, right: 8, top: 8),
                                          child: Column(
                                            children: [
                                              Card(
                                                key: Key(index.toString()),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                elevation: 5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildInfowidget(index),
                                                    _distanceTimeMethod(index),
                                                    _animalImageWidget(index),
                                                    _animalDescriptionMethod(
                                                        index),
                                                    Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[100],
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.grey,
                                                              blurRadius: 1.0,
                                                            ),
                                                          ],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        height: 80,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            widget.userImage ==
                                                                        null ||
                                                                    widget.userImage ==
                                                                        ""
                                                                ? Image.asset(
                                                                    'assets/images/profile.jpg',
                                                                    width: 40,
                                                                    height: 40)
                                                                : Image.memory(
                                                                    base64Decode(
                                                                        widget
                                                                            .userImage),
                                                                    width: 40,
                                                                    height: 40),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                _tempAnimalList[
                                                                        index][
                                                                    'userName'],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
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
                                                                color:
                                                                    secondaryColor,
                                                                onPressed:
                                                                    () async {
                                                                  SharedPreferences
                                                                      prefs =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  var addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(
                                                                      prefs.getDouble(
                                                                          'latitude'),
                                                                      prefs.getDouble(
                                                                          'longitude')));
                                                                  var first =
                                                                      addresses
                                                                          .first;

                                                                  callingInfo[
                                                                          'userIdCurrent'] =
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid;
                                                                  callingInfo[
                                                                      'userIdOther'] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userId'];
                                                                  callingInfo[
                                                                      'otherListId'] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'uniqueId'];
                                                                  callingInfo[
                                                                          'channel'] =
                                                                      "call";
                                                                  callingInfo[
                                                                      'userAddress'] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userAddress'];
                                                                  callingInfo[
                                                                      "userAnimalDescription"] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userAnimalDescription'];
                                                                  callingInfo[
                                                                          "userAnimalType"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalType'] ??
                                                                          "";
                                                                  callingInfo[
                                                                          "userAnimalTypeOther"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalTypeOther'] ??
                                                                          "";
                                                                  callingInfo[
                                                                          "userAnimalAge"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalAge'] ??
                                                                          "";
                                                                  callingInfo[
                                                                      "userAddress"] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userAddress'];
                                                                  callingInfo[
                                                                      "userName"] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userName'];
                                                                  callingInfo[
                                                                          "userAnimalPrice"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalPrice'] ??
                                                                          "0";
                                                                  callingInfo[
                                                                          "userAnimalBreed"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalBreed'] ??
                                                                          "";
                                                                  callingInfo[
                                                                      "userMobileNumber"] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userMobileNumber'];
                                                                  callingInfo[
                                                                          "userAnimalMilk"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalMilk'] ??
                                                                          "";
                                                                  callingInfo[
                                                                          "userAnimalPregnancy"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalPregnancy'] ??
                                                                          "";
                                                                  callingInfo[
                                                                      "image1"] = _tempAnimalList[index] ==
                                                                              null ||
                                                                          _tempAnimalList[index]['image1'] ==
                                                                              ""
                                                                      ? ""
                                                                      : _tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'image1'];
                                                                  callingInfo[
                                                                      "image2"] = _tempAnimalList[index]['image2'] ==
                                                                              null ||
                                                                          _tempAnimalList[index]['image2'] ==
                                                                              ""
                                                                      ? ""
                                                                      : _tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'image2'];
                                                                  callingInfo[
                                                                      "image3"] = _tempAnimalList[index]['image3'] ==
                                                                              null ||
                                                                          _tempAnimalList[index]['image3'] ==
                                                                              ""
                                                                      ? ""
                                                                      : _tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'image3'];
                                                                  callingInfo[
                                                                      "image4"] = _tempAnimalList[index]['image4'] ==
                                                                              null ||
                                                                          _tempAnimalList[index]['image4'] ==
                                                                              ""
                                                                      ? ""
                                                                      : _tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'image4'];
                                                                  callingInfo[
                                                                          "dateOfSaving"] =
                                                                      ReusableWidgets
                                                                          .dateTimeToEpoch(
                                                                              DateTime.now());
                                                                  callingInfo[
                                                                      'isValidUser'] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'isValidUser'];
                                                                  callingInfo[
                                                                          'extraInfo'] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'extraInfo'] ??
                                                                          {};

                                                                  if (_tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'userId'] !=
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid) {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "callingInfo")
                                                                        .doc(callingInfo[
                                                                            'otherListId'])
                                                                        .collection(
                                                                            'interestedBuyers')
                                                                        .doc(FirebaseAuth
                                                                            .instance
                                                                            .currentUser
                                                                            .uid)
                                                                        .set({
                                                                      'userName':
                                                                          widget
                                                                              .userName,
                                                                      'userMobileNumber':
                                                                          widget
                                                                              .userMobileNumber,
                                                                      "userAddress": first
                                                                              .addressLine ??
                                                                          (first.adminArea +
                                                                              ' ' +
                                                                              first.postalCode +
                                                                              ', ' +
                                                                              first.countryName),
                                                                      'userIdCurrent': FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid,
                                                                      'userIdOther':
                                                                          _tempAnimalList[index]
                                                                              [
                                                                              'userId'],
                                                                      'otherListId':
                                                                          _tempAnimalList[index]
                                                                              [
                                                                              'uniqueId'],
                                                                      'channel':
                                                                          "call",
                                                                      "dateOfSaving":
                                                                          ReusableWidgets.dateTimeToEpoch(
                                                                              DateTime.now())
                                                                    }, SetOptions(merge: true));

                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "myCallingInfo")
                                                                        .doc(FirebaseAuth
                                                                            .instance
                                                                            .currentUser
                                                                            .uid)
                                                                        .collection(
                                                                            'myCalls')
                                                                        .doc(callingInfo[
                                                                            'otherListId'])
                                                                        .set(
                                                                            callingInfo,
                                                                            SetOptions(merge: true));
                                                                  }

                                                                  return UrlLauncher
                                                                      .launch(
                                                                          'tel:+91 ${_tempAnimalList[index]['userMobileNumber']}');
                                                                },
                                                                icon: Icon(
                                                                  Icons.call,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 14,
                                                                ),
                                                                label: Text(
                                                                    'call'.tr,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14))),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            RaisedButton.icon(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            18.0),
                                                                    side: BorderSide(
                                                                        color:
                                                                            darkGreenColor)),
                                                                color:
                                                                    darkGreenColor,
                                                                onPressed:
                                                                    () async {
                                                                  SharedPreferences
                                                                      prefs =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  var addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(
                                                                      prefs.getDouble(
                                                                          'latitude'),
                                                                      prefs.getDouble(
                                                                          'longitude')));
                                                                  var first =
                                                                      addresses
                                                                          .first;
                                                                  String
                                                                      whatsappUrl =
                                                                      '';
                                                                  callingInfo[
                                                                          'userIdCurrent'] =
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid;
                                                                  callingInfo[
                                                                      'userIdOther'] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userId'];
                                                                  callingInfo[
                                                                      'otherListId'] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'uniqueId'];
                                                                  callingInfo[
                                                                          'channel'] =
                                                                      "whatsapp";
                                                                  callingInfo[
                                                                      'userAddress'] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userAddress'];
                                                                  callingInfo[
                                                                      "userAnimalDescription"] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userAnimalDescription'];
                                                                  callingInfo[
                                                                          "userAnimalType"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalType'] ??
                                                                          "";
                                                                  callingInfo[
                                                                          "userAnimalTypeOther"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalTypeOther'] ??
                                                                          "";
                                                                  callingInfo[
                                                                          "userAnimalAge"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalAge'] ??
                                                                          "";
                                                                  callingInfo[
                                                                      "userAddress"] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userAddress'];
                                                                  callingInfo[
                                                                      "userName"] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userName'];
                                                                  callingInfo[
                                                                          "userAnimalPrice"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalPrice'] ??
                                                                          "0";
                                                                  callingInfo[
                                                                          "userAnimalBreed"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalBreed'] ??
                                                                          "";
                                                                  callingInfo[
                                                                      "userMobileNumber"] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'userMobileNumber'];
                                                                  callingInfo[
                                                                          "userAnimalMilk"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalMilk'] ??
                                                                          "";
                                                                  callingInfo[
                                                                          "userAnimalPregnancy"] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'userAnimalPregnancy'] ??
                                                                          "";
                                                                  callingInfo[
                                                                      "image1"] = _tempAnimalList[index] ==
                                                                              null ||
                                                                          _tempAnimalList[index]['image1'] ==
                                                                              ""
                                                                      ? ""
                                                                      : _tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'image1'];
                                                                  callingInfo[
                                                                      "image2"] = _tempAnimalList[index]['image2'] ==
                                                                              null ||
                                                                          _tempAnimalList[index]['image2'] ==
                                                                              ""
                                                                      ? ""
                                                                      : _tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'image2'];
                                                                  callingInfo[
                                                                      "image3"] = _tempAnimalList[index]['image3'] ==
                                                                              null ||
                                                                          _tempAnimalList[index]['image3'] ==
                                                                              ""
                                                                      ? ""
                                                                      : _tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'image3'];
                                                                  callingInfo[
                                                                      "image4"] = _tempAnimalList[index]['image4'] ==
                                                                              null ||
                                                                          _tempAnimalList[index]['image4'] ==
                                                                              ""
                                                                      ? ""
                                                                      : _tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'image4'];
                                                                  callingInfo[
                                                                          "dateOfSaving"] =
                                                                      ReusableWidgets
                                                                          .dateTimeToEpoch(
                                                                              DateTime.now());
                                                                  callingInfo[
                                                                      'isValidUser'] = _tempAnimalList[
                                                                          index]
                                                                      [
                                                                      'isValidUser'];
                                                                  callingInfo[
                                                                          'extraInfo'] =
                                                                      _tempAnimalList[index]
                                                                              [
                                                                              'extraInfo'] ??
                                                                          {};
                                                                  if (_tempAnimalList[
                                                                              index]
                                                                          [
                                                                          'userId'] !=
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid) {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "callingInfo")
                                                                        .doc(callingInfo[
                                                                            'otherListId'])
                                                                        .collection(
                                                                            'interestedBuyers')
                                                                        .doc(FirebaseAuth
                                                                            .instance
                                                                            .currentUser
                                                                            .uid)
                                                                        .set({
                                                                      'userName':
                                                                          widget
                                                                              .userName,
                                                                      'userMobileNumber':
                                                                          widget
                                                                              .userMobileNumber,
                                                                      "userAddress": first
                                                                              .addressLine ??
                                                                          (first.adminArea +
                                                                              ' ' +
                                                                              first.postalCode +
                                                                              ', ' +
                                                                              first.countryName),
                                                                      'userIdCurrent': FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid,
                                                                      'userIdOther':
                                                                          _tempAnimalList[index]
                                                                              [
                                                                              'userId'],
                                                                      'otherListId':
                                                                          _tempAnimalList[index]
                                                                              [
                                                                              'uniqueId'],
                                                                      'channel':
                                                                          "whatsapp",
                                                                      "dateOfSaving":
                                                                          ReusableWidgets.dateTimeToEpoch(
                                                                              DateTime.now())
                                                                    }, SetOptions(merge: true));

                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "myCallingInfo")
                                                                        .doc(FirebaseAuth
                                                                            .instance
                                                                            .currentUser
                                                                            .uid)
                                                                        .collection(
                                                                            'myCalls')
                                                                        .doc(callingInfo[
                                                                            'otherListId'])
                                                                        .set(
                                                                            callingInfo,
                                                                            SetOptions(merge: true));
                                                                  }

                                                                  whatsappText =
                                                                      'नमस्कार भाई साहब, मैंने आपका पशु देखा पशुसंसार पे और आपसे आगे बात करना चाहता हूँ. कब बात कर सकते हैं? ${widget.userName}, ${prefs.getString('place')} \n\nपशुसंसार सूचना - ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन  एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है';
                                                                  whatsappUrl =
                                                                      "https://api.whatsapp.com/send/?phone=+91 ${_tempAnimalList[index]['userMobileNumber']}&text=$whatsappText";
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
                                                                          content:
                                                                              Text('${_tempAnimalList[index]['userMobileNumber']} is not present in Whatsapp'),
                                                                          duration:
                                                                              Duration(milliseconds: 300),
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 8),
                                                                          behavior:
                                                                              SnackBarBehavior.floating,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                        ));
                                                                },
                                                                icon: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .whatsapp,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 14),
                                                                label: Text(
                                                                    'message'
                                                                        .tr,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14)))
                                                          ]),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              _isLoading
                                                  ? Positioned(
                                                      bottom: 0,
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 10),
                                                          Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                    itemCount: _tempAnimalList.length),
                              ],
                            )
                          : Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                ListView.builder(
                                  key: ObjectKey(widget.animalInfo[0]),
                                  padding: EdgeInsets.only(bottom: 60),
                                  controller: _scrollController,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) => Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8, top: 8),
                                      child: Card(
                                        key: Key(index.toString()),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
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
                                                  padding:
                                                      const EdgeInsets.all(8.0),
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
                                                            ['userName'],
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    RaisedButton.icon(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                            side: BorderSide(
                                                                color:
                                                                    darkSecondaryColor)),
                                                        color: secondaryColor,
                                                        onPressed: () async {
                                                          SharedPreferences
                                                              prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          var addresses = await Geocoder
                                                              .local
                                                              .findAddressesFromCoordinates(Coordinates(
                                                                  prefs.getDouble(
                                                                      'latitude'),
                                                                  prefs.getDouble(
                                                                      'longitude')));
                                                          var first =
                                                              addresses.first;

                                                          callingInfo[
                                                                  'userIdCurrent'] =
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  .uid;
                                                          callingInfo[
                                                                  'userIdOther'] =
                                                              widget.animalInfo[
                                                                      index]
                                                                  ['userId'];
                                                          callingInfo[
                                                                  'otherListId'] =
                                                              widget.animalInfo[
                                                                      index]
                                                                  ['uniqueId'];
                                                          callingInfo[
                                                                  'channel'] =
                                                              "call";
                                                          callingInfo[
                                                                  'userAddress'] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'userAddress'];
                                                          callingInfo[
                                                                  "userAnimalDescription"] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'userAnimalDescription'];
                                                          callingInfo[
                                                                  "userAnimalType"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalType'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userAnimalTypeOther"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalTypeOther'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userAnimalAge"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalAge'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userAddress"] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'userAddress'];
                                                          callingInfo[
                                                                  "userName"] =
                                                              widget.animalInfo[
                                                                      index]
                                                                  ['userName'];
                                                          callingInfo[
                                                                  "userAnimalPrice"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalPrice'] ??
                                                                  "0";
                                                          callingInfo[
                                                                  "userAnimalBreed"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalBreed'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userMobileNumber"] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'userMobileNumber'];
                                                          callingInfo[
                                                                  "userAnimalMilk"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalMilk'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userAnimalPregnancy"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalPregnancy'] ??
                                                                  "";
                                                          callingInfo[
                                                              "image1"] = widget
                                                                              .animalInfo[
                                                                          index] ==
                                                                      null ||
                                                                  widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'image1'] ==
                                                                      ""
                                                              ? ""
                                                              : widget.animalInfo[
                                                                      index]
                                                                  ['image1'];
                                                          callingInfo[
                                                              "image2"] = widget
                                                                              .animalInfo[index]
                                                                          [
                                                                          'image2'] ==
                                                                      null ||
                                                                  widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'image2'] ==
                                                                      ""
                                                              ? ""
                                                              : widget.animalInfo[
                                                                      index]
                                                                  ['image2'];
                                                          callingInfo[
                                                              "image3"] = widget
                                                                              .animalInfo[index]
                                                                          [
                                                                          'image3'] ==
                                                                      null ||
                                                                  widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'image3'] ==
                                                                      ""
                                                              ? ""
                                                              : widget.animalInfo[
                                                                      index]
                                                                  ['image3'];
                                                          callingInfo[
                                                              "image4"] = widget
                                                                              .animalInfo[index]
                                                                          [
                                                                          'image4'] ==
                                                                      null ||
                                                                  widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'image4'] ==
                                                                      ""
                                                              ? ""
                                                              : widget.animalInfo[
                                                                      index]
                                                                  ['image4'];
                                                          callingInfo[
                                                                  "dateOfSaving"] =
                                                              ReusableWidgets
                                                                  .dateTimeToEpoch(
                                                                      DateTime
                                                                          .now());
                                                          callingInfo[
                                                                  'isValidUser'] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'isValidUser'];
                                                          callingInfo[
                                                                  'extraInfo'] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'extraInfo'] ??
                                                                  {};
                                                          if (widget.animalInfo[
                                                                      index]
                                                                  ['userId'] !=
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  .uid) {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "callingInfo")
                                                                .doc(callingInfo[
                                                                    'otherListId'])
                                                                .collection(
                                                                    'interestedBuyers')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                                .set(
                                                                    {
                                                                  'userName': widget
                                                                      .userName,
                                                                  'userMobileNumber':
                                                                      widget
                                                                          .userMobileNumber,
                                                                  "userAddress": first
                                                                          .addressLine ??
                                                                      (first.adminArea +
                                                                          ' ' +
                                                                          first
                                                                              .postalCode +
                                                                          ', ' +
                                                                          first
                                                                              .countryName),
                                                                  'userIdCurrent':
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid,
                                                                  'userIdOther':
                                                                      widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'userId'],
                                                                  'otherListId':
                                                                      widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'uniqueId'],
                                                                  'channel':
                                                                      "call",
                                                                  "dateOfSaving":
                                                                      ReusableWidgets
                                                                          .dateTimeToEpoch(
                                                                              DateTime.now())
                                                                },
                                                                    SetOptions(
                                                                        merge:
                                                                            true));

                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "myCallingInfo")
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                                .collection(
                                                                    'myCalls')
                                                                .doc(callingInfo[
                                                                    'otherListId'])
                                                                .set(
                                                                    callingInfo,
                                                                    SetOptions(
                                                                        merge:
                                                                            true));
                                                          }

                                                          return UrlLauncher.launch(
                                                              'tel:+91 ${widget.animalInfo[index]['userMobileNumber']}');
                                                        },
                                                        icon: Icon(
                                                          Icons.call,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                        label: Text(
                                                            'call'.tr,
                                                            style:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14))),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    RaisedButton.icon(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                            side: BorderSide(
                                                                color:
                                                                    darkGreenColor)),
                                                        color: darkGreenColor,
                                                        onPressed: () async {
                                                          String whatsappUrl =
                                                              '';
                                                          SharedPreferences
                                                              prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          var addresses = await Geocoder
                                                              .local
                                                              .findAddressesFromCoordinates(Coordinates(
                                                                  prefs.getDouble(
                                                                      'latitude'),
                                                                  prefs.getDouble(
                                                                      'longitude')));
                                                          var first =
                                                              addresses.first;

                                                          callingInfo[
                                                                  'userIdCurrent'] =
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  .uid;
                                                          callingInfo[
                                                                  'userIdOther'] =
                                                              widget.animalInfo[
                                                                      index]
                                                                  ['userId'];
                                                          callingInfo[
                                                                  'otherListId'] =
                                                              widget.animalInfo[
                                                                      index]
                                                                  ['uniqueId'];
                                                          callingInfo[
                                                                  'channel'] =
                                                              "whatsapp";
                                                          callingInfo[
                                                                  'userAddress'] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'userAddress'];
                                                          callingInfo[
                                                                  "userAnimalDescription"] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'userAnimalDescription'];
                                                          callingInfo[
                                                                  "userAnimalType"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalType'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userAnimalTypeOther"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalTypeOther'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userAnimalAge"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalAge'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userAddress"] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'userAddress'];
                                                          callingInfo[
                                                                  "userName"] =
                                                              widget.animalInfo[
                                                                      index]
                                                                  ['userName'];
                                                          callingInfo[
                                                                  "userAnimalPrice"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalPrice'] ??
                                                                  "0";
                                                          callingInfo[
                                                                  "userAnimalBreed"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalBreed'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userMobileNumber"] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'userMobileNumber'];
                                                          callingInfo[
                                                                  "userAnimalMilk"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalMilk'] ??
                                                                  "";
                                                          callingInfo[
                                                                  "userAnimalPregnancy"] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'userAnimalPregnancy'] ??
                                                                  "";
                                                          callingInfo[
                                                              "image1"] = widget
                                                                              .animalInfo[
                                                                          index] ==
                                                                      null ||
                                                                  widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'image1'] ==
                                                                      ""
                                                              ? ""
                                                              : widget.animalInfo[
                                                                      index]
                                                                  ['image1'];
                                                          callingInfo[
                                                              "image2"] = widget
                                                                              .animalInfo[index]
                                                                          [
                                                                          'image2'] ==
                                                                      null ||
                                                                  widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'image2'] ==
                                                                      ""
                                                              ? ""
                                                              : widget.animalInfo[
                                                                      index]
                                                                  ['image2'];
                                                          callingInfo[
                                                              "image3"] = widget
                                                                              .animalInfo[index]
                                                                          [
                                                                          'image3'] ==
                                                                      null ||
                                                                  widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'image3'] ==
                                                                      ""
                                                              ? ""
                                                              : widget.animalInfo[
                                                                      index]
                                                                  ['image3'];
                                                          callingInfo[
                                                              "image4"] = widget
                                                                              .animalInfo[index]
                                                                          [
                                                                          'image4'] ==
                                                                      null ||
                                                                  widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'image4'] ==
                                                                      ""
                                                              ? ""
                                                              : widget.animalInfo[
                                                                      index]
                                                                  ['image4'];
                                                          callingInfo[
                                                                  "dateOfSaving"] =
                                                              ReusableWidgets
                                                                  .dateTimeToEpoch(
                                                                      DateTime
                                                                          .now());
                                                          callingInfo[
                                                                  'isValidUser'] =
                                                              widget.animalInfo[
                                                                      index][
                                                                  'isValidUser'];
                                                          callingInfo[
                                                                  'extraInfo'] =
                                                              widget.animalInfo[
                                                                          index]
                                                                      [
                                                                      'extraInfo'] ??
                                                                  {};
                                                          if (widget.animalInfo[
                                                                      index]
                                                                  ['userId'] !=
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  .uid) {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "callingInfo")
                                                                .doc(callingInfo[
                                                                    'otherListId'])
                                                                .collection(
                                                                    'interestedBuyers')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                                .set(
                                                                    {
                                                                  'userName': widget
                                                                      .userName,
                                                                  'userMobileNumber':
                                                                      widget
                                                                          .userMobileNumber,
                                                                  "userAddress": first
                                                                          .addressLine ??
                                                                      (first.adminArea +
                                                                          ' ' +
                                                                          first
                                                                              .postalCode +
                                                                          ', ' +
                                                                          first
                                                                              .countryName),
                                                                  'userIdCurrent':
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid,
                                                                  'userIdOther':
                                                                      widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'userId'],
                                                                  'otherListId':
                                                                      widget.animalInfo[
                                                                              index]
                                                                          [
                                                                          'uniqueId'],
                                                                  'channel':
                                                                      "whatsapp",
                                                                  "dateOfSaving":
                                                                      ReusableWidgets
                                                                          .dateTimeToEpoch(
                                                                              DateTime.now())
                                                                },
                                                                    SetOptions(
                                                                        merge:
                                                                            true));

                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "myCallingInfo")
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                                .collection(
                                                                    'myCalls')
                                                                .doc(callingInfo[
                                                                    'otherListId'])
                                                                .set(
                                                                    callingInfo,
                                                                    SetOptions(
                                                                        merge:
                                                                            true));
                                                          }

                                                          whatsappText =
                                                              'नमस्कार भाई साहब, मैंने आपका पशु देखा पशुसंसार पे और आपसे आगे बात करना चाहता हूँ. कब बात कर सकते हैं? ${widget.userName}, ${prefs.getString('place')} \n\nपशुसंसार सूचना - ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन  एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है';
                                                          whatsappUrl =
                                                              "https://api.whatsapp.com/send/?phone=+91 ${widget.animalInfo[index]['userMobileNumber']}&text=$whatsappText";
                                                          await UrlLauncher
                                                                      .canLaunch(
                                                                          whatsappUrl) !=
                                                                  null
                                                              ? UrlLauncher.launch(
                                                                  Uri.encodeFull(
                                                                      whatsappUrl))
                                                              : ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                  content: Text(
                                                                      '${widget.animalInfo[index]['userMobileNumber']} is not present in Whatsapp'),
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
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                ));
                                                        },
                                                        icon: FaIcon(
                                                            FontAwesomeIcons
                                                                .whatsapp,
                                                            color: Colors.white,
                                                            size: 14),
                                                        label: Text(
                                                            'message'.tr,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14)))
                                                  ]),
                                                )),
                                          ],
                                        ),
                                      )
                                      // ),
                                      ),
                                  itemCount: widget.animalInfo.length,
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
                                          transitionDuration:
                                              Duration(seconds: 2),
                                          openBuilder: (context, _) =>
                                              AnimalInfoForm(
                                            userMobileNumber:
                                                widget.userMobileNumber,
                                            userName: widget.userName,
                                          ),
                                          closedShape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          closedColor:
                                              Theme.of(context).primaryColor,
                                          closedBuilder:
                                              (context, openContainer) =>
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
                                                        onPressed: () =>
                                                            setState(() {
                                                          _isVisible = true;
                                                          _isCardVisible =
                                                              false;
                                                        }),
                                                        elevation: 2.0,
                                                        fillColor: Colors.white,
                                                        child: Icon(
                                                          Icons.close,
                                                          size: 20.0,
                                                          color: primaryColor,
                                                        ),
                                                        shape: CircleBorder(),
                                                        constraints:
                                                            BoxConstraints(
                                                                minWidth: 30,
                                                                minHeight: 30),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12.0),
                                                      child: Text(
                                                        'कौन सा पशु खरीदना चाहते है ?',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                                    .circular(
                                                                        10)),
                                                        color: Colors.white,
                                                        onPressed: null,
                                                        disabledColor:
                                                            Colors.white,
                                                        disabledTextColor:
                                                            primaryColor,
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
                                                                  primaryColor,
                                                            ),
                                                            Text('हमें बताये',
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      primaryColor,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    )
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
                                // ),
                                _isLoading
                                    ? Positioned(
                                        bottom: 0,
                                        child: Column(
                                          children: [
                                            SizedBox(height: 60),
                                            Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink(),
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
                                          style: TextStyle(color: primaryColor),
                                        ),
                                        onPressed: () async {
                                          if (_locationController.text.length ==
                                              0)
                                            Navigator.pop(context);
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
                                              _tempAnimalList.clear();

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
                                                  _latitude = first
                                                      .coordinates.latitude;
                                                  _longitude = first
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
                                    backgroundColor: primaryColor,
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
    double _radiusData = _valueRadius == 0
        ? 25
        : _valueRadius == 1
            ? 50
            : _valueRadius == 2
                ? 75
                : _valueRadius == 3
                    ? 75
                    : 50;

    try {
      List district = [];
      RemoteConfig remoteConfig = await RemoteConfig.instance;
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();

      json
          .decode(remoteConfig.getValue("district_map").asString())
          .forEach((element) {
        district.addIf(element[first.subAdminArea ?? first.locality] != null,
            element[first.subAdminArea ?? first.locality]);
      });
      pr.show();
      if (district.isEmpty ||
          !district[0].contains(first.subAdminArea ?? first.locality)) {
        Stream<List<DocumentSnapshot>> stream = geo
            .collection(
                collectionRef: FirebaseFirestore.instance
                    .collection("buyingAnimalList1")
                    .where('isValidUser', isEqualTo: 'Approved'))
            .within(
                center: geo.point(
                    latitude: first.coordinates.latitude,
                    longitude: first.coordinates.longitude),
                radius: _radiusData,
                field: 'position',
                strictMode: true);

        stream.listen((List<DocumentSnapshot> documentList) {
          print("=-=-=12==" + documentList.length.toString());
          if (_tempAnimalList.length == 0) {
            Flushbar(
              message: "no_animal_present".tr,
              duration: Duration(seconds: 2),
            )..show(context);
          }

          setState(() {
            lastDocument = '';
            _resetFilterData = _tempAnimalList = documentList;
            _tempAnimalList
                .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
          });
          if (pr.isShowing()) pr.hide();
          // pr.hide();
          Navigator.of(context).pop();
        });
      } else {
        FirebaseFirestore.instance
            .collection('buyingAnimalList1')
            .orderBy('dateOfSaving', descending: true)
            .where('dateOfSaving',
                isLessThanOrEqualTo:
                    ReusableWidgets.dateTimeToEpoch(DateTime.now()))
            .where('district', whereIn: district[0])
            .where('isValidUser', isEqualTo: 'Approved')
            .limit(25)
            .get()
            .then((value) {
          print('=-=-=-<>' + value.docs.last['dateOfSaving'].toString());

          setState(() {
            lastDocument = value.docs.last['dateOfSaving'];
            districtList = district[0];
            _resetFilterData = _tempAnimalList = value.docs;
            _tempAnimalList
                .sort((a, b) => b['dateOfSaving'].compareTo(a['dateOfSaving']));
          });

          // pr.hide();
          if (pr.isShowing()) pr.hide();
          Navigator.of(context).pop();
          print("=-=-=" + value.docs.length.toString());
        });
      }
    } catch (e) {
      Navigator.pop(context);
      print('=-=Error-=->>>' + e.toString());
    }
  }

  Padding _animalDescriptionMethod(int index) {
    List _list =
        _tempAnimalList.length != 0 ? _tempAnimalList : widget.animalInfo;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _list[index]['userAnimalDescription'] ?? "",
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 14.5),
      ),
    );
  }

  Padding _animalImageWidget(int index) {
    List _list =
        _tempAnimalList.length != 0 ? _tempAnimalList : widget.animalInfo;

    List<String> _images = [];
    [
      _list[index]['image1'],
      _list[index]['image2'],
      _list[index]['image3'],
      _list[index]['image4'],
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
                            autoPlayInterval: Duration(seconds: 4),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (index, reason) => setState(() {
                                  _current = index;
                                })),
                        items: _images.map((i) {
                          return InteractiveViewer(
                            boundaryMargin: const EdgeInsets.all(20.0),
                            minScale: 0.1,
                            maxScale: 1.6,
                            child: i.length > 1000
                                ? Image.memory(base64Decode('$i'))
                                : Image.network(
                                    '$i',
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
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
                  image: _images[0].length > 1000
                      ? MemoryImage(
                          base64.decode(_images[0]),
                        )
                      : NetworkImage(_images[0]),
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
                    "uniqueId": _list[index]['uniqueId'],
                    "userId": _list[index]['userId'],
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

                  await takeScreenShot(_list[index]['uniqueId']);

                  Share.shareFiles([fileUrl.path],
                      mimeTypes: ['images/png'],
                      text:
                          // "नस्ल: ${_list[index]['userAnimalBreed']}\nजानकारी: ${_list[index]['userAnimalDescription']}\nदूध(प्रति दिन): ${_list[index]['userAnimalMilk']} Litre\n\nऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar}",
                          "नस्ल: ${_list[index]['userAnimalBreed']}\nजानकारी: ${_list[index]['userAnimalDescription']}\nदूध(प्रति दिन): ${_list[index]['userAnimalMilk']} Litre\n\nपशु देखे: ${shortUrl.toString()}",
                      subject: 'animal_info'.tr);

                  // Share.share(shortUrl.toString());
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
    List _list =
        _tempAnimalList.length != 0 ? _tempAnimalList : widget.animalInfo;

    return StatefulBuilder(builder: (context, setState1) {
      getPositionBasedOnLatLong(
              _list[index]['userLatitude'], _list[index]['userLongitude'])
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
                          _list[index]['dateOfSaving'],
                        ),
                      ),
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

                // TextSpan(
                //     text: ' ' + val.toString(),
                //     style: TextStyle(
                //         color: Colors.grey[500],
                //         fontWeight: FontWeight.bold,
                //         fontSize: 13),
                children: [
                  // TextSpan(
                  //   text: ' (',
                  //   style: TextStyle(
                  //       color: Colors.grey[500],
                  //       // fontWeight: FontWeight.bold,
                  //       fontSize: 13),
                  // ),
                  TextSpan(
                    text: _distanceBetweenTwoCoordinates(
                            _list[index]['userLatitude'],
                            _list[index]['userLongitude']) +
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
    double _latx, _longx;
    if (widget.latitude == 0.0 || widget.longitude == 0.0) {
      _latx = _latitude;
      _longx = _longitude;
    } else {
      _latx = widget.latitude;
      _longx = widget.longitude;
    }

    return (Geodesy().distanceBetweenTwoGeoPoints(
              LatLng(_latx, _longx),
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
                          color: _index == 0 ? primaryColor : Colors.white,
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
                            color: _index == 1 ? primaryColor : Colors.white,
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
                                  onPressed: () {
                                    setState(() {
                                      _filterDropDownMap.remove('filter1');
                                      _filterDropDownMap.remove('filter2');
                                      _tempAnimalList = _resetFilterData;
                                      _value = null;
                                      _filterAnimalType = null;
                                    });

                                    Navigator.pop(context);
                                  },
                                  child: Text('कैंसिल',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold))),
                              RaisedButton(
                                  onPressed: () {
                                    List _data = [];
                                    (_tempAnimalList.length == 0
                                            ? widget.animalInfo
                                            : _tempAnimalList)
                                        .forEach((element) {
                                      if (_filterDropDownMap == null ||
                                          _filterDropDownMap == {}) {
                                        _data.add(_infoList);
                                      } else if ((_filterDropDownMap[
                                                      'filter1'] !=
                                                  null &&
                                              _filterDropDownMap['filter1']
                                                  .isNotEmpty) &&
                                          (_filterDropDownMap['filter2'] !=
                                              null)) {
                                        switch (_filterDropDownMap['filter2']) {
                                          case 0:
                                            _data.addIf(
                                                _filterDropDownMap['filter1'] ==
                                                        element[
                                                            'userAnimalType'] &&
                                                    ((double.parse(_milkValueCheck(
                                                                element[
                                                                    'userAnimalMilk'])) >=
                                                            0.0) &&
                                                        (double.parse(
                                                                _milkValueCheck(
                                                                    element[
                                                                        'userAnimalMilk'])) <=
                                                            10.0)),
                                                element);

                                            break;
                                          case 1:
                                            _data.addIf(
                                                _filterDropDownMap['filter1'] ==
                                                        element[
                                                            'userAnimalType'] &&
                                                    ((double.parse(_milkValueCheck(
                                                                element[
                                                                    'userAnimalMilk'])) >
                                                            10.0) &&
                                                        (double.parse(
                                                                _milkValueCheck(
                                                                    element[
                                                                        'userAnimalMilk'])) <=
                                                            15.0)),
                                                element);
                                            break;
                                          case 2:
                                            _data.addIf(
                                                _filterDropDownMap['filter1'] ==
                                                        element[
                                                            'userAnimalType'] &&
                                                    ((double.parse(_milkValueCheck(
                                                                element[
                                                                    'userAnimalMilk'])) >
                                                            15.0) &&
                                                        (double.parse(
                                                                _milkValueCheck(
                                                                    element[
                                                                        'userAnimalMilk'])) <=
                                                            20.0)),
                                                element);
                                            break;
                                          case 3:
                                            _data.addIf(
                                                _filterDropDownMap['filter1'] ==
                                                        element[
                                                            'userAnimalType'] &&
                                                    (double.parse(_milkValueCheck(
                                                            element[
                                                                'userAnimalMilk'])) >
                                                        20.0),
                                                element);
                                            break;
                                        }
                                      } else if (_filterDropDownMap[
                                                  'filter1'] !=
                                              null &&
                                          _filterDropDownMap['filter1']
                                              .isNotEmpty) {
                                        _data.addIf(
                                            _filterDropDownMap['filter1'] ==
                                                element['userAnimalType'],
                                            element);
                                      } else if (_filterDropDownMap[
                                              'filter2'] !=
                                          null) {
                                        switch (_filterDropDownMap['filter2']) {
                                          case 0:
                                            _data.addIf(
                                                (double.parse(_milkValueCheck(
                                                            element[
                                                                'userAnimalMilk'])) >=
                                                        0.0) &&
                                                    (double.parse(_milkValueCheck(
                                                            element[
                                                                'userAnimalMilk'])) <=
                                                        10.0),
                                                element);

                                            break;
                                          case 1:
                                            _data.addIf(
                                                (double.parse(_milkValueCheck(
                                                            element[
                                                                'userAnimalMilk'])) >
                                                        10.0) &&
                                                    (double.parse(_milkValueCheck(
                                                            element[
                                                                'userAnimalMilk'])) <=
                                                        15.0),
                                                element);
                                            break;
                                          case 2:
                                            _data.addIf(
                                                (double.parse(_milkValueCheck(
                                                            element[
                                                                'userAnimalMilk'])) >
                                                        15.0) &&
                                                    (double.parse(_milkValueCheck(
                                                            element[
                                                                'userAnimalMilk'])) <=
                                                        20.0),
                                                element);
                                            break;
                                          case 3:
                                            _data.addIf(
                                                double.parse(_milkValueCheck(
                                                        element[
                                                            'userAnimalMilk'])) >
                                                    20.0,
                                                element);
                                            break;
                                        }
                                      }
                                    });
                                    setState(() {
                                      // _resetFilterData = _tempAnimalList;
                                      _tempAnimalList = _data;
                                      // _tempAnimalList.sort((a, b) =>
                                      //     a['userAnimalMilk']
                                      //         .compareTo(b['userAnimalMilk']));
                                    });

                                    Navigator.pop(context);
                                    if (_tempAnimalList.length == 0) {
                                      Flushbar(
                                        message: "no_animal_present".tr,
                                        duration: Duration(seconds: 2),
                                      )..show(context);

                                      setState(() {
                                        _tempAnimalList = _resetFilterData;
                                      });
                                    }
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

  _milkValueCheck(milk) {
    return (milk == null || milk == "") ? '0' : milk;
  }
}
