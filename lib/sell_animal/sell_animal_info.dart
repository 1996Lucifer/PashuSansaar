import 'dart:convert';

import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import 'sell_animal_edit_form.dart';
import 'sell_animal_form.dart';

class SellingAnimalInfo extends StatefulWidget {
  final List animalInfo;
  final String userName;
  final String userMobileNumber;

  SellingAnimalInfo({
    Key key,
    @required this.animalInfo,
    @required this.userName,
    @required this.userMobileNumber,
  }) : super(key: key);

  @override
  _SellingAnimalInfoState createState() => _SellingAnimalInfoState();
}

class _SellingAnimalInfoState extends State<SellingAnimalInfo>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSellingFormButton(context),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 30,
                child: Text('your_selling_animal_info'.tr,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
            ),
            // Expanded(
            //     flex: 4,
            //     child: Container(
            //       child:
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.animalInfo.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    key: Key(widget.animalInfo[index]['uuid']),
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
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection: TextDirection.rtl,
                          children: [
                            // FlatButton(
                            //     onPressed: () {},
                            //     child: Row(
                            //       children: [
                            //         Text(
                            //           'see_more_info'.tr,
                            //           style: TextStyle(color: primaryColor),
                            //         ),
                            //         Icon(
                            //           Icons.visibility,
                            //           color: primaryColor,
                            //         )
                            //       ],
                            //     )),
                            FlatButton(
                                onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SellAnimalEditForm(
                                          index: index,
                                          userName: widget.userName,
                                          userMobileNumber:
                                              widget.userMobileNumber,
                                        ),
                                      ),
                                    ),
                                child: Row(
                                  children: [
                                    Text(
                                      'change_info'.tr,
                                      style: TextStyle(
                                          color: primaryColor, fontSize: 15),
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
                          ],
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
    if (widget.animalInfo[index]['animalImages']['image1'] != '') {
      data = widget.animalInfo[index]['animalImages']['image1'];
    } else if (widget.animalInfo[index]['animalImages']['image2'] != '') {
      data = widget.animalInfo[index]['animalImages']['image2'];
    } else if (widget.animalInfo[index]['animalImages']['image3'] != '') {
      data = widget.animalInfo[index]['animalImages']['image3'];
    } else if (widget.animalInfo[index]['animalImages']['image4'] != '') {
      data = widget.animalInfo[index]['animalImages']['image4'];
    }

    return base64Decode(data);
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
        stmn4 = stmn4 + stmn41;
      else
        stmn4 = stmn4 + stmn42;

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
                      fit: BoxFit.cover, image: MemoryImage(_imageData(index))),
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
          // GestureDetector(
          //   onTap: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => SellAnimalEditForm(index: index),
          //     ),
          //   ),
          //   child: Pill(
          //       child: Row(
          //         children: [
          //           Text('change_info'.tr),
          //           Icon(
          //             Icons.edit_sharp,
          //             color: Colors.grey[700],
          //             size: 20,
          //           )
          //         ],
          //       ),
          //       backgroundColor: Colors.grey[300]),
          // )
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
