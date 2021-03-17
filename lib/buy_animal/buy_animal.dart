import 'dart:convert';
import 'dart:typed_data';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/global.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
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
import 'package:screenshot/screenshot.dart';
import 'package:pashusansaar/utils/constants.dart' as constant;
import 'package:geoflutterfire/geoflutterfire.dart' as geoFire;

class BuyAnimal extends StatefulWidget {
  List animalInfo;
  final String userName;
  final String userMobileNumber;
  final String userImage;
  BuyAnimal({
    Key key,
    @required this.animalInfo,
    @required this.userName,
    @required this.userMobileNumber,
    @required this.userImage,
  }) : super(key: key);

  @override
  _BuyAnimalState createState() => _BuyAnimalState();
}

class _BuyAnimalState extends State<BuyAnimal>
    with AutomaticKeepAliveClientMixin {
  var formatter = intl.NumberFormat('#,##,000');
  int _index = 0, _value, _valueRadius;
  int perPage = 10;

  List<String> _filterMilkValue = [
    '0-10 ' + 'litre_milk'.tr,
    '11-15 ' + 'litre_milk'.tr,
    '16-20 ' + 'litre_milk'.tr,
    '> 20 ' + 'litre_milk'.tr
  ];
  List<String> _radius = [
    '25 ' + 'km'.tr,
    '50 ' + 'km'.tr,
    '75 ' + 'km'.tr,
    '100 ' + 'km'.tr
  ];

  final geo = geoFire.Geoflutterfire();

  int _current = 0;
  Map<String, dynamic> _filterDropDownMap = {};
  ProgressDialog pr;
  double _latitude = 0.0, _longitude = 0.0;
  ScreenshotController screenshotController = ScreenshotController();
  String _filterAnimalType;
  List _infoList = [];
  List _tempAnimalList = [];
  String desc = '';
  String _userLocality = '';
  TextEditingController _locationController = TextEditingController();
  String whatsappText = '';
  ScrollController _scrollController = ScrollController();
  bool _gettingMoreBuyer = false;
  bool _moreDataAvailable = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    dataFillOnInit();
    // _locationController.addListener(() {
    //   _onChanged();
    // });
    _getInitialData();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll <= delta) {
        getInitialInfo();
      }
    });
    super.initState();
  }

  _getInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _latitude = prefs.getDouble('latitude');
      _longitude = prefs.getDouble('longitude');
    });
    getLatLong();
  }

  getLatLong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    getPositionBasedOnLatLong(
            prefs.getDouble('latitude'), prefs.getDouble('longitude'))
        .then((result) {
      setState(() {
        _userLocality = result;
        prefs.setString('place', _userLocality);
      });
    });
  }

  getInitialInfo() async {
    print("called funcrion");
    // pr = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false);

    // pr.style(message: 'progress_dialog_message'.tr);
    // pr.show();

    if (_moreDataAvailable == false) return;
    if (_gettingMoreBuyer == true) return;

    _gettingMoreBuyer = true;

    FirebaseFirestore.instance
        .collection("buyingAnimalList")
        .orderBy("dateOfSaving", descending: true)
        .startAfter(dataSnapshotValue.data['dateOfSaving'])
        .limit(perPage)
        .get(GetOptions(source: Source.serverAndCache))
        .then(
      (value) {
        if (value.docs.length < perPage) {
          setState(() {
            _moreDataAvailable = false;
          });
        }
        List _info = [];
        value.docs.forEach((element) {
          _info.add(element.data());
        });

        dataSnapshotValue = value.docs[value.docs.length - 1];
        setState(() {
          //   widget.animalInfo = _info;
          //   widget.animalInfo.sort((a, b) => _getDistance(
          //           prefs.getDouble('latitude'),
          //           prefs.getDouble('longitude'),
          //           a['userLatitude'],
          //           a['userLongitude'])
          //       .compareTo(_getDistance(
          //           prefs.getDouble('latitude'),
          //           prefs.getDouble('longitude'),
          //           b['userLatitude'],
          //           b['userLongitude'])));
        });
        // pr.hide();
      },
    );

    _gettingMoreBuyer = false;
  }

  dataFillOnInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final myData = await rootBundle.loadString("assets/file/animal_data_1.csv");
    // final myImageData1 =
    //     await PlatformAssetBundle().load("assets/images/image_1");
    // final myImageData2 =
    //     await PlatformAssetBundle().load("assets/images/image_2");
    // final myImageData3 =
    //     await PlatformAssetBundle().load("assets/images/image_3");
    // final myImageData4 =
    // await PlatformAssetBundle().load("assets/images/image_4");
    List<List<dynamic>> data = CsvToListConverter().convert(myData);

    for (int i = 1; i <= data.length - 1; i++) {
      loadAddress(data[i][3].toString());
      // await FirebaseFirestore.instance
      //     .collection("buyingAnimalList")
      //     .doc()
      //     .set({
      //   "userAnimalDescription": data[i][0].toString(),
      //   "userAnimalType": data[i][1].toString(),
      //   "userAnimalAge": data[i][2].toString(),
      //   "userAddress": data[i][3].toString(),
      //   "userName": data[i][4].toString(),
      //   "userAnimalPrice": data[i][5].toString(),
      //   "userAnimalBreed": data[i][6].toString(),
      //   "userMobileNumber": data[i][7].toString(),
      //   "userAnimalMilk": data[i][8].toString(),
      //   "userAnimalPregnancy": data[i][9].toString(),
      //   "userLatitude": prefs.getDouble('userLatitude'),
      //   "userLongitude": prefs.getDouble('userLongitude'),
      //   'position': geo.point(
      //       latitude: prefs.getDouble('userLatitude'),
      //       longitude: prefs.getDouble('userLongitude')).data,

      //   "image1": data[i][10] == null || data[i][10] == ""
      //       ? ""
      //       : data[i][10].toString(),
      //   "image2": data[i][11] == null || data[i][11] == ""
      //       ? ""
      //       : data[i][11].toString(),
      //   "image3": data[i][12] == null || data[i][12] == ""
      //       ? ""
      //       : data[i][12].toString(),
      //   "image4": data[i][13] == null || data[i][13] == ""
      //       ? ""
      //       : data[i][13].toString(),
      //   "dateOfSaving": ReusableWidgets.dateTimeToEpoch(DateTime.now())
      // });
    }
  }

  // String _getDistance(lat1, long1, lat2, long2) {
  //   return (Geodesy().distanceBetweenTwoGeoPoints(
  //             LatLng(lat1, long1),
  //             LatLng(lat2, long2),
  //           ) /
  //           1000)
  //       .toStringAsFixed(0);
  // }

  loadAddress(address) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(address);
    var first = addresses.first;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setDouble("userLatitude", first.coordinates.latitude);
      prefs.setDouble("userLongitude", first.coordinates.longitude);
    });
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

  getPositionBasedOnLatLong(double lat, double long) async {
    final coordinates = new Coordinates(lat, long);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    return first.locality ?? first.featureName;
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
                            : _list[index]['userAnimalBreed'],
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

                    // if (type != 'cow'.tr || type != 'buffalo_female'.tr) {
                    //   _filterDropDownMap.remove('filter2');
                    //   _value = null;
                    // }
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
            Text("कितनी दुरी तक के पशु दिखाए"),
            Wrap(
                children: _radius
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
                                  color: _valueRadius == _radius.indexOf(e)
                                      ? Colors.white
                                      : primaryColor),
                            ),
                            selectedColor: primaryColor,
                            selected: _valueRadius == _radius.indexOf(e),
                            onSelected: (bool selected) {
                              setState1(() {
                                _valueRadius =
                                    selected ? _radius.indexOf(e) : null;
                              });
                            },
                          ),
                        ))
                    .toList()),
          ],
        ),
      );

  // _onChanged() {
  //   if (_sessionToken == null) {
  //     setState(() {
  //       _sessionToken = Uuid().v4();
  //     });
  //   }
  //   getSuggestion(_locationController.text);
  // }

  // void getSuggestion(String input) async {
  //   List _placesList = [];
  //   String baseURL =
  //       'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyAPeAo2d-fIrw24-5ZXEcRECleQnzgRdXk&sessiontoken=$_sessionToken';

  //   var response = await Dio().get(baseURL);
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _placesList = json.decode(response.data);
  //     });
  //   } else {
  //     throw Exception('Failed to load predictions');
  //   }
  // }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    // rebuildAllChildren(context);
    return Scaffold(
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
                      ? ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8, top: 8),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        height: 80,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(children: [
                                            widget.userImage == null ||
                                                    widget.userImage == ""
                                                ? Image.asset(
                                                    'assets/images/profile.jpg',
                                                    width: 40,
                                                    height: 40)
                                                : Image.memory(
                                                    base64Decode(
                                                        widget.userImage),
                                                    width: 40,
                                                    height: 40),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: Text(
                                                _tempAnimalList[index]
                                                    ['userName'],
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14))),
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
                                                          content: Text(
                                                              '${_tempAnimalList[index]['userMobileNumber']} is not present in Whatsapp'),
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
                                                label: Text('message'.tr,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)))
                                          ]),
                                        ))
                                  ],
                                ),
                              )
                              // ),
                              ),
                          itemCount: _tempAnimalList.length)
                      : ListView.builder(
                          controller: _scrollController,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8, top: 8),
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
                                                    ['userName'],
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14))),
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

                                                  whatsappText =
                                                      'नमस्कार भाई साहब, मैंने आपका पशु देखा पशुसंसार पे और आपसे आगे बात करना चाहता हूँ. कब बात कर सकते हैं? ${widget.userName}, ${prefs.getString('place')} \n\nपशुसंसार सूचना - ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन  एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है';
                                                  whatsappUrl =
                                                      "https://api.whatsapp.com/send/?phone=+91 ${widget.animalInfo[index]['userMobileNumber']}&text=$whatsappText";
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
                                                label: Text('message'.tr,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)))
                                          ]),
                                        ))
                                  ],
                                ),
                              )
                              // ),
                              ),
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
                            title: Text("जगह बदले"),
                            content:
                                StatefulBuilder(builder: (context, setState) {
                              return SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextField(
                                      maxLength: 6,
                                      controller: _locationController,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        icon: Container(
                                          margin: EdgeInsets.only(left: 20),
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
                              );
                            }),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text(
                                    'Ok'.tr,
                                    style: TextStyle(color: primaryColor),
                                  ),
                                  onPressed: () async {
                                    if (_locationController.text.length == 0)
                                      Navigator.pop(context);
                                    // return;
                                    else {
                                      if (_locationController.text.length < 6)
                                        ReusableWidgets.showDialogBox(
                                            context,
                                            'error'.tr,
                                            Text('error_length_zipcode'.tr));
                                      // SharedPreferences prefs =
                                      //     await SharedPreferences.getInstance();

                                      var addresses = await Geocoder.local
                                          .findAddressesFromQuery(
                                              _locationController.text);
                                      var first = addresses.first;
                                      // List _data = [];
                                      // widget.animalInfo.map((e) => _data.addIf(
                                      //     (first.locality ??
                                      //             first.featureName) ==
                                      //         _locality,
                                      //     e));
                                      setState(() {
                                        _userLocality =
                                            first.locality ?? first.featureName;
                                        _latitude = first.coordinates.latitude;
                                        _longitude =
                                            first.coordinates.longitude;
                                        // prefs.setDouble('userLatitude',
                                        //     first.coordinates.latitude);
                                        // prefs.setDouble('userLongitude',
                                        //     first.coordinates.longitude);
                                        // _tempAnimalList = _data;
                                      });

                                      pr = new ProgressDialog(context,
                                          type: ProgressDialogType.Normal,
                                          isDismissible: false);

                                      pr.style(
                                          message:
                                              'progress_dialog_message'.tr);
                                      pr.show();

                                      double _radiusData = _valueRadius == 0
                                          ? 25
                                          : _valueRadius == 1
                                              ? 50
                                              : _valueRadius == 2
                                                  ? 75
                                                  : 100;
                                      Stream<
                                          List<
                                              DocumentSnapshot>> stream = geo
                                          .collection(
                                              collectionRef:
                                                  FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          "buyingAnimalList"))
                                          .within(
                                              center: geo.point(
                                                  latitude: first
                                                      .coordinates.latitude,
                                                  longitude: first
                                                      .coordinates.longitude),
                                              radius: _radiusData,
                                              field: 'position',
                                              strictMode: true);

                                      stream.listen((List<DocumentSnapshot>
                                          documentList) {
                                        // doSomething()
                                        print("=-=-=12==" +
                                            documentList.length.toString());
                                        setState(() {
                                          _tempAnimalList = documentList;
                                          // widget.animalInfo = documentList;
                                        });
                                      });
                                      Navigator.pop(context);
                                    }
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
                  onTap: () {
                    return showModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            Container(child: _filterBottomSheet(), height: 250),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        )).then((value) => setState(() {}));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[400])),
                    height: 70,
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
                                text: " " + "animal_filter".tr + "  ",
                                style: TextStyle(color: Colors.black)),
                            WidgetSpan(
                              child: CircleAvatar(
                                backgroundColor: primaryColor,
                                radius: 10,
                                child: Text(
                                    _filterDropDownMap == null ||
                                            _filterDropDownMap == {}
                                        ? '0'
                                        : _filterDropDownMap.length.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
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
    );
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
              child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: violetColor)),
                  color: violetColor,
                  onPressed: () async {
                    Share.share(
                        "Type: ${_list[index]['userAnimalBreed']}\nDescription: ${_list[index]['userAnimalDescription']}\nMilk: ${_list[index]['userAnimalMilk']} Litre",
                        subject: 'Share Animal Info');
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

  _distanceTimeMethod(int index) {
    String val = '';
    List _list =
        _tempAnimalList.length != 0 ? _tempAnimalList : widget.animalInfo;

    // _userLocalityValue(index);
    return StatefulBuilder(builder: (context, setState1) {
      getPositionBasedOnLatLong(
              _list[index]['userLatitude'], _list[index]['userLongitude'])
          .then((result) {
        setState1(() {
          val = result;
        });

        if (!mounted) return;
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
                              _list[index]['dateOfSaving'])),
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
                  text: ' ' + val.toString(),
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
    });
  }

  // _userLocalityValue(index) {
  //   List _list =
  //       _tempAnimalList.length != 0 ? _tempAnimalList : widget.animalInfo;

  //   return getPositionBasedOnLatLong(
  //           _list[index]['userLatitude'], _list[index]['userLongitude'])
  //       .then((result) => setState(() {
  //             _locality = result;
  //           }));
  // }

  String _distanceBetweenTwoCoordinates(int index) {
    List _list =
        _tempAnimalList.length != 0 ? _tempAnimalList : widget.animalInfo;
    return (Geodesy().distanceBetweenTwoGeoPoints(
              LatLng(_latitude, _longitude),
              LatLng(
                  _list[index]['userLatitude'], _list[index]['userLongitude']),
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
                    Expanded(
                      child: Center(
                        child: Container(
                            width: 120,
                            height: 125,
                            color: _index == 0 ? primaryColor : Colors.white,
                            child: GestureDetector(
                              onTap: () => setState(() => _index = 0),
                              child: Center(
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
                            )),
                      ),
                    ),
                    Center(
                      child: SizedBox(width: 1),
                    ),
                    Expanded(
                        child: Center(
                      child: Container(
                          width: 120,
                          height: 125,
                          color: _index == 1 ? primaryColor : Colors.white,
                          child: GestureDetector(
                            onTap: () => setState(() => _index = 1),
                            child: Center(
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
                          )),
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
                                      _tempAnimalList = [];
                                    });

                                    Navigator.pop(context);
                                  },
                                  child: Text('Reset',
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
                                      _tempAnimalList = _data;
                                      // _tempAnimalList.sort((a, b) =>
                                      //     a['userAnimalMilk']
                                      //         .compareTo(b['userAnimalMilk']));
                                    });

                                    Navigator.pop(context);
                                    if (_tempAnimalList.length == 0)
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'चुनाव में एक भी पशु उपलब्ध नहीं है, इसलिए सभी पशु दिखाए जा रहे है |')));
                                  },
                                  child: Text('Apply',
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
