import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'utils/colors.dart';
import 'utils/reusable_widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:paginate_firestore/paginate_firestore.dart';
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
  Padding _buildBreedTypeWidget(int index) {
    var formatter = intl.NumberFormat('#,##,000');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                      color: greyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  text: (widget.animalInfo[index]['animalInfo']
                                  ['animalBreed'] ==
                              'not_known'.tr
                          ? ""
                          : widget.animalInfo[index]['animalInfo']
                              ['animalBreed']) +
                      ' ',
                  children: <InlineSpan>[
                    TextSpan(
                      text: (widget.animalInfo[index]['animalInfo']
                                      ['animalType'] ==
                                  'other_animal'.tr
                              ? widget.animalInfo[index]['animalInfo']
                                  ['animalTypeOther']
                              : widget.animalInfo[index]['animalInfo']
                                  ['animalType']) +
                          ', ',
                      style: TextStyle(
                          color: greyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: '₹ ' +
                          formatter.format(int.parse(widget.animalInfo[index]
                              ['animalInfo']['animalPrice'])),
                      style: TextStyle(
                          color: greyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    )
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  _imageData(index) {
    var data = '';
    if (widget.animalInfo[index]['animalImages'] == null) {
      if (widget.animalInfo[index]['image1'].isNotEmpty) {
        data = widget.animalInfo[index]['image1'];
      } else if (widget.animalInfo[index]['image2'].isNotEmpty) {
        data = widget.animalInfo[index]['image2'];
      } else if (widget.animalInfo[index]['image3'].isNotEmpty) {
        data = widget.animalInfo[index]['image3'];
      } else if (widget.animalInfo[index]['image4'].isNotEmpty) {
        data = widget.animalInfo[index]['image4'];
      } else {
        data = widget.animalInfo[index]['animalVideoThumbnail'];
      }
    } else {
      if (widget.animalInfo[index]['animalImages']['image1'].isNotEmpty) {
        data = widget.animalInfo[index]['animalImages']['image1'];
      } else if (widget
          .animalInfo[index]['animalImages']['image2'].isNotEmpty) {
        data = widget.animalInfo[index]['animalImages']['image2'];
      } else if (widget
          .animalInfo[index]['animalImages']['image3'].isNotEmpty) {
        data = widget.animalInfo[index]['animalImages']['image3'];
      } else if (widget
          .animalInfo[index]['animalImages']['image4'].isNotEmpty) {
        data = widget.animalInfo[index]['animalImages']['image4'];
      } else {
        data = widget.animalInfo[index]['animalVideoThumbnail'];
      }
    }

    return data;
  }

  _descriptionText(int index) {
    String animalBreedCheck =
        widget.animalInfo[index]['animalInfo']['animalBreed'] == 'not_known'.tr
            ? ""
            : widget.animalInfo[index]['animalInfo']['animalBreed'];
    String animalTypeCheck = widget.animalInfo[index]['animalInfo']
                ['animalType'] ==
            'other_animal'.tr
        ? widget.animalInfo[index]['animalInfo']['animalTypeOther']
        : widget.animalInfo[index]['animalInfo']['animalType'];

    String desc = '';

    String stmn2 =
        'यह ${widget.animalInfo[index]['extraInfo']['animalAlreadyGivenBirth']} ब्यायी है ';
    String stmn3 =
        'और अभी ${widget.animalInfo[index]['extraInfo']['animalIfPregnant']} है। ';
    String stmn4 = '';
    String stmn41 = 'इसके साथ में बच्चा नहीं है| ';
    String stmn42 =
        'इसके साथ में ${widget.animalInfo[index]['extraInfo']['animalHasBaby']}। ';
    String stmn5 =
        'पिछले बार के हिसाब से दूध कैपेसिटी ${widget.animalInfo[index]['animalInfo']['animalMilk']} लीटर है। ';

    if (widget.animalInfo[index]['animalInfo']['animalType'] ==
            'buffalo_male'.tr ||
        widget.animalInfo[index]['animalInfo']['animalType'] == 'ox'.tr ||
        widget.animalInfo[index]['animalType'] == 'other_animal'.tr) {
      desc =
          'ये $animalBreedCheck $animalTypeCheck ${widget.animalInfo[index]['animalInfo']['animalAge']} साल का है। ';
    } else {
      desc =
          'ये $animalBreedCheck $animalTypeCheck ${widget.animalInfo[index]['animalInfo']['animalAge']} साल की है। ';
      if (widget.animalInfo[index]['extraInfo']['animalAlreadyGivenBirth'] !=
          null) desc = desc + stmn2;
      if (widget.animalInfo[index]['extraInfo']['animalIfPregnant'] != null)
        desc = desc + stmn3;
      if (widget.animalInfo[index]['extraInfo']['animalHasBaby'] != null &&
          widget.animalInfo[index]['extraInfo']['animalHasBaby'] ==
              'nothing'.tr)
        stmn4 = stmn4 + stmn42;
      else
        stmn4 = stmn4 + stmn41;

      desc = desc + stmn4;
      desc = desc + stmn5;
    }

    return desc + (widget.animalInfo[index]['extraInfo']['moreInfo'] ?? '');
  }

  Padding _buildImageDescriptionWidget(double width, int index) => Padding(
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
                      image: _imageData(index).length > 1000
                          ? MemoryImage(base64Decode(_imageData(index)))
                          : NetworkImage(_imageData(index))),
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
                    _descriptionText(index),
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
                  child: Text(
                    'आपका कोई पशु दर्ज़ नहीं है',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      height: 210,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              key: Key(
                                  widget.animalInfo[widget.index]['uniqueId']),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildBreedTypeWidget(widget.index),
                                    _buildImageDescriptionWidget(
                                        width, widget.index),
                                  ]))),
                    ),
                    Text('इच्छुक खरीदार की सूचि',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      height: MediaQuery.of(context).size.height - 300,
                      child: PaginateFirestore(
                          physics: NeverScrollableScrollPhysics(),
                          itemsPerPage: 10,
                          initialLoader: Center(
                            child: CircularProgressIndicator(
                              backgroundColor: appPrimaryColor,
                            ),
                          ),
                          bottomLoader: Center(
                            child: CircularProgressIndicator(
                              backgroundColor: appPrimaryColor,
                            ),
                          ),
                          emptyDisplay: Center(
                            child: Text(
                              'किसी ग्राहक ने अभी तक संपर्क नहीं किया है',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          itemBuilderType: PaginateBuilderType
                              .listView, // listview and gridview
                          itemBuilder: (index, context, documentSnapshot) =>
                              documentSnapshot.data() == null
                                  ? Center(
                                      child: Text(
                                      'किसी ग्राहक ने अभी तक संपर्क नहीं किया है',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ))
                                  : Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        FaIcon(
                                                          FontAwesomeIcons
                                                              .userAlt,
                                                          color:
                                                              Colors.grey[500],
                                                          size: 13,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          documentSnapshot
                                                                  .data()[
                                                              'userName'],
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        FaIcon(
                                                          FontAwesomeIcons
                                                              .clock,
                                                          color:
                                                              Colors.grey[500],
                                                          size: 13,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                            ReusableWidgets.epochToDateTime(
                                                                documentSnapshot
                                                                        .data()[
                                                                    'dateOfSaving']),
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400)),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          color:
                                                              Colors.grey[500],
                                                          size: 13,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                              documentSnapshot
                                                                      .data()[
                                                                  'userAddress'],
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: GestureDetector(
                                                    onTap: () {
                                                      return UrlLauncher.launch(
                                                          'tel:+91 ${documentSnapshot.data()['userMobileNumber']}');
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
                                                          'नमस्कार ${documentSnapshot.data()['userName']}, आपको मेरा पशु अगर पसंद आया हो तो फ़ोन पे बात करें?';
                                                      String whatsappUrl =
                                                          "https://api.whatsapp.com/send/?phone=+91 ${documentSnapshot.data()['userMobileNumber']}&text=$whatsappText";
                                                      await UrlLauncher.canLaunch(
                                                                  whatsappUrl) !=
                                                              null
                                                          ? UrlLauncher.launch(
                                                              Uri.encodeFull(
                                                                  whatsappUrl))
                                                          : ScaffoldMessenger
                                                                  .of(context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                              content: Text(
                                                                  '${documentSnapshot.data()['userMobileNumber']} is not present in Whatsapp'),
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
                                                    child: FaIcon(
                                                      FontAwesomeIcons.whatsapp,
                                                      color: greenColor,
                                                      size: 30,
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          // orderBy is compulsary to enable pagination
                          query: FirebaseFirestore.instance
                              .collection('callingInfo')
                              // .doc('08303159')
                              .doc(widget.listId)
                              .collection('interestedBuyers')
                              .orderBy('dateOfSaving'),
                          isLive: false // to fetch real-time data
                          ),
                    )
                  ],
                ),
        ));
  }
}
