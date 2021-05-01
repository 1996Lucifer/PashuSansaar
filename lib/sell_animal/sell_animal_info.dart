import 'dart:convert';

import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:video_player/video_player.dart';

import '../interested_buyer.dart';
import 'sell_animal_edit_form.dart';
import 'sell_animal_form.dart';

class SellingAnimalInfo extends StatefulWidget {
  final List animalInfo;
  final String userName;
  final String userMobileNumber;
  final bool showExtraData;

  SellingAnimalInfo({
    Key key,
    @required this.animalInfo,
    @required this.userName,
    @required this.userMobileNumber,
    @required this.showExtraData,
  }) : super(key: key);

  @override
  _SellingAnimalInfoState createState() => _SellingAnimalInfoState();
}

class _SellingAnimalInfoState extends State<SellingAnimalInfo>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController _videoController;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: !widget.showExtraData && (widget.animalInfo.length == 0)
            ? Center(
                child: Column(
                  children: [
                    Text(
                      'आपका कोई पशु दर्ज़ नहीं है| कृपया पशु दर्ज़ करे',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    _buildSellingFormButton(context)
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.showExtraData
                      ? _buildSellingFormButton(context)
                      : SizedBox.shrink(),
                  widget.showExtraData
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            child: Text('your_selling_animal_info'.tr,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),
                        )
                      : SizedBox.shrink(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.animalInfo.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          key: Key(widget.animalInfo[index]['uniqueId']),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBreedTypeWidget(index),
                              _buildDateWidget(index),
                              _buildImageDescriptionWidget(width, index),
                              widget.showExtraData
                                  ? Row(
                                      textDirection: TextDirection.rtl,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FlatButton(
                                            onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SellAnimalEditForm(
                                                      index: index,
                                                      userName: widget.userName,
                                                      userMobileNumber: widget
                                                          .userMobileNumber,
                                                    ),
                                                  ),
                                                ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'change_info'.tr,
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                FaIcon(
                                                  FontAwesomeIcons.edit,
                                                  color: primaryColor,
                                                  size: 16,
                                                )
                                              ],
                                            )),
                                        FlatButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InterestedBuyer(
                                                          listId: widget.animalInfo[
                                                                      index][
                                                                  'uniqueId'] ??
                                                              '',
                                                          index: index,
                                                          animalInfo:
                                                              widget.animalInfo,
                                                        ))),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'इच्छुक खरीदार की सूचि',
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                FaIcon(
                                                  FontAwesomeIcons.arrowRight,
                                                  color: primaryColor,
                                                  size: 16,
                                                )
                                              ],
                                            )),
                                      ],
                                    )
                                  : GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  InterestedBuyer(
                                                    listId:
                                                        widget.animalInfo[index]
                                                                ['uniqueId'] ??
                                                            '',
                                                    index: index,
                                                    animalInfo:
                                                        widget.animalInfo,
                                                  ))),
                                      child: Container(
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
                                        height: 50,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("इच्छुक खरीदार की सूचि देखे",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Icon(Icons.arrow_forward_ios)
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // ))
                ],
              ),
      ),
    );
  }

  _imageData(index) {
    var data = '';
    if (widget.animalInfo[index]['animalVideoThumbnail'] == null) {
      if (widget.animalInfo[index]['animalImages']['image1'] != '') {
        data = widget.animalInfo[index]['animalImages']['image1'];
      } else if (widget.animalInfo[index]['animalImages']['image2'] != '') {
        data = widget.animalInfo[index]['animalImages']['image2'];
      } else if (widget.animalInfo[index]['animalImages']['image3'] != '') {
        data = widget.animalInfo[index]['animalImages']['image3'];
      } else if (widget.animalInfo[index]['animalImages']['image4'] != '') {
        data = widget.animalInfo[index]['animalImages']['image4'];
      }
    } else {
      data = widget.animalInfo[index]['animalVideoThumbnail'];
      // _videoController =
      //     VideoPlayerController.network(widget.animalInfo[index]['video']);
      // _videoController.setLooping(false);
      // _videoController.initialize();
      // _videoController.pause();
    }

    return data;
  }

  // _descriptionText(int index) {
  //   String animalBreedCheck =
  //       widget.animalInfo[index]['animalInfo']['animalBreed'] == 'not_known'.tr
  //           ? ""
  //           : widget.animalInfo[index]['animalInfo']['animalBreed'];
  //   String animalTypeCheck = widget.animalInfo[index]['animalInfo']
  //               ['animalType'] ==
  //           'other_animal'.tr
  //       ? widget.animalInfo[index]['animalInfo']['animalTypeOther']
  //       : widget.animalInfo[index]['animalInfo']['animalType'];

  //   String desc = '';

  //   String stmn2 =
  //       'यह ${widget.animalInfo[index]['extraInfo']['animalAlreadyGivenBirth']} ब्यायी है ';
  //   String stmn3 =
  //       'और अभी ${widget.animalInfo[index]['extraInfo']['animalIfPregnant']} है। ';
  //   String stmn4 = '';
  //   String stmn41 = 'इसके साथ में बच्चा नहीं है| ';
  //   String stmn42 =
  //       'इसके साथ में ${widget.animalInfo[index]['extraInfo']['animalHasBaby']}। ';
  //   String stmn5 =
  //       'पिछले बार के हिसाब से दूध कैपेसिटी ${widget.animalInfo[index]['animalInfo']['animalMilk']} लीटर है। ';

  //   if (widget.animalInfo[index]['animalInfo']['animalType'] ==
  //           'buffalo_male'.tr ||
  //       widget.animalInfo[index]['animalInfo']['animalType'] == 'ox'.tr ||
  //       widget.animalInfo[index]['animalType'] == 'other_animal'.tr) {
  //     desc =
  //         'ये $animalBreedCheck $animalTypeCheck ${widget.animalInfo[index]['animalInfo']['animalAge']} साल का है। ';
  //   } else {
  //     desc =
  //         'ये $animalBreedCheck $animalTypeCheck ${widget.animalInfo[index]['animalInfo']['animalAge']} साल की है। ';
  //     if (widget.animalInfo[index]['extraInfo']['animalAlreadyGivenBirth'] !=
  //         null) desc = desc + stmn2;
  //     if (widget.animalInfo[index]['extraInfo']['animalIfPregnant'] != null)
  //       desc = desc + stmn3;
  //     if (widget.animalInfo[index]['extraInfo']['animalHasBaby'] != null &&
  //         widget.animalInfo[index]['extraInfo']['animalHasBaby'] ==
  //             'nothing'.tr)
  //       stmn4 = stmn4 + stmn42;
  //     else
  //       stmn4 = stmn4 + stmn41;

  //     desc = desc + stmn4;
  //     desc = desc + stmn5;
  //   }

  //   return desc + (widget.animalInfo[index]['extraInfo']['moreInfo'] ?? '');
  // }

  Padding _buildImageDescriptionWidget(double width, int index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _imageData(index).length > 1000
                  ? Container(
                      width: width * 0.3,
                      height: 130.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image:
                                MemoryImage(base64Decode(_imageData(index)))),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: Colors.redAccent,
                      ),
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: width * 0.3,
                          height: 130.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(_imageData(index))),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            color: Colors.redAccent,
                          ),
                        ),
                        // Icon(
                        //   Icons.play_circle_outline_outlined,
                        //   color: Colors.grey,
                        //   size: 45,
                        // ),
                      ],
                    ),
            )
            // WillPopScope(
            //   onWillPop: () async {
            //     setState(() {
            //       _videoController.pause();
            //     });
            //     return true;
            //   },
            //   child: GestureDetector(
            //     onTap: () {
            //       Navigator.of(context).push(
            //         PageRouteBuilder(
            //           opaque: true,
            //           pageBuilder: (BuildContext context, _, __) =>
            //               StatefulBuilder(
            //                   builder: (context, setState) => widget
            //                                       .animalInfo[index]
            //                                   ['animalVideoThumbnail'] ==
            //                               null ||
            //                           widget.animalInfo[index]
            //                                   ['animalVideoThumbnail'] ==
            //                               ''
            //                       ? SizedBox.shrink()
            //                       : Expanded(
            //                           flex: 1,
            //                           child: Stack(
            //                             alignment:
            //                                 AlignmentDirectional.bottomCenter,
            //                             children: [
            //                               Center(
            //                                   child: StreamBuilder<Object>(
            //                                       stream: null,
            //                                       builder: (context, snapshot) {
            //                                         return VideoPlayer(
            //                                             _videoController);
            //                                       })),
            //                               _videoController == null
            //                                   ? SizedBox.shrink()
            //                                   : ValueListenableBuilder(
            //                                       valueListenable:
            //                                           _videoController,
            //                                       builder: (context,
            //                                               VideoPlayerValue
            //                                                   value,
            //                                               child) =>
            //                                           Row(
            //                                         children: [
            //                                           Card(
            //                                             color:
            //                                                 Colors.transparent,
            //                                             child: IconButton(
            //                                                 icon: Icon(
            //                                                   _videoController
            //                                                           .value
            //                                                           .isPlaying
            //                                                       ? Icons.pause
            //                                                       : Icons
            //                                                           .play_arrow,
            //                                                 ),
            //                                                 onPressed: () =>
            //                                                     setState(() {
            //                                                       if (!_videoController
            //                                                               .value
            //                                                               .isPlaying &&
            //                                                           value.position
            //                                                                   .compareTo(value.duration) ==
            //                                                               0) {
            //                                                         _videoController
            //                                                             .initialize();
            //                                                       }
            //                                                       _videoController
            //                                                               .value
            //                                                               .isPlaying
            //                                                           ? _videoController
            //                                                               .pause()
            //                                                           : _videoController
            //                                                               .play();
            //                                                     })),
            //                                           ),
            //                                           Container(
            //                                             width: MediaQuery.of(
            //                                                         context)
            //                                                     .size
            //                                                     .width *
            //                                                 0.6,
            //                                             child:
            //                                                 VideoProgressIndicator(
            //                                                     _videoController,
            //                                                     allowScrubbing:
            //                                                         true),
            //                                           ),
            //                                           SizedBox(
            //                                             width: 10,
            //                                           ),
            //                                           Text(
            //                                               ReusableWidgets
            //                                                       .printDuration(
            //                                                           value
            //                                                               .position)
            //                                                   .toString(),
            //                                               style: TextStyle(
            //                                                   color:
            //                                                       primaryColor,
            //                                                   fontSize: 15))
            //                                         ],
            //                                       ),
            //                                     ),
            //                             ],
            //                           ),
            //                         )),
            //         ),
            //       );
            //     },
            //     child: _imageData(index).length > 1000
            //         ? Container(
            //             width: width * 0.3,
            //             height: 130.0,
            //             decoration: BoxDecoration(
            //               image: DecorationImage(
            //                   fit: BoxFit.cover,
            //                   image:
            //                       MemoryImage(base64Decode(_imageData(index)))),
            //               borderRadius: BorderRadius.all(Radius.circular(8.0)),
            //               color: Colors.redAccent,
            //             ),
            //           )
            //         : Stack(
            //             alignment: Alignment.center,
            //             children: [
            //               Container(
            //                 width: width * 0.3,
            //                 height: 130.0,
            //                 decoration: BoxDecoration(
            //                   image: DecorationImage(
            //                       fit: BoxFit.cover,
            //                       image: NetworkImage(_imageData(index))),
            //                   borderRadius:
            //                       BorderRadius.all(Radius.circular(8.0)),
            //                   color: Colors.redAccent,
            //                 ),
            //               ),
            //               Icon(
            //                 Icons.play_circle_outline_outlined,
            //                 color: Colors.grey,
            //                 size: 45,
            //               ),
            //             ],
            //           ),
            //   ),
            // ),
            ,
            Expanded(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 12.0, left: 12, top: 15),
                  child: Text(
                    widget.animalInfo[index]['animalDescription'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16),
                  ),
                ))
          ],
        ),
      );

  Padding _buildDateWidget(int index) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style:
                TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
            text: ReusableWidgets.epochToDateTime(
                    widget.animalInfo[index]['dateOfSaving']) +
                ' ',
            children: <InlineSpan>[
              TextSpan(
                text: ' (' +
                    ReusableWidgets.dateDifference(
                        ReusableWidgets.epochToDateTime(
                            widget.animalInfo[index]['dateOfSaving'])) +
                    ')',
                style: TextStyle(
                    color: Colors.grey[500], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

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

  Padding _buildSellingFormButton(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Column(
            children: [
              Text('animal_selling_form'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/left-to-right.jpg',
                      height: 40,
                      width: 40,
                    ),
                    Padding(
                      padding: EdgeInsets.all(1),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.55,
                        child: RaisedButton(
                          color: primaryColor,
                          padding: EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 5,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SellAnimalForm(
                                      userName: widget.userName,
                                      userMobileNumber: widget.userMobileNumber,
                                    )),
                          ),
                          child: Text(
                            'sell_more_animal_button'.tr,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/right-to-left.jpg',
                      height: 40,
                      width: 40,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
