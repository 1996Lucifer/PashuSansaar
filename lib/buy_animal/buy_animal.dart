import 'dart:convert';
import 'dart:typed_data';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:dhenu/utils/colors.dart';
import 'package:dhenu/utils/reusable_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:esys_flutter_share/esys_flutter_share.dart' as eshare;
import 'package:screenshot/screenshot.dart';
import 'package:dhenu/utils/constants.dart' as constant;
import 'package:dio/dio.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:uuid/uuid.dart';

class BuyAnimal extends StatefulWidget {
  List animalInfo;
  List sellingAnimalInfo;
  final String userName;
  final String userMobileNumber;
  BuyAnimal({
    Key key,
    @required this.animalInfo,
    @required this.sellingAnimalInfo,
    @required this.userName,
    @required this.userMobileNumber,
  }) : super(key: key);

  @override
  _BuyAnimalState createState() => _BuyAnimalState();
}

class _BuyAnimalState extends State<BuyAnimal> {
  var formatter = intl.NumberFormat('#,##,000');
  int _index;
  Uint8List _imageFile;
  int _value;
  List<String> _filterMilkValue = [
    '0-10 ' + 'litre_milk'.tr,
    '10-15 ' + 'litre_milk'.tr,
    '15-20 ' + 'litre_milk'.tr,
    '> 20 ' + 'litre_milk'.tr
  ];
  List _infoData = [];
  int _current = 0;
  RangeValues _values = RangeValues(0, 50);
  String _filterDropDown;
  Map _filterDropDownMap = {};
  List<String> _filterData = ['animal_type'.tr, 'animal_milk_per_day'.tr];
  // List widget.animalInfo = [];
  ProgressDialog pr;
  String _locality = '';
  double _latitude = 0.0, _longitude = 0.0;
  ScreenshotController screenshotController = ScreenshotController();
  String _filterAnimalType;
  List _infoList = [];
  String desc = '';
  String _userLocality = '';
  TextEditingController _locationController = TextEditingController();
  String _sessionToken;
  List _tempList = [];
  @override
  void initState() {
    // getInitialInfo();
    // dataFillOnInit();
    _locationController.addListener(() {
      _onChanged();
    });

    getLatLong();
    super.initState();
  }

  getLatLong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getPositionBasedOnLatLong(
            prefs.getDouble('latitude'), prefs.getDouble('longitude'))
        .then((result) {
      setState(() {
        _userLocality = result;
        _latitude = prefs.getDouble('latitude');
        _longitude = prefs.getDouble('longitude');
        // widget.animalInfo.sort((a, b) =>
        //     ReusableWidgets.epochToDateTime(a['dateOfSaving'])
        //         .compareTo(ReusableWidgets.epochToDateTime(b['dateOfSaving'])));
        // widget.animalInfo.sort(
        //     (a, b) => a['userAnimalPrice'].compareTo(b['userAnimalPrice']));
        // widget.animalInfo
        //     .sort((a, b) => a['userAnimalMilk'].compareTo(b['userAnimalMilk']));
      });
    });

    // sellingAnimalInfoMappingWithBuying();
  }

  getInitialInfo() async {
    // await Firebase.initializeApp();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);

    // SharedPreferences prefs = await SharedPreferences.getInstance();

    pr.style(message: 'progress_dialog_message'.tr);
    pr.show();

    FirebaseFirestore.instance
        .collection("buyingAnimalList")
        .get(GetOptions(source: Source.serverAndCache))
        .then(
      (value) {
        List _info = [];
        value.docs.forEach((element) {
          _info.add(element.data());
        });

        setState(() {
          widget.animalInfo = _info;
        });
        pr.hide();
      },
    );
  }

  _descriptionText(jsonData, int index) {
    String desc = '';

    String stmn2 =
        'यह ${jsonData[index]['extraInfo']['animalAlreadyGivenBirth']} ब्यायी है ';
    String stmn3 =
        'और अभी ${jsonData[index]['extraInfo']['animalIfPregnant']} है। ';
    String stmn4 = '';
    String stmn41 = 'इसके साथ में बच्चा नहीं है। ';
    String stmn42 =
        'इसके साथ में ${jsonData[index]['extraInfo']['animalHasBaby']}। ';
    String stmn5 =
        'पिछले बार के हिसाब से दूध कैपेसिटी ${jsonData[index]['animalInfo']['animalMilk']} लीटर है। ';

    if (jsonData[index]['animalInfo']['animalType'] == 'buffalo_male'.tr ||
        jsonData[index]['animalInfo']['animalType'] == 'ox'.tr) {
      desc =
          'ये ${jsonData[index]['animalInfo']['animalBreed']} ${jsonData[index]['animalInfo']['animalType']} ${jsonData[index]['animalInfo']['animalAge']} साल का है। ';
    } else {
      desc =
          'ये ${jsonData[index]['animalInfo']['animalBreed']} ${jsonData[index]['animalInfo']['animalType']} ${jsonData[index]['animalInfo']['animalAge']} साल की है। ';
      if (jsonData[index]['extraInfo']['animalAlreadyGivenBirth'] != null)
        desc = desc + stmn2;
      if (jsonData[index]['extraInfo']['animalIfPregnant'] != null)
        desc = desc + stmn3;
      if (jsonData[index]['extraInfo']['animalHasBaby'] != null &&
          jsonData[index]['extraInfo']['animalHasBaby'] == 'nothing'.tr)
        stmn4 = stmn4 + stmn41;
      else
        stmn4 = stmn4 + stmn42;

      desc = desc + stmn4;
      desc = desc + stmn5;
    }

    return desc + (jsonData[index]['extraInfo']['moreInfo'] ?? '');
  }

  sellingAnimalInfoMappingWithBuying() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _infoList = [];
    var jsonData = jsonDecode(prefs.get('animalDetails'));
    var jsonBuyingData = jsonDecode(prefs.get('animalBuyingDetails'));
    widget.animalInfo = jsonBuyingData;
    _infoData = widget.animalInfo;

    for (int i = 0; i < jsonData.length; i++) {
      _infoData.addIf(
        widget.animalInfo[i]['dateOfSaving'] != jsonData[i]['dateOfSaving'],
        ({
          "userAnimalDescription": _descriptionText(jsonData, i),
          "userAnimalType": jsonData[i]['animalInfo']['animalType'],
          "userAnimalAge": jsonData[i]['animalInfo']['animalAge'],
          "userAddress": "",
          "userName": widget.userName,
          "userAnimalPrice": jsonData[i]['animalInfo']['animalPrice'],
          "userAnimalBreed": jsonData[i]['animalInfo']['animalBreed'],
          "userMobileNumber": widget.userMobileNumber,
          "userAnimalMilk": jsonData[i]['animalInfo']['animalMilk'],
          "userAnimalPregnancy": jsonData[i]['animalInfo']['animalIsPregnant'],
          "userLatitude": prefs.getDouble('latitude'),
          "userLongitude": prefs.getDouble('longitude'),
          "image1": jsonData[i]['animalImages']['image1'] == null ||
                  jsonData[i]['animalImages']['image1'] == ""
              ? ""
              : jsonData[i]['animalImages']['image1'],
          "image2": jsonData[i]['animalImages']['image2'] == null ||
                  jsonData[i]['animalImages']['image2'] == ""
              ? ""
              : jsonData[i]['animalImages']['image2'],
          "image3": jsonData[i]['animalImages']['image3'] == null ||
                  jsonData[i]['animalImages']['image3'] == ""
              ? ""
              : jsonData[i]['animalImages']['image3'],
          "image4": jsonData[i]['animalImages']['image4'] == null ||
                  jsonData[i]['animalImages']['image4'] == ""
              ? ""
              : jsonData[i]['animalImages']['image4'],
          "dateOfSaving": jsonData[i]['dateOfSaving']
        }),
      );
    }

    setState(() {
      // widget.animalInfo = _infoData;
      widget.animalInfo = _infoData.toSet().toList();
      // widget.animalInfo.toSet().toList().sort((a, b) =>
      //     ReusableWidgets.epochToDateTime(b['dateOfSaving'])
      //         .compareTo(ReusableWidgets.epochToDateTime(a['dateOfSaving'])));
      widget.animalInfo.sort((a, b) =>
          _getDistance(a['userLatitude'], a['userLongitude'])
              .compareTo(_getDistance(a['userLatitude'], a['userLongitude'])));
      widget.animalInfo
          .sort((a, b) => a['userAnimalPrice'].compareTo(b['userAnimalPrice']));
      widget.animalInfo
          .sort((a, b) => a['userAnimalMilk'].compareTo(b['userAnimalMilk']));
    });

    // pr.hide();
  }

  String _getDistance(lat, long) {
    return (Geodesy().distanceBetweenTwoGeoPoints(
              LatLng(_latitude, _longitude),
              LatLng(lat, long),
            ) /
            1000)
        .toStringAsFixed(0);
  }

  // loadAddress(address) async {
  //   var addresses = await Geocoder.local.findAddressesFromQuery(address);
  //   var first = addresses.first;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   setState(() {
  //     prefs.setDouble("userLatitude", first.coordinates.latitude);
  //     prefs.setDouble("userLongitude", first.coordinates.longitude);
  //   });
  // }

  // dataFillOnInit() async {
  //   // await Firebase.initializeApp();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   final myData = await rootBundle.loadString("assets/file/animal_data.csv");
  //   List<List<dynamic>> data = CsvToListConverter().convert(myData);

  //   for (int i = 1; i <= data.length - 1; i++) {
  //     loadAddress(data[i][3].toString());
  //     await FirebaseFirestore.instance
  //         .collection("buyingAnimalList")
  //         .doc()
  //         .set({
  //       "userAnimalDescription": data[i][0].toString(),
  //       "userAnimalType": data[i][1].toString(),
  //       "userAnimalAge": data[i][2].toString(),
  //       "userAddress": data[i][3].toString(),
  //       "userName": data[i][4].toString(),
  //       "userAnimalPrice": data[i][5].toString(),
  //       "userAnimalBreed": data[i][6].toString(),
  //       "userMobileNumber": data[i][7].toString(),
  //       "userAnimalMilk": data[i][8].toString(),
  //       "userAnimalPregnancy": data[i][9].toString(),
  //       "userLatitude": prefs.getDouble('userLatitude'),
  //       "userLongitude": prefs.getDouble('userLongitude'),
  //       "image1": data[i][10] == null || data[i][10] == ""
  //           ? ""
  //           : data[i][10].toString(),
  //       "image2": data[i][11] == null || data[i][11] == ""
  //           ? ""
  //           : data[i][11].toString(),
  //       "image3": data[i][12] == null || data[i][12] == ""
  //           ? ""
  //           : data[i][12].toString(),
  //       "image4": data[i][13] == null || data[i][13] == ""
  //           ? ""
  //           : data[i][13].toString(),
  //       "dateOfSaving": ReusableWidgets.dateTimeToEpoch(DateTime.now())
  //     });
  //   }
  // }

  bayaatMapping(bayaat) {
    String bayaaat = '';
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

    return bayaaat;
  }

  getPositionBasedOnLatLong(double lat, double long) async {
    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    return first.locality ?? first.featureName;
  }

  Row _buildInfowidget(index) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: RichText(
              textAlign: TextAlign.center,
              text: (constant.animalType.indexOf(
                              widget.animalInfo[index]['userAnimalType']) ==
                          0 ||
                      constant.animalType.indexOf(
                              widget.animalInfo[index]['userAnimalType']) ==
                          1)
                  ? TextSpan(
                      text: widget.animalInfo[index]['userAnimalMilk'],
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
                            text: bayaatMapping(widget.animalInfo[index]
                                ['userAnimalPregnancy']),
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
                                        widget.animalInfo[index]
                                            ['userAnimalPrice'])) ??
                                0,
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ])
                  : TextSpan(
                      text: widget.animalInfo[index]['userAnimalBreed'],
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
                            text: widget.animalInfo[index]['userAnimalType'],
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          TextSpan(
                            text: ', ₹ ' +
                                    formatter.format(int.parse(
                                        widget.animalInfo[index]
                                            ['userAnimalPrice'])) ??
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

  // (700 / distance)  + (200/ time in days + 1)  + (100 / price)  formula for sorting

  _animalTypeDropDown() => StatefulBuilder(
      builder: (context, setState) => Column(children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  Text(
                    'animal_type'.tr,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '*',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
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

                    if (constant.animalType.indexOf(type) != 0 ||
                        constant.animalType.indexOf(type) != 1) {
                      _filterDropDownMap['filter2'] = null;
                      _value = null;
                    }
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
                children: _filterMilkValue
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
                                  color: _value == _filterMilkValue.indexOf(e)
                                      ? Colors.white
                                      : primaryColor),
                            ),
                            selectedColor: primaryColor,
                            selected: _value == _filterMilkValue.indexOf(e),
                            onSelected: (bool selected) {
                              setState(() {
                                _value = selected
                                    ? _filterMilkValue.indexOf(e)
                                    : null;
                                _filterDropDownMap['filter2'] = _value;
                              });
                            },
                          ),
                        ))
                    .toList()),
          ],
        ),
      );

  _filterAnimal() {
    return Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: GestureDetector(
          onTap: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Text("Filter"),
                    content: StatefulBuilder(builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField(
                            value: _filterDropDown,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8)),
                            onChanged: (String newValue) {
                              setState(() {
                                _filterDropDown = newValue;
                              });
                            },
                            items: _filterData
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _filterDropDown == null
                              ? SizedBox.shrink()
                              : Visibility(
                                  visible:
                                      _filterData[0].contains(_filterDropDown),
                                  child: _animalTypeDropDown(),
                                  replacement: _animalMilkSilder(),
                                )
                        ],
                      );
                    }),
                    actions: <Widget>[
                      StatefulBuilder(builder: (context, setState) {
                        return FlatButton(
                            child: Text(
                              'Ok'.tr,
                              style: TextStyle(color: primaryColor),
                            ),
                            onPressed: () {
                              List _data = [];
                              widget.animalInfo.forEach((element) {
                                if (_filterDropDownMap == null ||
                                    _filterDropDownMap == {}) {
                                  _data.add(_infoList);
                                } else if (_filterDropDownMap['filter1'] !=
                                        null &&
                                    _filterDropDownMap['filter1'].isNotEmpty) {
                                  _data.addIf(
                                      _filterDropDownMap['filter1'] ==
                                          'buffalo_male'.tr,
                                      element);
                                } else if (_filterDropDownMap['filter2'] !=
                                    null) {
                                  switch (_filterDropDownMap['filter2']) {
                                    case 0:
                                      _data.addIf(
                                          int.parse(element[
                                                      'userAnimalMilk']) >=
                                                  0 &&
                                              int.parse(element[
                                                      'userAnimalMilk']) <=
                                                  10,
                                          element);

                                      break;
                                    case 1:
                                      _data.addIf(
                                          double.parse(element[
                                                      'userAnimalMilk']) >
                                                  10 &&
                                              int.parse(element[
                                                      'userAnimalMilk']) <=
                                                  15,
                                          element);
                                      break;
                                    case 2:
                                      _data.addIf(
                                          double.parse(element[
                                                      'userAnimalMilk']) >
                                                  15 &&
                                              int.parse(element[
                                                      'userAnimalMilk']) <=
                                                  20,
                                          element);
                                      break;
                                    case 3:
                                      _data.addIf(
                                          double.parse(
                                                  element['userAnimalMilk']) >
                                              20,
                                          element);
                                      break;
                                  }
                                }
                                setState(() {
                                  widget.animalInfo = _data;
                                });
                              });
                              // Navigator.pop(context);
                            });
                      }),
                    ]);
              }),
          child: Icon(
            Icons.filter_alt,
            size: 26.0,
          ),
        ));
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = Uuid().v4();
      });
    }
    getSuggestion(_locationController.text);
  }

  void getSuggestion(String input) async {
    List _placesList = [];
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyAPeAo2d-fIrw24-5ZXEcRECleQnzgRdXk&sessiontoken=$_sessionToken';

    var response = await Dio().get(baseURL);
    if (response.statusCode == 200) {
      setState(() {
        _placesList = json.decode(response.data);
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                      child: Card(
                        key: Key(index.toString()),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                height: 80,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Image.asset('assets/images/profile.jpg',
                                        width: 40, height: 40),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        widget.animalInfo[index]['userName'],
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    RaisedButton.icon(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                                color: darkSecondaryColor)),
                                        color: secondaryColor,
                                        onPressed: () => UrlLauncher.launch(
                                            'tel:+91 ${widget.animalInfo[index]['userMobileNumber']}'),
                                        icon: Icon(
                                          Icons.call,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        label: Text('call'.tr,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14))),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    RaisedButton.icon(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                                color: darkGreenColor)),
                                        color: darkGreenColor,
                                        onPressed: () async {
                                          String whatsappText = '';
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          getPositionBasedOnLatLong(
                                                  prefs.getDouble('latitude'),
                                                  prefs.getDouble('longitude'))
                                              .then((result) {
                                            setState(() {
                                              whatsappText =
                                                  'नमस्कार भाई साहब, मैंने आपका पशु देखा पशुसंसार पे और आपसे आगे बात करना चाहता हूँ. कब बात कर सकते हैं? ${widget.userName}, $result \n\nपशुसंसार सूचना - ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन  एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है';
                                            });
                                          });
                                          var whatsappUrl =
                                              "https://api.whatsapp.com/send/?phone=${widget.animalInfo[index]['userMobileNumber']}&text=$whatsappText";
                                          // "whatsapp://send?phone=+91 ${widget.animalInfo[index]['userMobileNumber']}&text=$whatsappText";
                                          await UrlLauncher.canLaunch(
                                                      whatsappUrl) !=
                                                  null
                                              ? UrlLauncher.launch(whatsappUrl)
                                              : ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                  content: Text(
                                                      '${widget.animalInfo[index]['userMobileNumber']} is not present in Whatsapp'),
                                                  duration: Duration(
                                                      milliseconds: 300),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ));
                                        },
                                        icon: FaIcon(FontAwesomeIcons.whatsapp,
                                            color: Colors.white, size: 14),
                                        label: Text('message'.tr,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)))
                                  ]),
                                ))
                          ],
                        ),
                      )
                      // ),
                      );
                },
                itemCount: widget.animalInfo.length),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: Text("Location Change"),
                            content:
                                StatefulBuilder(builder: (context, setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextField(
                                    controller: _locationController,
                                    // onTap: () async {
                                    //   final request =
                                    //       'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${_locationController.text}&key=AIzaSyAPeAo2d-fIrw24-5ZXEcRECleQnzgRdXk';
                                    //   // var response = await Dio().get(request);

                                    //   // print(response);

                                    //   // placeholder for our places search later
                                    // },
                                    // with some styling
                                    decoration: InputDecoration(
                                      icon: Container(
                                        margin: EdgeInsets.only(left: 20),
                                        width: 10,
                                        height: 10,
                                        child: Icon(
                                          Icons.location_on,
                                          color: Colors.black,
                                        ),
                                      ),
                                      hintText: "Enter your address or zipcode",
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(left: 8.0, top: 16.0),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text(
                                    'Ok'.tr,
                                    style: TextStyle(color: primaryColor),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ]);
                      }),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[400])),

                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
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
                    // color: Colors.grey[100],
                  ),
                ),
              ),
              // Container(
              //   width: 1,
              //   color: Colors.grey[400],
              //   height: 70,
              // ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => _filterBottomSheet(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      )),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[400])),
                    height: 70,
                    // width: MediaQuery.of(context).size.width / 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                          child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: FaIcon(FontAwesomeIcons.dog,
                                  size: 14, color: Colors.black),
                            ),
                            TextSpan(
                                text: " " + "animal_filter".tr,
                                style: TextStyle(color: Colors.black)),
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
    );
  }

  Padding _animalDescriptionMethod(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        widget.animalInfo[index]['userAnimalDescription'],
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 14.5),
      ),
    );
  }

  Padding _animalImageWidget(int index) {
    return Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8, bottom: 4),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                List<String> _images = [];
                [
                  widget.animalInfo[index]['image1'],
                  widget.animalInfo[index]['image2'],
                  widget.animalInfo[index]['image3'],
                  widget.animalInfo[index]['image4'],
                ].forEach((element) => _images.addIf(
                    element != null && element.isNotEmpty, element));

                return Navigator.of(context).push(PageRouteBuilder(
                  opaque: true,
                  pageBuilder: (BuildContext context, _, __) => Column(
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
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            }),
                        items: _images.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Image.network('$i');
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
                  ),
                ));
              },
              child: Container(
                height: 200.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.animalInfo[index]['image1'])),
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
                    // _imageFile = null;
                    // screenshotController
                    //     .capture(delay: Duration(milliseconds: 10))
                    //     .then((Uint8List image) {
                    //   // setState(() {
                    //   _imageFile = image;
                    //   // });
                    // }).catchError((onError) {
                    //   print(onError);
                    // });

                    Share.share(
                        "Type: ${widget.animalInfo[index]['userAnimalBreed']}\nDescription: ${widget.animalInfo[index]['userAnimalDescription']}\nGender: ${widget.animalInfo[index]['userAnimalGender']}\nMilk: ${widget.animalInfo[index]['userAnimalMilk']} Litre",
                        subject: 'Share Animal Info');

                    //text add
                    //image add

                    // await eshare.Share.file(
                    //     'Image', 'info.png', _imageFile, 'image/png',
                    //     text: 'My optional text.');
                  },
                  icon: Icon(Icons.share, color: Colors.white, size: 14),
                  label: Text('share'.tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14))),
            )
          ],
        ));
  }

  Padding _distanceTimeMethod(int index) => Padding(
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
                              widget.animalInfo[index]['dateOfSaving'])),
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
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: ' ' + _locality.toString(),
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  children: [
                    TextSpan(
                      text: ' ( ' + 'approx'.tr + ' ',
                      style: TextStyle(
                          color: Colors.grey[500],
                          // fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    TextSpan(
                      text:
                          _distanceBetweenTwoCoordinates(index) + ' ' + 'km'.tr,
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    TextSpan(
                      text: ' )',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    )
                  ]),
            ),
          ],
        ),
      );

  String _distanceBetweenTwoCoordinates(int index) {
    getPositionBasedOnLatLong(widget.animalInfo[index]['userLatitude'],
            widget.animalInfo[index]['userLongitude'])
        .then((result) => setState(() {
              _locality = result;
            }));

    return (Geodesy().distanceBetweenTwoGeoPoints(
              LatLng(_latitude, _longitude),
              LatLng(widget.animalInfo[index]['userLatitude'],
                  widget.animalInfo[index]['userLongitude']),
            ) /
            1000)
        .toStringAsFixed(0);
  }

  _filterBottomSheet() {
    return StatefulBuilder(builder: (context, setState) {
      return Row(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                    child: GestureDetector(
                  onTap: () => setState(() => _index = 0),
                  child: Text('animal_type'.tr),
                )),
              ),
              Divider(),
              Expanded(
                  child: Container(
                      child: GestureDetector(
                onTap: () => setState(() => _index = 1),
                child: Text('animal_milk_per_day'.tr),
              ))),
            ],
          ),
          VerticalDivider(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Visibility(
                    visible: _index == 0,
                    child: _animalTypeDropDown(),
                    replacement: _animalMilkSilder(),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RaisedButton(
                          onPressed: () {
                            setState(() {
                              _filterDropDownMap = null;
                            });
                            Navigator.pop(context);
                          },
                          child: Text('Cancel')),
                      RaisedButton(
                          onPressed: () {
                            List _data = [];
                            widget.animalInfo.forEach((element) {
                              element['userAnimalMilk'] =
                                  element['userAnimalMilk'] == ""
                                      ? '0'
                                      : element['userAnimalMilk'];
                              if (_filterDropDownMap == null ||
                                  _filterDropDownMap == {}) {
                                _data.add(_infoList);
                              } else if ((_filterDropDownMap['filter1'] !=
                                          null &&
                                      _filterDropDownMap['filter1']
                                          .isNotEmpty) &&
                                  (_filterDropDownMap['filter2'] != null)) {
                                switch (_filterDropDownMap['filter2']) {
                                  case 0:
                                    _data.addIf(
                                        _filterDropDownMap['filter1'] ==
                                                element['userAnimalType'] &&
                                            (double.parse(element[
                                                        'userAnimalMilk']) >=
                                                    0 &&
                                                double.parse(element[
                                                        'userAnimalMilk']) <=
                                                    10),
                                        element);

                                    break;
                                  case 1:
                                    _data.addIf(
                                        _filterDropDownMap['filter1'] ==
                                                element['userAnimalType'] &&
                                            (double.parse(element[
                                                        'userAnimalMilk']) >
                                                    10 &&
                                                double.parse(element[
                                                        'userAnimalMilk']) <=
                                                    15),
                                        element);
                                    break;
                                  case 2:
                                    _data.addIf(
                                        _filterDropDownMap['filter1'] ==
                                                element['userAnimalType'] &&
                                            (double.parse(element[
                                                        'userAnimalMilk']) >
                                                    15 &&
                                                double.parse(element[
                                                        'userAnimalMilk']) <=
                                                    20),
                                        element);
                                    break;
                                  case 3:
                                    _data.addIf(
                                        _filterDropDownMap['filter1'] ==
                                                element['userAnimalType'] &&
                                            (double.parse(
                                                    element['userAnimalMilk']) >
                                                20),
                                        element);
                                    break;
                                }
                              } else if (_filterDropDownMap['filter1'] !=
                                      null &&
                                  _filterDropDownMap['filter1'].isNotEmpty) {
                                _data.addIf(
                                    _filterDropDownMap['filter1'] ==
                                        element['userAnimalType'],
                                    element);
                              } else if (_filterDropDownMap['filter2'] !=
                                  null) {
                                switch (_filterDropDownMap['filter2']) {
                                  case 0:
                                    _data.addIf(
                                        double.parse(element[
                                                    'userAnimalMilk']) >=
                                                0 &&
                                            double.parse(element[
                                                    'userAnimalMilk']) <=
                                                10,
                                        element);

                                    break;
                                  case 1:
                                    _data.addIf(
                                        double.parse(
                                                    element['userAnimalMilk']) >
                                                10 &&
                                            double.parse(element[
                                                    'userAnimalMilk']) <=
                                                15,
                                        element);
                                    break;
                                  case 2:
                                    _data.addIf(
                                        double.parse(
                                                    element['userAnimalMilk']) >
                                                15 &&
                                            double.parse(element[
                                                    'userAnimalMilk']) <=
                                                20,
                                        element);
                                    break;
                                  case 3:
                                    _data.addIf(
                                        double.parse(
                                                element['userAnimalMilk']) >
                                            20,
                                        element);
                                    break;
                                }
                              }
                            });
                            setState(() {
                              widget.animalInfo = _data;
                            });

                            Navigator.pop(context);
                          },
                          child: Text('Apply')),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      );
    });
  }
}
