import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pashusansaar/intersted_buyers/interestedBuyerController.dart';
import 'package:pashusansaar/refresh_token/refresh_token_controller.dart';
import 'package:pashusansaar/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/colors.dart';
import 'utils/reusable_widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class InterestedBuyer extends StatefulWidget {
  final String listId;
  final int index;
  final List animalInfo;
  InterestedBuyer(
      {Key key,
      @required this.listId,
      @required this.animalInfo,
      @required this.index})
      : super(key: key);

  @override
  _InterestedBuyerState createState() => _InterestedBuyerState();
}

class _InterestedBuyerState extends State<InterestedBuyer> {
  final InterestedBuyerController interestedBuyerController =
      Get.put(InterestedBuyerController());
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());

  List interestedBuyers = [];
  SharedPreferences prefs;

  getInitialInfo() async {
    prefs = await SharedPreferences.getInstance();
    bool status;

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
      List data = await interestedBuyerController.interstedBuyers(
        animalId: widget.listId,
        userId: prefs.getString('userId'),
        token: prefs.getString('accessToken'),
        page: 1,
      );

      setState(() {
        interestedBuyers = data;
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
  }

  @override
  void initState() {
    super.initState();
    getInitialInfo();
  }

   _buildBreedTypeWidget(_list) {
    var formatter = intl.NumberFormat('#,##,000');
    return Expanded(
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
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
                            : (_list.animalType <= 4
                            ? intToAnimalTypeMapping[_list.animalType]
                            : intToAnimalOtherTypeMapping[_list.animalType]),
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
      ),
    );
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

  Padding _buildImageDescriptionWidget(double width, _list) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: width * 0.3,
                height: 130.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _list.files[0].fileName.length > 1000
                          ? MemoryImage(base64Decode(_list.files[0].fileName))
                          : NetworkImage(_list.files[0].fileName)),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: Colors.redAccent,
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 12.0, left: 12, top: 15),
                  child: Text(
                    ReusableWidgets.descriptionText(_list),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
                  ),
                ))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
      body: SingleChildScrollView(
        child: widget.animalInfo == []
            ? Center(
                child: Text('noAnimalPresent'.tr,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            : Column(
                children: <Widget>[
                  Container(
                    height: 210,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        // key: Key(
                        //     widget.animalInfo[widget.index]['uniqueId']),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBreedTypeWidget(
                                widget.animalInfo[widget.index]),
                            _buildImageDescriptionWidget(
                                width, widget.animalInfo[widget.index]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Text('interestedBuyer'.tr,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    height: MediaQuery.of(context).size.height - 300,
                    child: interestedBuyers.length == null ||
                            interestedBuyers.isEmpty
                        ? Center(
                            child: Text(
                              'notContactedYet'.tr,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: interestedBuyers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.userAlt,
                                                color: Colors.grey[500],
                                                size: 13,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                interestedBuyers[index]
                                                    .userId
                                                    .name,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.phone,
                                                color: Colors.grey[500],
                                                size: 13,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                interestedBuyers[index]
                                                    .userId
                                                    .mobile
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                          Row(
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
                                                  interestedBuyers[index]
                                                      .userId
                                                      .userAddress,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                            onTap: () {
                                              return UrlLauncher.launch(
                                                  'tel:+91 ${interestedBuyers[index].userId.mobile}');
                                            },
                                            child: FaIcon(
                                              FontAwesomeIcons.phoneAlt,
                                              color: secondaryColor,
                                              size: 30,
                                            ),
                                          )),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                String whatsappText =
                                                    'interestedBuyerWhatsAppText'.trParams({'name':interestedBuyers[index].userId.name});
                                                String whatsappUrl =
                                                    "https://api.whatsapp.com/send/?phone=+91 ${interestedBuyers[index].userId.mobile}&text=$whatsappText";
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
                                                              '${interestedBuyers[index].userId.mobile} is not present in Whatsapp'),
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
                                                        ),
                                                      );
                                              },
                                              child: FaIcon(
                                                FontAwesomeIcons.whatsapp,
                                                color: greenColor,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
      ),
    );
  }
}
