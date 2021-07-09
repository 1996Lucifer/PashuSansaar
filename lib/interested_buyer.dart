import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final InterestedBuyerController interestedBuyerController =
      Get.put(InterestedBuyerController());
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());

  List interestedBuyers = [];
  SharedPreferences prefs;

  getInitialInfo() async {
    prefs = await SharedPreferences.getInstance();
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

    List data = await interestedBuyerController.interstedBuyers(
      animalId: widget.listId,
      userId: prefs.getString('userId'),
      token: prefs.getString('accessToken'),
      page: 1,
    );

    print('user id is: ${prefs.getString('userId')}');
    print('animal id is: ${widget.listId}');
    print('token id is: ${prefs.getString('accessToken')}');

    setState(() {
      interestedBuyers = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitialInfo();
  }

  Padding _buildBreedTypeWidget(_list) {
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
                  text: (_list.animalBreed == 'not_known'.tr
                          ? ""
                          : _list.animalBreed) +
                      ' ',
                  children: <InlineSpan>[
                    TextSpan(
                      text: (_list.animalType == 'other_animal'.tr
                              ? ' '
                              : intToAnimalTypeMapping[_list.animalType]) +
                          ', ',
                      style: TextStyle(
                          color: greyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    TextSpan(
                      text: '₹ ' +
                          formatter
                              .format(int.parse(_list.animalPrice.toString())),
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

  // _imageData(_list) {
  //   var data = '';
  //   if (widget.animalInfo[index]['animalImages'] == null) {
  //     if (widget.animalInfo[index]['image1'].isNotEmpty) {
  //       data = widget.animalInfo[index]['image1'];
  //     } else if (widget.animalInfo[index]['image2'].isNotEmpty) {
  //       data = widget.animalInfo[index]['image2'];
  //     } else if (widget.animalInfo[index]['image3'].isNotEmpty) {
  //       data = widget.animalInfo[index]['image3'];
  //     } else if (widget.animalInfo[index]['image4'].isNotEmpty) {
  //       data = widget.animalInfo[index]['image4'];
  //     } else {
  //       data = widget.animalInfo[index]['animalVideoThumbnail'];
  //     }
  //   } else {
  //     if (widget.animalInfo[index]['animalImages']['image1'].isNotEmpty) {
  //       data = widget.animalInfo[index]['animalImages']['image1'];
  //     } else if (widget
  //         .animalInfo[index]['animalImages']['image2'].isNotEmpty) {
  //       data = widget.animalInfo[index]['animalImages']['image2'];
  //     } else if (widget
  //         .animalInfo[index]['animalImages']['image3'].isNotEmpty) {
  //       data = widget.animalInfo[index]['animalImages']['image3'];
  //     } else if (widget
  //         .animalInfo[index]['animalImages']['image4'].isNotEmpty) {
  //       data = widget.animalInfo[index]['animalImages']['image4'];
  //     } else {
  //       data = widget.animalInfo[index]['animalVideoThumbnail'];
  //     }
  //   }
  //
  //   return data;
  // }

  _descriptionText(_list) {
    String animalBreedCheck =
        (_list.animalBreed == 'not_known'.tr) ? "" : _list.animalBreed;
    String animalTypeCheck = (_list.animalType == 5)
        ? intToAnimalTypeMapping[5]
        : intToAnimalTypeMapping[_list.animalType];

    String desc = '';

    if (_list.animalType == 3 ||
        _list.animalType == 4 ||
        _list.animalType == 5) {
      desc =
          'ये $animalBreedCheck $animalTypeCheck ${_list.animalAge} साल की है। ';
    } else {
      desc =
          'ये ${_list.animalBreed} ${intToAnimalTypeMapping[_list.animalType]} ${_list.animalAge} साल का है। ';
      if (_list.recentBayatTime != null) {
        desc = desc +
            'यह ${intToRecentBayaatTime[_list.recentBayatTime]} ब्यायी है। ';
      }
      if (_list.pregnantTime != null) {
        desc = desc + 'यह अभी ${intToPregnantTime[_list.pregnantTime]} है। ';
      }
      if (_list.animalMilkCapacity != null) {
        desc = desc +
            'पिछले बार के हिसाब से दूध कैपेसिटी ${_list.animalMilkCapacity} लीटर है। ';
      }
    }
    return desc;
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
                    _descriptionText(_list),
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
                    Text('इच्छुक खरीदार की सूचि',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      height: MediaQuery.of(context).size.height - 300,
                      child: interestedBuyers.length == null ||
                              interestedBuyers.isEmpty
                          ? Center(
                              child: Text(
                                'किसी ग्राहक ने अभी तक संपर्क नहीं किया है',
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
                                            )
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
        ));
  }
}

//<<<<<<<<<<<<<<<<<<< Old firebase build >>>>>>>>>>>>>>>>>>>>>>>

//               documentSnapshot
//                       .data()[
//                   'userName'],
//               style: TextStyle(
//                   fontSize: 15,
//                   fontWeight:
//                       FontWeight
//                           .w400),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             FaIcon(
//               FontAwesomeIcons
//                   .clock,
//               color:
//                   Colors.grey[500],
//               size: 13,
//             ),
//             SizedBox(
//               width: 5,
//             ),
//             Text(
//                 ReusableWidgets.epochToDateTime(
//                     documentSnapshot
//                             .data()[
//                         'dateOfSaving']),
//                 style: TextStyle(
//                     fontSize: 15,
//                     fontWeight:
//                         FontWeight
//                             .w400)),
//           ],
//         ),
//         Row(
//           children: [
//             Icon(
//               Icons.location_on,
//               color:
//                   Colors.grey[500],
//               size: 13,
//             ),
//             SizedBox(
//               width: 5,
//             ),
//             Expanded(
//               child: Text(
//                   documentSnapshot
//                           .data()[
//                       'userAddress'],
//                   style: TextStyle(
//                       fontSize: 15,
//                       fontWeight:
//                           FontWeight
//                               .w400)),
//             ),
//           ],
//         ),
//       ],
//     )),
// Expanded(
//   flex: 1,
//   child: Row(
//     children: [
//       Expanded(
//           child: GestureDetector(
//         onTap: () {
//           return UrlLauncher.launch(
//               'tel:+91 ${documentSnapshot.data()['userMobileNumber']}');
//         },
//         child: FaIcon(
//           FontAwesomeIcons.phoneAlt,
//           color: secondaryColor,
//           size: 30,
//         ),
//       )),
//       SizedBox(width: 12),
//       Expanded(
//           child: GestureDetector(
//         onTap: () async {
//           String whatsappText =
//               'नमस्कार ${documentSnapshot.data()['userName']}, आपको मेरा पशु अगर पसंद आया हो तो फ़ोन पे बात करें?';
//           String whatsappUrl =
//               "https://api.whatsapp.com/send/?phone=+91 ${documentSnapshot.data()['userMobileNumber']}&text=$whatsappText";
//           await UrlLauncher.canLaunch(
//                       whatsappUrl) !=
//                   null
//               ? UrlLauncher.launch(
//                   Uri.encodeFull(
//                       whatsappUrl))
//               : ScaffoldMessenger
//                       .of(context)
//                   .showSnackBar(
//                       SnackBar(
//                   content: Text(
//                       '${documentSnapshot.data()['userMobileNumber']} is not present in Whatsapp'),
//                   duration: Duration(
//                       milliseconds:
//                           300),
//                   padding: EdgeInsets
//                       .symmetric(
//                           horizontal:
//                               8),
//                   behavior:
//                       SnackBarBehavior
//                           .floating,
//                   shape:
//                       RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius
//                             .circular(
//                                 10.0),
//                   ),
//                 ));
//         },
//         child: FaIcon(
//           FontAwesomeIcons.whatsapp,
//           color: greenColor,
//           size: 30,
//         ),
//       )),

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     return Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
//         body: SingleChildScrollView(
//           child: widget.animalInfo == []
//               ? Center(
//                   child: Text(
//                     'आपका कोई पशु दर्ज़ नहीं है',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 )
//               : Column(
//                   children: [
//                     Container(
//                       height: 210,
//                       child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Card(
//                               // key: Key(
//                               //     widget.animalInfo[widget.index]['uniqueId']),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               elevation: 5,
//                               child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(widget.animalInfo.toString()),
//                                    //_buildBreedTypeWidget(),
//                                    // _buildImageDescriptionWidget(
//                                     //   width, widget.index),
//                                   ]))),
//                     ),
//                     Text('इच्छुक खरीदार की सूचि',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     Container(
//                       height: MediaQuery.of(context).size.height - 300,
//                       child: PaginateFirestore(
//                           physics: NeverScrollableScrollPhysics(),
//                           itemsPerPage: 10,
//                           initialLoader: Center(
//                             child: CircularProgressIndicator(
//                               backgroundColor: appPrimaryColor,
//                             ),
//                           ),
//                           bottomLoader: Center(
//                             child: CircularProgressIndicator(
//                               backgroundColor: appPrimaryColor,
//                             ),
//                           ),
//                           emptyDisplay: Center(
//                             child: Text(
//                               'किसी ग्राहक ने अभी तक संपर्क नहीं किया है',
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           itemBuilderType: PaginateBuilderType
//                               .listView, // listview and gridview
//                           itemBuilder: (index, context, documentSnapshot) =>
//                               documentSnapshot.data() == null
//                                   ? Center(
//                                       child: Text(
//                                       'किसी ग्राहक ने अभी तक संपर्क नहीं किया है',
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold),
//                                     ))
//                                   : Card(
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Expanded(
//                                                 flex: 3,
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       children: [
//                                                         FaIcon(
//                                                           FontAwesomeIcons
//                                                               .userAlt,
//                                                           color:
//                                                               Colors.grey[500],
//                                                           size: 13,
//                                                         ),
//                                                         SizedBox(
//                                                           width: 5,
//                                                         ),
//                                                         Text(
//                                                           documentSnapshot
//                                                                   .data()[
//                                                               'userName'],
//                                                           style: TextStyle(
//                                                               fontSize: 15,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w400),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     Row(
//                                                       children: [
//                                                         FaIcon(
//                                                           FontAwesomeIcons
//                                                               .clock,
//                                                           color:
//                                                               Colors.grey[500],
//                                                           size: 13,
//                                                         ),
//                                                         SizedBox(
//                                                           width: 5,
//                                                         ),
//                                                         Text(
//                                                             ReusableWidgets.epochToDateTime(
//                                                                 documentSnapshot
//                                                                         .data()[
//                                                                     'dateOfSaving']),
//                                                             style: TextStyle(
//                                                                 fontSize: 15,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w400)),
//                                                       ],
//                                                     ),
//                                                     Row(
//                                                       children: [
//                                                         Icon(
//                                                           Icons.location_on,
//                                                           color:
//                                                               Colors.grey[500],
//                                                           size: 13,
//                                                         ),
//                                                         SizedBox(
//                                                           width: 5,
//                                                         ),
//                                                         Expanded(
//                                                           child: Text(
//                                                               documentSnapshot
//                                                                       .data()[
//                                                                   'userAddress'],
//                                                               style: TextStyle(
//                                                                   fontSize: 15,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w400)),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 )),
//                                             Expanded(
//                                               flex: 1,
//                                               child: Row(
//                                                 children: [
//                                                   Expanded(
//                                                       child: GestureDetector(
//                                                     onTap: () {
//                                                       return UrlLauncher.launch(
//                                                           'tel:+91 ${documentSnapshot.data()['userMobileNumber']}');
//                                                     },
//                                                     child: FaIcon(
//                                                       FontAwesomeIcons.phoneAlt,
//                                                       color: secondaryColor,
//                                                       size: 30,
//                                                     ),
//                                                   )),
//                                                   SizedBox(width: 12),
//                                                   Expanded(
//                                                       child: GestureDetector(
//                                                     onTap: () async {
//                                                       String whatsappText =
//                                                           'नमस्कार ${documentSnapshot.data()['userName']}, आपको मेरा पशु अगर पसंद आया हो तो फ़ोन पे बात करें?';
//                                                       String whatsappUrl =
//                                                           "https://api.whatsapp.com/send/?phone=+91 ${documentSnapshot.data()['userMobileNumber']}&text=$whatsappText";
//                                                       await UrlLauncher.canLaunch(
//                                                                   whatsappUrl) !=
//                                                               null
//                                                           ? UrlLauncher.launch(
//                                                               Uri.encodeFull(
//                                                                   whatsappUrl))
//                                                           : ScaffoldMessenger
//                                                                   .of(context)
//                                                               .showSnackBar(
//                                                                   SnackBar(
//                                                               content: Text(
//                                                                   '${documentSnapshot.data()['userMobileNumber']} is not present in Whatsapp'),
//                                                               duration: Duration(
//                                                                   milliseconds:
//                                                                       300),
//                                                               padding: EdgeInsets
//                                                                   .symmetric(
//                                                                       horizontal:
//                                                                           8),
//                                                               behavior:
//                                                                   SnackBarBehavior
//                                                                       .floating,
//                                                               shape:
//                                                                   RoundedRectangleBorder(
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             10.0),
//                                                               ),
//                                                             ));
//                                                     },
//                                                     child: FaIcon(
//                                                       FontAwesomeIcons.whatsapp,
//                                                       color: greenColor,
//                                                       size: 30,
//                                                     ),
//                                                   )),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                           // orderBy is compulsary to enable pagination
//                           query: FirebaseFirestore.instance
//                               .collection('callingInfo')
//                               // .doc('08303159')
//                               .doc(widget.listId)
//                               .collection('interestedBuyers')
//                               .orderBy('dateOfSaving'),
//                           isLive: false // to fetch real-time data
//                           ),
//                     )
//                   ],
//                 ),
//         ));
//   }
// }
