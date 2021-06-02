import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:progress_dialog/progress_dialog.dart';

import '../home_screen.dart';
import '../interested_buyer.dart';
import 'remove_animal.dart';
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
  bool _isError = false, _isErrorEmpty = false;
  String _price = '';
  TextEditingController _controller = TextEditingController();
  ProgressDialog pr;

  static const _locale = 'en_IN';
  String _formatNumber(String s) =>
      intl.NumberFormat.decimalPattern(_locale).format(int.parse(s));
  String get _currency =>
      intl.NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

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
                                                    // key:
                                                    //     Key(widget.animalInfo[index]
                                                    //         ['uniqueId']),
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
    }

    return data;
  }

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
                      ],
                    ),
            ),
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
          // overflow: TextOverflow.ellipsis,
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
          RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                style: TextStyle(
                    color: greyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                text: (widget.animalInfo[index]['animalInfo']['animalBreed'] ==
                            'not_known'.tr
                        ? ""
                        : ReusableWidgets.removeEnglisgDataFromName(widget
                            .animalInfo[index]['animalInfo']['animalBreed'])) +
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
          RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () => showRemoveAnimalDialog(index),
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              label: Text('remove_animal'.tr,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)))
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

  _openAddEntryDialog(int index) {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return RemoveAnimal(
              listId: widget.animalInfo[index]['uniqueId'],
              price: widget.animalInfo[index]['animalInfo']['animalPrice']);
        },
        fullscreenDialog: true));
  }

  _priceTextBox(index) => Column(
        children: [
          TextFormField(
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.deny(RegExp(r'^0+'))
            ],
            controller: _controller,
            keyboardType: TextInputType.number,
            onChanged: (String price) {
              String string = '${_formatNumber(price.replaceAll(',', ''))}';

              _controller.value = TextEditingValue(
                text: _currency + string,
                selection: TextSelection.collapsed(offset: string.length),
              );

              _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length));
              setState(() {
                _price = price;
              });
            },
            decoration: InputDecoration(
                hintText: 'price_hint_text'.tr,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
          ),
          _isErrorEmpty
              ? Text(
                  'empty_removal_price_error'.tr,
                  style: TextStyle(color: primaryColor),
                )
              : _isError
                  ? Text(
                      'removal_price_error'.tr,
                      style: TextStyle(color: primaryColor),
                    )
                  : SizedBox.shrink()

          // Text(
          //   'removal_price_error'.trParams(
          //     {
          //       'minPrice':
          //           '${(int.parse(widget.animalInfo[index]['animalInfo']['animalPrice']) ~/ 2).toString()}',
          //       'maxPrice':
          //           '${widget.animalInfo[index]['animalInfo']['animalPrice']}'
          //     },
          //   ),
          //   style: TextStyle(color: primaryColor),
          // )
        ],
      );

  _showPriceDialog(index) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('info'.tr),
            content: Padding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('tell_price'.tr),
                  SizedBox(height: 5),
                  _priceTextBox(index)
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
            ),
            actions: <Widget>[
              RaisedButton(
                  child: Text(
                    'cancel'.tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      _isError = false;
                      _isErrorEmpty = false;
                      _price = '';
                    });
                    Navigator.of(context).pop();
                  }),
              RaisedButton(
                child: Text(
                  'Ok'.tr,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                onPressed: () {
                  if (_price.isEmpty) {
                    setState(() {
                      _isError = false;
                      _isErrorEmpty = true;
                    });
                  } else if ((int.parse(_price) <
                          (int.parse(widget.animalInfo[index]['animalInfo']
                                  ['animalPrice']) ~/
                              2)) ||
                      (int.parse(_price) >
                          int.parse(widget.animalInfo[index]['animalInfo']
                              ['animalPrice']))) {
                    setState(() {
                      _isErrorEmpty = false;
                      _isError = true;
                    });
                  } else {
                    setState(() {
                      _isErrorEmpty = false;
                      _isError = false;
                    });

                    pr = new ProgressDialog(context,
                        type: ProgressDialogType.Normal, isDismissible: false);
                    pr.style(message: 'progress_dialog_message'.tr);
                    pr.show();

                    FirebaseFirestore.instance
                        .collection("animalSellingInfo")
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .collection('sellingAnimalList')
                        .doc(widget.animalInfo[index]['uniqueId'])
                        .update({
                          'animalRemove': {
                            'soldFromApp': false,
                            'price': _price
                          },
                          'isValidUser': 'RemovedByUser',
                          'dateOfUpdation':
                              ReusableWidgets.dateTimeToEpoch(DateTime.now())
                        })
                        .then((value) => FirebaseFirestore.instance
                                .collection('buyingAnimalList1')
                                .doc(widget.animalInfo[index]['uniqueId'] +
                                    FirebaseAuth.instance.currentUser.uid)
                                .update({
                              'animalRemove': {
                                'soldFromApp': false,
                                'price': _price
                              },
                              'isValidUser': 'RemovedByUser',
                              'dateOfUpdation': ReusableWidgets.dateTimeToEpoch(
                                  DateTime.now())
                            }).then((value) {
                              pr.hide();
                              Navigator.of(context).pop();

                              return showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        title: Text('info'.tr),
                                        content: Text('pashu_removed'.tr),
                                        actions: <Widget>[
                                          FlatButton(
                                              child: Text(
                                                'Ok'.tr,
                                                style: TextStyle(
                                                    color: primaryColor),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Get.offAll(() => HomeScreen(
                                                      selectedIndex: 0,
                                                    ));
                                                // Navigator.pushReplacement(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder: (context) =>
                                                //             HomeScreen(
                                                //               selectedIndex: 0,
                                                //             )));
                                              }),
                                        ]);
                                  });
                            }).catchError((err) => print(
                                    'removeAnimalError==>${err.toString()}')))
                        .catchError((err) => print(
                            'removeAnimalOuterError==>${err.toString()}'));
                  }
                },
              ),
            ],
          ),
        ),
      );

  showRemoveAnimalDialog(index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('warning'.tr),
              content: Text('remove_animal_warning_text'.tr),
              actions: <Widget>[
                RaisedButton(
                    child: Text(
                      'no'.tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    onPressed: () => Navigator.of(context).pop()),
                RaisedButton(
                    child: Text(
                      'yes'.tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      FirebaseFirestore.instance
                          .collection('callingInfo')
                          .doc(widget.animalInfo[index]['uniqueId'])
                          .collection('interestedBuyers')
                          .orderBy('dateOfSaving')
                          .limit(1)
                          .get()
                          .then((value) {
                        if (value.docs.length == 0) {
                          _showPriceDialog(index);
                        } else {
                          _openAddEntryDialog(index);
                        }
                      });
                    }),
              ]);
        });
  }
}
