import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'dart:ui' as ui;

class AnimalDescription extends StatefulWidget {
  final String userId;
  final String uniqueId;
  AnimalDescription({
    Key key,
    @required this.userId,
    @required this.uniqueId,
  });

  @override
  _AnimalDescriptionState createState() => _AnimalDescriptionState();
}

int _current = 0;
String whatsappText = '', whatsappUrl = '', _userLocality = '';
File fileUrl;
Map<String, dynamic> _animalInfo = {}, _profileData = {};
ProgressDialog pr;
bool _isLoading = false;

class _AnimalDescriptionState extends State<AnimalDescription> {
  static GlobalKey previewContainer =
      new GlobalKey(debugLabel: 'descriptionPreviewController');
  @override
  void initState() {
    super.initState();
    getAnimalInfo();
  }

  getAnimalInfo() async {
    setState(() {
      _isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('buyingAnimalList1')
        .doc(widget.uniqueId + widget.userId)
        .get()
        .then((value) => setState(() {
              _animalInfo = value.data();
            }))
        .catchError(
          (error) => print(
            'description===>' + error.toString(),
          ),
        );

    await FirebaseFirestore.instance
        .collection('userInfo')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) => setState(() {
              _profileData = value.data();
            }))
        .catchError(
          (error) => print(
            'description-_profileData===>' + error.toString(),
          ),
        );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    return RepaintBoundary(
      key: previewContainer,
      child: Scaffold(
        appBar: ReusableWidgets.getAppBar(context, "app_name".tr, true),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        key: Key(widget.uniqueId),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            _infoText1(),
                            SizedBox(
                              height: 5,
                            ),
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
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Image.asset('assets/images/profile.jpg',
                                          width: 40, height: 40),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _animalInfo['userName'],
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // _getUserData()
                      _getButton(),
                      SizedBox(
                        height: 15,
                      ),
                      _getHomeScreenButton()
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  _getButton() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _getWhatsAppButton(),
            SizedBox(height: 4),
            _getShareButton(),
            SizedBox(height: 4),
            _getCallButton(),
            SizedBox(height: 4),
          ],
        ),
      );

  Widget _infoText1() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: _animalInfo['userAnimalMilk'],
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
                      text: bayaatMapping(_animalInfo['userAnimalPregnancy']),
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
                      text: '₹ ' + _animalInfo['userAnimalPrice'],
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

    setState(() {
      _userLocality = first.subAdminArea ?? first.locality ?? first.featureName;
    });
  }

  Widget _distanceTimeMethod() {
    getPositionBasedOnLatLong(
        _animalInfo['userLatitude'], _animalInfo['userLongitude']);

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
                            _animalInfo['dateOfSaving'])),
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
          _userLocality.length > 20
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: _userLocality,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                )
              : RichText(
                  text: TextSpan(
                    text: _userLocality,
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
          RichText(
            text: TextSpan(
              text: ' (',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
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
  }

  String _distanceBetweenTwoCoordinates() {
    return (Geodesy().distanceBetweenTwoGeoPoints(
              LatLng(_animalInfo['userLatitude'], _animalInfo['userLongitude']),
              LatLng(double.parse(_profileData['latitude']),
                  double.parse(_profileData['longitude'])),
            ) /
            1000)
        .toStringAsFixed(0);
  }

  Widget _infoText2() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _animalInfo['userAnimalDescription'] ?? "",
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600], fontSize: 14.5),
      ),
    );
  }

  _getCallButton() => RaisedButton.icon(
        color: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () => launch("tel://${_animalInfo['userMobileNumber']}"),
        label: Text(
          'call'.tr,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        icon: Icon(
          Icons.phone,
          color: Colors.white,
        ),
      );

  _getWhatsAppButton() => RaisedButton.icon(
        color: darkGreenColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () async {
          whatsappText =
              'नमस्कार भाई साहब, मैंने आपका पशु देखा पशुसंसार पे और आपसे आगे बात करना चाहता हूँ. कब बात कर सकते हैं? ${_animalInfo['userName']}, $_userLocality \n\nपशुसंसार सूचना - ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन  एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है';
          whatsappUrl =
              "https://api.whatsapp.com/send/?phone=+91 ${_animalInfo['userMobileNumber']}&text=$whatsappText";
          await UrlLauncher.canLaunch(whatsappUrl) != null
              ? UrlLauncher.launch(Uri.encodeFull(whatsappUrl))
              : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '${_animalInfo['userMobileNumber']} is not present in Whatsapp'),
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
          size: 16,
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

  _getShareButton() => RaisedButton.icon(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: violetColor,
        onPressed: () async {
          String qParams = json.encode({
            "uniqueId": widget.uniqueId,
            "userId": widget.userId,
            "screen": "DESCRIPTION_PAGE",
          });

          final DynamicLinkParameters parameters = DynamicLinkParameters(
              uriPrefix: "https://pashusansaar.page.link",
              link: Uri.parse("https://www.pashu-sansaar.com/?data=$qParams"),
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

          await takeScreenShot(_animalInfo['uniqueId']);
          Share.shareFiles([fileUrl.path],
              mimeTypes: ['images/png'],
              text:
                  "नस्ल: ${_animalInfo['userAnimalBreed']}\nजानकारी: ${_animalInfo['userAnimalDescription']}\nदूध(प्रति दिन): ${_animalInfo['userAnimalMilk']} Litre\n\nपशु देखे: ${shortUrl.toString()}",
              subject: 'पशु की जानकारी');
        },
        icon: Icon(Icons.share, color: Colors.white, size: 16),
        label: Text(
          'share'.tr,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      );

  _getHomeScreenButton() => Center(
        child: RaisedButton.icon(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: appPrimaryColor,
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
          icon: Icon(Icons.remove_red_eye_outlined,
              color: Colors.white, size: 16),
          label: Text(
            'see_more_animal'.tr,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );

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

  Widget _animalImage() {
    List<String> _images = [];
    [
      _animalInfo['image1'],
      _animalInfo['image2'],
      _animalInfo['image3'],
      _animalInfo['image4'],
    ].forEach((element) =>
        _images.addIf(element != null && element.isNotEmpty, element));
    return Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8, bottom: 4),
        child: GestureDetector(
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
                                  ));
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
        ));
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
