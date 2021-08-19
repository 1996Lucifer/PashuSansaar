import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/rendering.dart';
import 'package:pashusansaar/animal_description/animal_description_controller.dart';
import 'package:pashusansaar/animal_description/animal_description_model.dart';
import 'package:pashusansaar/refresh_token/refresh_token_controller.dart';
import 'package:pashusansaar/seller_contact/seller_contact_controller.dart';
import 'package:pashusansaar/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:intl/intl.dart' as intl;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geodesy/geodesy.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:share/share.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:video_player/video_player.dart';

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
Animal animalDesc;
ProgressDialog pr;
bool _isLoading = false;
double lat, long;

class _AnimalDescriptionState extends State<AnimalDescription> {
  static GlobalKey previewContainer =
      new GlobalKey(debugLabel: 'descriptionPreviewController');

  @override
  void initState() {
    super.initState();
    getAnimalInfo();
  }

  var formatter = intl.NumberFormat('#,##,000');
  bool _isLoadingScreen = false;
  VideoPlayerController _videoController;

  final AnimalDescriptionController animalDescriptionController =
      Get.put(AnimalDescriptionController());
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());
  final SellerContactController sellerContactController =
      Get.put(SellerContactController());

  getAnimalInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool status;
    setState(() {
      _isLoading = true;
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

    lat = prefs.getDouble('latitude');
    long = prefs.getDouble('longitude');

    try {
      Animal data = await animalDescriptionController.animalDescription(
        animalId: widget.uniqueId,
        senderUserId: widget.userId,
        userId: prefs.getString('userId'),
        accessToken: prefs.getString('accessToken') ?? '',
      );
      print('animalId is ${widget.uniqueId}');
      print('sender userId is ${widget.userId}');
      print('userId is ${prefs.getString('userId')}');
      print('accessToken is ${prefs.getString('accessToken')}');
      print('data we are receiving is $data');

      if (mounted) {
        setState(() {
          animalDesc = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      ReusableWidgets.loggerFunction(
        fileName: 'animal_description',
        error: e.toString(),
        myNum: prefs.getString('userId'),
        userId: prefs.getString('userId'),
      );
      // ReusableWidgets.showDialogBox(
      //   context,
      //   'warning'.tr,
      //   Text(
      //     'global_error'.tr,
      //   ),
      // );
    }

    // try {
    //   myNum = await sellerContactController.getSellerContact(
    //       animalId: widget.uniqueId,
    //       userId: prefs.getString('userId'),
    //       token: prefs.getString('accessToken'),
    //       channel: [
    //         {"contactMedium": "Call"}
    //       ]);
    // } catch (e) {
    // ReusableWidgets.showDialogBox(
    //   context,
    //   'warning'.tr,
    //   Text(
    //     'global_error'.tr,
    //   ),
    // );
    // }
  }

  getSellerContacts(BuildContext context, String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      int myNum;
      myNum = await sellerContactController.getSellerContact(
          animalId: widget.uniqueId,
          userId: prefs.getString('userId'),
          token: prefs.getString('accessToken'),
          channel: [
            {"contactMedium": mode}
          ]);
      return myNum;
    } catch (e) {
      ReusableWidgets.showDialogBox(
        context,
        'warning'.tr,
        Text(
          'global_error'.tr,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    return RepaintBoundary(
      key: previewContainer,
      child: Scaffold(
        appBar: ReusableWidgets.getAppBar(context, "app_name".tr, true),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : animalDesc == null
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'animalSoldOut'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      _getHomeScreenButton()
                    ],
                  ))
                : (SingleChildScrollView(
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
                                _buildInfowidget(animalDesc),
                                SizedBox(
                                  height: 5,
                                ),
                                _distanceTimeMethod(),
                                SizedBox(
                                  height: 10,
                                ),
                                _animalImage(animalDesc),
                                SizedBox(
                                  height: 10,
                                ),
                                ReusableWidgets.animalDescriptionMethod(
                                    animalDesc),
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
                                          Image.asset(
                                              'assets/images/profile.jpg',
                                              width: 40,
                                              height: 40),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            animalDesc.userName,
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
                          _getButton(),
                          SizedBox(
                            height: 15,
                          ),
                          _getHomeScreenButton()
                        ],
                      ),
                    ),
                  )),
      ),
    );
  }

  _getButton() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: (_isLoadingScreen)
            ? Center(
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white),
                    height: 100,
                    width: 100,
                    child: Center(child: CircularProgressIndicator())))
            : Row(
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

  Row _buildInfowidget(_list) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: RichText(
            textAlign: TextAlign.center,
            text: _list.animalType == 1 || _list.animalType == 2
                ? TextSpan(
                    text: _list.animalMilk.toString(),
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
                            intToAnimalBayaatMapping[_list.animalBayat],
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
                          text: '₹ ' + formatter.format(_list.animalPrice) ?? 0,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ])
                : TextSpan(
                    text: _list.animalBreed == 'not_known'.tr
                        ? ""
                        : ReusableWidgets.removeEnglishDataFromName(
                            _list.animalBreed),
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
                          text: _list.animalType <= 4
                              ? intToAnimalTypeMapping[_list.animalType]
                              : intToAnimalOtherTypeMapping[_list.animalType],
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        TextSpan(
                          text:
                              ', ₹ ' + formatter.format(_list.animalPrice) ?? 0,
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
    getPositionBasedOnLatLong(animalDesc.latitude, animalDesc.longitude);

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
                text:
                    ' ' + ReusableWidgets.dateDifference(animalDesc.createdAt),
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
          _userLocality.toString().length > 20
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: _userLocality.toString(),
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                )
              : RichText(
                  text: TextSpan(
                    text: _userLocality.toString(),
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
              LatLng(animalDesc.latitude, animalDesc.longitude),
              LatLng(lat, long),
              //LatLng(animalDesc.location.coordinates[0], animalDesc.location.coordinates[1]),
            ) /
            1000)
        .toStringAsFixed(0);
  }

  _getCallButton() => RaisedButton.icon(
        color: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: () {
          int myNum = getSellerContacts(context, "Call");
          return UrlLauncher.launch('tel:+91 $myNum');
        },
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
          int myNum = getSellerContacts(context, "Whatsapp");

          whatsappText =
              'नमस्कार भाई साहब, मैंने आपका पशु देखा पशुसंसार पे और आपसे आगे बात करना चाहता हूँ. कब बात कर सकते हैं? ${animalDesc.userName}, $_userLocality \n\nपशुसंसार सूचना - ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन  एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें वरना नुकसान हो सकता है';
          whatsappUrl =
              "https://api.whatsapp.com/send/?phone=+91 $myNum&text=$whatsappText";
          await UrlLauncher.canLaunch(whatsappUrl) != null
              ? UrlLauncher.launch(Uri.encodeFull(whatsappUrl))
              : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('$myNum is not present in Whatsapp'),
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

          await takeScreenShot(animalDesc.sId);
          Share.shareFiles([fileUrl.path],
              mimeTypes: ['images/png'],
              text: animalDesc.animalType <= 2
                  ? "नस्ल: ${animalDesc.animalBreed}\nजानकारी: ${ReusableWidgets.descriptionText(animalDesc) == null ? 'जानकारी उपलब्ध नहीं है|' : ReusableWidgets.descriptionText(animalDesc)}\nदूध(प्रति दिन): ${animalDesc.animalMilkCapacity} Litre\n\nपशु देखे: ${shortUrl.toString()}"
                  : (animalDesc.animalType <= 4
                      ? ("नस्ल: ${animalDesc.animalBreed}\nजानकारी: ${ReusableWidgets.descriptionText(animalDesc) == null ? 'जानकारी उपलब्ध नहीं है|' : ReusableWidgets.descriptionText(animalDesc)}\n\nपशु देखे: ${shortUrl.toString()}")
                      : ("जानकारी: ${ReusableWidgets.descriptionText(animalDesc) == null ? 'जानकारी उपलब्ध नहीं है|' : ReusableWidgets.descriptionText(animalDesc)}\n\nपशु देखे: ${shortUrl.toString()}")),
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
    setState(() {
      _isLoadingScreen = true;
    });
    RenderRepaintBoundary boundary =
        previewContainer.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    File imgFile = new File(
        '$directory/pashu_${ReusableWidgets.dateTimeToEpoch(DateTime.now())}.png');
    await imgFile.writeAsBytes(pngBytes);
    setState(() {
      _isLoadingScreen = false;
      fileUrl = imgFile;
    });
  }

  Widget _animalImage(_list) {
    List<String> _images = [], _videos = [], _videoImageList = [];
    _list.files
        .forEach((elem) => _images.addIf(elem.fileName != null, elem.fileName));
    _list.files?.forEach(
      (elem) => _images.addIf(elem.fileName != null, elem.fileName),
    );
    _videoImageList = List.from(_videos)..addAll(_images);

    return Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 4.0,
      ),
      child: Stack(
        children: [
          WillPopScope(
            onWillPop: () async {
              if (_videoController != null) {
                _videoController.dispose();
              }
              return false;
            },
            child: GestureDetector(
              onTap: () async {
                if (_videoController != null) _videoController.pause();
                if (_videos.length != 0) {
                  pr.style(
                      message: 'video_loading_message'.tr,
                      messageTextStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500));
                  // pr.show();

                  if (_videoController != null) _videoController.dispose();

                  _videoController =
                      VideoPlayerController.network(_videoImageList[0]);
                  await _videoController.initialize();
                  _videoController.setLooping(false);
                  // pr.hide();
                  _videoController.play();
                }

                return Navigator.of(context).push(
                  PageRouteBuilder(
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
                              autoPlay: _videos.isEmpty ? true : false,
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
                            items: _videoImageList.map((i) {
                              return i.split('/')[4].split('_')[1] == "Video"
                                  ? Stack(
                                      alignment:
                                          AlignmentDirectional.bottomCenter,
                                      children: [
                                        _videoController == null
                                            ? SizedBox.shrink()
                                            : ValueListenableBuilder(
                                                valueListenable:
                                                    _videoController,
                                                builder: (context,
                                                        VideoPlayerValue value,
                                                        child) =>
                                                    Center(
                                                  child: StreamBuilder<Object>(
                                                      stream: null,
                                                      builder:
                                                          (context, snapshot) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            if (!_videoController
                                                                    .value
                                                                    .isPlaying &&
                                                                value.position
                                                                        .compareTo(
                                                                            value.duration) ==
                                                                    0) {
                                                              _videoController
                                                                  .initialize();
                                                            }
                                                            setState(() {
                                                              _videoController
                                                                      .value
                                                                      .isPlaying
                                                                  ? _videoController
                                                                      .pause()
                                                                  : _videoController
                                                                      .play();
                                                            });
                                                          },
                                                          child: AspectRatio(
                                                            aspectRatio:
                                                                _videoController
                                                                    .value
                                                                    .aspectRatio,
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                VideoPlayer(
                                                                    _videoController),
                                                                _videoController
                                                                        .value
                                                                        .isPlaying
                                                                    ? SizedBox
                                                                        .shrink()
                                                                    : Icon(
                                                                        Icons
                                                                            .play_circle_fill,
                                                                        color: Colors
                                                                            .grey[800],
                                                                        size:
                                                                            80,
                                                                      ),
                                                              ],
                                                            ),
                                                            // ),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ),
                                        _videoController == null
                                            ? SizedBox.shrink()
                                            : ValueListenableBuilder(
                                                valueListenable:
                                                    _videoController,
                                                builder: (context,
                                                        VideoPlayerValue value,
                                                        child) =>
                                                    Row(
                                                  children: [
                                                    Card(
                                                      color: Colors.transparent,
                                                      child: IconButton(
                                                        icon: Icon(
                                                          _videoController.value
                                                                  .isPlaying
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () =>
                                                            setState(() {
                                                          if (value.duration ==
                                                              null)
                                                            ReusableWidgets
                                                                .showDialogBox(
                                                              context,
                                                              'error'.tr,
                                                              Text('Error'),
                                                            );
                                                          if (!_videoController
                                                                  .value
                                                                  .isPlaying &&
                                                              value.position
                                                                      .compareTo(
                                                                          value
                                                                              .duration) ==
                                                                  0) {
                                                            _videoController
                                                                .initialize();
                                                          }
                                                          _videoController.value
                                                                  .isPlaying
                                                              ? _videoController
                                                                  .pause()
                                                              : _videoController
                                                                  .play();
                                                        }),
                                                      ),
                                                    ),
                                                    Card(
                                                      color: Colors.transparent,
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        child:
                                                            VideoProgressIndicator(
                                                          _videoController,
                                                          colors:
                                                              VideoProgressColors(
                                                            playedColor:
                                                                Colors.white,
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  20),
                                                          allowScrubbing: true,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Card(
                                                      color: Colors.transparent,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 11.0,
                                                                horizontal: 5),
                                                        child: Text(
                                                            ReusableWidgets
                                                                    .printDuration(
                                                                        value
                                                                            .position)
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                        GestureDetector(
                                          onTap: () {
                                            if (_videos.length != 0) {
                                              _videoController.pause();
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                            } else if (_images.length != 0) {
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16.0,
                                                    left: 8,
                                                    right: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    _buildInfowidget(_list),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Icon(
                                                      Icons.cancel,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: '$i',
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                            child: CircularProgressIndicator(
                                              value: downloadProgress.progress,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            size: 60,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (_videos.length != 0) {
                                              _videoController.pause();
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                            } else if (_images.length != 0) {
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 16.0,
                                                  left: 8,
                                                  right: 8,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    _buildInfowidget(_list),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Icon(
                                                      Icons.cancel,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                            }).toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _videoImageList.map((url) {
                              int indexData = _videoImageList.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 2.0,
                                ),
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
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 200.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: _videos.length != 0 ? _videos[1] : _images[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: Image.asset(
                            'assets/images/loader.gif',
                            height: 80,
                            width: 80,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                  _videos.isNotEmpty
                      ? Icon(
                          Icons.play_circle_outline_sharp,
                          size: 100,
                          color: appPrimaryColor,
                        )
                      : SizedBox.shrink()
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: violetColor),
              ),
              color: violetColor,
              onPressed: () async {
                String qParams = json.encode({
                  "uniqueId": _list.sId,
                  "userId": _list.userId,
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

                await takeScreenShot(_list.sId);

                // Share.share(
                //     "नस्ल: ${_list.animalBreed}\nजानकारी: description\nदूध(प्रति दिन): ${_list.animalMilk} Litre\n\nऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar}",
                //     subject: 'animal_info'.tr);

                Share.shareFiles([fileUrl.path],
                    mimeTypes: ['images/png'],
                    text:
                        // "नस्ल: ${_list['userAnimalBreed']}\nजानकारी: ${_list['userAnimalDescription']}\nदूध(प्रति दिन): ${_list['userAnimalMilk']} Litre\n\nऍप डाउनलोड  करे : https://play.google.com/store/apps/details?id=dj.pashusansaar}",
                        _list.animalType <= 2
                            ? "नस्ल: ${_list.animalBreed}\nजानकारी: ${ReusableWidgets.descriptionText(_list) == null ? 'जानकारी उपलब्ध नहीं है|' : ReusableWidgets.descriptionText(_list)}\n${_list.animalMilkCapacity != null || _list.animalMilk != null ? 'दूध(प्रति दिन): ${_list.animalMilkCapacity ?? _list.animalMilk} Litre' : ''}\n\nपशु देखे: ${shortUrl.toString()}"
                            : (_list.animalType <= 4
                                ? ("नस्ल: ${_list.animalBreed}\nजानकारी: ${ReusableWidgets.descriptionText(_list) == null ? 'जानकारी उपलब्ध नहीं है|' : ReusableWidgets.descriptionText(_list)}\n\nपशु देखे: ${shortUrl.toString()}")
                                : ("जानकारी: ${ReusableWidgets.descriptionText(_list) == null ? 'जानकारी उपलब्ध नहीं है|' : ReusableWidgets.descriptionText(_list)}\n\nपशु देखे: ${shortUrl.toString()}")),
                    subject: 'पशु की जानकारी');

                // Share.share(shortUrl.toString());
              },
              icon: Icon(Icons.share, color: Colors.white, size: 14),
              label: Text(
                'share'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
