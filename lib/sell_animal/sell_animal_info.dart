import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:pashusansaar/buy_animal/buy_animal_controller.dart';
import 'package:pashusansaar/my_animals/myAnimalController.dart';
import 'package:pashusansaar/refresh_token/refresh_token_controller.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/constants.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final MyAnimalListController myAnimalListController =
      Get.put(MyAnimalListController());
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());

  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  // _imageData(_list) {
  //   var data = '';
  //   if (_list.files[0].fileName != '') {
  //     data = _list.files[0].fileName;
  //   } else if (widget.animalInfo[index]['animalImages']['image2'] != '') {
  //     data = widget.animalInfo[index]['animalImages']['image2'];
  //   } else if (widget.animalInfo[index]['animalImages']['image3'] != '') {
  //     data = widget.animalInfo[index]['animalImages']['image3'];
  //   } else if (widget.animalInfo[index]['animalImages']['image4'] != '') {
  //     data = widget.animalInfo[index]['animalImages']['image4'];
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
                padding: const EdgeInsets.only(right: 12.0, left: 12, top: 15),
                child: Text(
                  _descriptionText(_list),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      );

  Padding _buildDateWidget(_list) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: RichText(
          // overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style:
                TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
            text: (_list.createdAt) + ' ',
            children: <InlineSpan>[
              TextSpan(
                text: ' (' +
                    ReusableWidgets.dateDifference((_list.createdAt)) +
                    ')',
                style: TextStyle(
                    color: Colors.grey[500], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

  Padding _buildBreedTypeWidget(_list) {
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
                text: (_list.animalBreed == 'not_known'.tr
                        ? ""
                        : ReusableWidgets.removeEnglishDataFromName(
                            _list.animalBreed)) +
                    ' ',
                children: <InlineSpan>[
                  TextSpan(
                    text: (_list.animalType.toString() == 'other_animal'.tr
                            ? "no type"
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
          RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () => showRemoveAnimalDialog(_list),
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

  _openAddEntryDialog(_list) {
    Navigator.of(context).push(new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return RemoveAnimal(
              listId: _list.sId, price: _list.animalPrice.toString());
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
                  style: TextStyle(color: appPrimaryColor),
                )
              : _isError
                  ? Text(
                      'removal_price_error'.tr,
                      style: TextStyle(color: appPrimaryColor),
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
          //   style: TextStyle(color: appPrimaryColor),
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
                            'price': _price,
                            'soldDate':
                                ReusableWidgets.dateTimeToEpoch(DateTime.now())
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
                                'price': _price,
                                'soldDate': ReusableWidgets.dateTimeToEpoch(
                                    DateTime.now())
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
                                          TextButton(
                                              child: Text(
                                                'Ok'.tr,
                                                style: TextStyle(
                                                    color: appPrimaryColor),
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

  showRemoveAnimalDialog(_list) {
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
                _openAddEntryDialog(_list);
              },
            ),
          ],
        );
      },
    );
  }

/////<<<<<<<<<<<< previous dialog box >>>>>>>>>>>>>>>

//   showRemoveAnimalDialog(index) {
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('warning'.tr),
//           content: Text('remove_animal_warning_text'.tr),
//           actions: <Widget>[
//             RaisedButton(
//                 child: Text(
//                   'no'.tr,
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16),
//                 ),
//                 onPressed: () => Navigator.of(context).pop()),
//             RaisedButton(
//               child: Text(
//                 'yes'.tr,
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 FirebaseFirestore.instance
//                     .collection('callingInfo')
//                     .doc(widget.animalInfo[index]['uniqueId'])
//                     .collection('interestedBuyers')
//                     .orderBy('dateOfSaving')
//                     .limit(1)
//                     .get()
//                     .then(
//                   (value) {
//                     if (value.docs.length == 0) {
//                       _showPriceDialog(index);
//                     } else {
//                       _openAddEntryDialog(index);
//                     }
//                   },
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

//
//
//
//
//<<<<<<<<<<<<<<< new build >>>>>>>>>>>>>>>>>>>

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
        body: !widget.showExtraData && (widget.animalInfo.length == 0)
            ? Center(
                child: Column(
                  children: [
                    Text(
                      'आपका कोई पशु दर्ज़ नहीं है| कृपया पशु दर्ज़ करे',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    _buildSellingFormButton(context)
                  ],
                ),
              )
            : SingleChildScrollView(
          physics: BouncingScrollPhysics(),
              child: Column(
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
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildBreedTypeWidget(widget.animalInfo[index]),
                              _buildDateWidget(widget.animalInfo[index]),
                              _buildImageDescriptionWidget(
                                  width, widget.animalInfo[index]),
                              widget.showExtraData
                                  ? Row(
                                      textDirection: TextDirection.rtl,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                            onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SellAnimalEditForm(
                                                      index: index,
                                                      userName:
                                                          widget.userName,
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
                                                      color: appPrimaryColor,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                FaIcon(
                                                  FontAwesomeIcons.edit,
                                                  color: appPrimaryColor,
                                                  size: 16,
                                                )
                                              ],
                                            )),
                                        TextButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InterestedBuyer(
                                                          listId: widget
                                                                  .animalInfo[
                                                                      index]
                                                                  .sId ??
                                                              '',
                                                          index: index,
                                                          animalInfo: widget
                                                              .animalInfo,
                                                        ))),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'इच्छुक खरीदार की सूचि',
                                                  style: TextStyle(
                                                      color: appPrimaryColor,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                FaIcon(
                                                  FontAwesomeIcons.arrowRight,
                                                  color: appPrimaryColor,
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
                                                    listId: widget
                                                            .animalInfo[index]
                                                            .sId ??
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
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                  "इच्छुक खरीदार की सूचि देखे",
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
                        );
                      },
                    ),
                  ],
                ),
            ));
  }
}

//////////////////// Previous Build ???????????????

// @override
// Widget build(BuildContext context) {
//   super.build(context);
//   final double width = MediaQuery.of(context).size.width;
//   return Scaffold(
//     backgroundColor: Colors.grey[100],
//     appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
//     body: myAnimalList == null || myAnimalList.isEmpty
//         ? Center(
//       child: Column(
//         children: [
//           Text(
//             'आपका कोई पशु दर्ज़ नहीं है| कृपया पशु दर्ज़ करे',
//             style:
//             TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           _buildSellingFormButton(context)
//         ],
//       ),
//     )
//         : Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         widget.showExtraData
//             ? _buildSellingFormButton(context)
//             : SizedBox.shrink(),
//         widget.showExtraData
//             ? Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             height: 30,
//             child: Text('your_selling_animal_info'.tr,
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black)),
//           ),
//         )
//             : SizedBox.shrink(),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: widget.animalInfo.length,
//           itemBuilder: (context, index) {
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Card(
//                 key: Key(widget.animalInfo[index]['uniqueId']),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 elevation: 5,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildBreedTypeWidget(index),
//                     _buildDateWidget(index),
//                     _buildImageDescriptionWidget(width, index),
//                     widget.showExtraData
//                         ? Row(
//                       textDirection: TextDirection.rtl,
//                       mainAxisAlignment:
//                       MainAxisAlignment.spaceBetween,
//                       children: [
//                         TextButton(
//                             onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     SellAnimalEditForm(
//                                       index: index,
//                                       userName: widget.userName,
//                                       userMobileNumber: widget
//                                           .userMobileNumber,
//                                     ),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'change_info'.tr,
//                                   style: TextStyle(
//                                       color: appPrimaryColor,
//                                       fontSize: 15),
//                                 ),
//                                 SizedBox(
//                                   width: 5,
//                                 ),
//                                 FaIcon(
//                                   FontAwesomeIcons.edit,
//                                   color: appPrimaryColor,
//                                   size: 16,
//                                 )
//                               ],
//                             )),
//                         TextButton(
//                             onPressed: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         InterestedBuyer(
//                                           listId: widget.animalInfo[
//                                           index][
//                                           'uniqueId'] ??
//                                               '',
//                                           index: index,
//                                           animalInfo:
//                                           widget.animalInfo,
//                                         ))),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'इच्छुक खरीदार की सूचि',
//                                   style: TextStyle(
//                                       color: appPrimaryColor,
//                                       fontSize: 15),
//                                 ),
//                                 SizedBox(
//                                   width: 5,
//                                 ),
//                                 FaIcon(
//                                   FontAwesomeIcons.arrowRight,
//                                   color: appPrimaryColor,
//                                   size: 16,
//                                 )
//                               ],
//                             )),
//                       ],
//                     )
//                         : GestureDetector(
//                       onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   InterestedBuyer(
//                                     // key:
//                                     //     Key(widget.animalInfo[index]
//                                     //         ['uniqueId']),
//                                     listId:
//                                     widget.animalInfo[index]
//                                     ['uniqueId'] ??
//                                         '',
//                                     index: index,
//                                     animalInfo:
//                                     widget.animalInfo,
//                                   ))),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey,
//                               blurRadius: 1.0,
//                             ),
//                           ],
//                           borderRadius:
//                           BorderRadius.circular(8),
//                         ),
//                         height: 50,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("इच्छुक खरीदार की सूचि देखे",
//                                   style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight:
//                                       FontWeight.bold)),
//                               Icon(Icons.arrow_forward_ios)
//                             ],
//                           ),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//         // ))
//       ],
//     ),
//   );
// }
