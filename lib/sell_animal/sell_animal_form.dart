import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhenu/utils/colors.dart';
import 'package:dhenu/utils/reusable_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';
import '../utils/constants.dart' as constant;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SellAnimalForm extends StatefulWidget {
  final String userName;
  SellAnimalForm({Key key, @required this.userName}) : super(key: key);

  @override
  _SellAnimalFormState createState() => _SellAnimalFormState();
}

class _SellAnimalFormState extends State<SellAnimalForm> {
  var animalInfo = {}, extraInfoData = {};
  String _base64Image;
  ImagePicker _picker;
  ProgressDialog pr;
  Color backgroundColor = Colors.red[50];
  bool _showData = false;
  // final _storage = new FlutterSecureStorage();
  SharedPreferences prefs;
  String desc = '';

  Map<String, dynamic> imagesUpload = {
    'image1': '',
    'image2': '',
    'image3': '',
    'image4': ''
  };

  TextEditingController _controller;
  static const _locale = 'en_IN';

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(
        int.parse(s),
      );
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

  Future<void> _choose(String index) async {
    try {
      if (_picker == null) {
        _picker = ImagePicker();
      }
      var file = await _picker.getImage(source: ImageSource.camera);

      switch (file) {
        case null:
          return null;
          break;
        default:
          File compressedFile = await FlutterNativeImage.compressImage(
              file.path,
              quality: 90,
              targetWidth: 500,
              targetHeight: 500);
          setState(() {
            _base64Image = base64Encode(
              compressedFile.readAsBytesSync(),
            );
            imagesUpload['image$index'] = _base64Image;
          });
      }
    } catch (e) {}
  }

  Future<void> _chooseFromGallery(String index) async {
    try {
      if (_picker == null) {
        _picker = ImagePicker();
      }
      var file = await _picker.getImage(source: ImageSource.gallery);

      switch (file) {
        case null:
          return null;
          break;
        default:
          File compressedFile = await FlutterNativeImage.compressImage(
              file.path,
              quality: 90,
              targetWidth: 500,
              targetHeight: 500);
          setState(() {
            _base64Image = base64Encode(
              compressedFile.readAsBytesSync(),
            );
            imagesUpload['image$index'] = _base64Image;
          });
      }
    } catch (e) {}
  }

  // _descriptionText(int index) {
  //   String desc = '';

  //   String stmn2 =
  //       'यह ${widget.animalInfo[index]['extraInfo']['animalAlreadyGivenBirth']} ब्यायी है ';
  //   String stmn3 =
  //       'और अभी ${widget.animalInfo[index]['extraInfo']['animalIfPregnant']} है। ';
  //   String stmn4 = '';
  //   String stmn41 = 'इसके साथ में बच्चा नहीं है। ';
  //   String stmn42 =
  //       'इसके साथ में ${widget.animalInfo[index]['extraInfo']['animalHasBaby']}। ';
  //   String stmn5 =
  //       'पिछले बार के हिसाब से दूध कैपेसिटी ${widget.animalInfo[index]['animalInfo']['animalMilk']} लीटर है। ';

  //   if (widget.animalInfo[index]['animalInfo']['animalType'] ==
  //           'buffalo_male'.tr ||
  //       widget.animalInfo[index]['animalInfo']['animalType'] == 'ox'.tr) {
  //     desc =
  //         'ये ${widget.animalInfo[index]['animalInfo']['animalBreed']} ${widget.animalInfo[index]['animalInfo']['animalType']} ${widget.animalInfo[index]['animalInfo']['animalAge']} साल का है। ';
  //   } else {
  //     desc =
  //         'ये ${widget.animalInfo[index]['animalInfo']['animalBreed']} ${widget.animalInfo[index]['animalInfo']['animalType']} ${widget.animalInfo[index]['animalInfo']['animalAge']} साल की है। ';
  //     if (widget.animalInfo[index]['extraInfo']['animalAlreadyGivenBirth'] !=
  //         null) desc = desc + stmn2;
  //     if (widget.animalInfo[index]['extraInfo']['animalIfPregnant'] != null)
  //       desc = desc + stmn3;
  //     if (widget.animalInfo[index]['extraInfo']['animalHasBaby'] != null &&
  //         widget.animalInfo[index]['extraInfo']['animalHasBaby'] ==
  //             'nothing'.tr)
  //       stmn4 = stmn4 + stmn41;
  //     else
  //       stmn4 = stmn4 + stmn42;

  //     desc = desc + stmn4;
  //     desc = desc + stmn5;
  //   }

  //   return desc + (widget.animalInfo[index]['extraInfo']['moreInfo'] ?? '');
  // }

  chooseOption(String index) => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Choose From..',
          ),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          _choose(index);
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(" Capture from camera")
                    ],
                  ),
                  onTap: () {
                    _choose(index);
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () {
                          _chooseFromGallery(index);
                          Navigator.of(context).pop();
                        },
                      ),
                      Text(" Choose from gallery")
                    ],
                  ),
                  onTap: () {
                    _chooseFromGallery(index);
                    Navigator.of(context).pop();
                  },
                ),
              ]),
        );
      });

  Column animalType() => Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              Text(
                'animal_type'.tr,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5),
              Text(
                '*',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: DropdownSearch<String>(
            mode: Mode.BOTTOM_SHEET,
            showSelectedItem: true,
            items: constant.animalType,
            label: 'animal_type'.tr,
            hint: 'animal_type'.tr,
            selectedItem: animalInfo['animalType'],
            onChanged: (String type) {
              setState(() {
                animalInfo['animalType'] = type;
              });
            },
            dropdownSearchDecoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                )),
          ),
        ),
        Visibility(
          visible: (constant.animalType.indexOf(animalInfo['animalType']) ==
              (constant.animalType.length - 1)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: DropdownSearch<String>(
              mode: Mode.BOTTOM_SHEET,
              showSelectedItem: true,
              items: constant.animalTypeOther,
              label: 'other_animal'.tr,
              hint: 'other_animal'.tr,
              selectedItem: animalInfo['animalTypeOther'],
              onChanged: (String otherType) {
                setState(() {
                  animalInfo['animalTypeOther'] = otherType;
                });
              },
              dropdownSearchDecoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
            ),
          ),
          replacement: SizedBox.shrink(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Divider(
            thickness: 1,
          ),
        ),
      ]);

  Column animalBreed() => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'animal_breed'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: DropdownSearch<String>(
              mode: Mode.BOTTOM_SHEET,
              showSelectedItem: true,
              selectedItem: animalInfo['animalBreed'],
              items: [0, 3].contains(
                constant.animalType.indexOf(animalInfo['animalType']),
              )
                  ? constant.animalBreedCowOx
                  : [1, 2].contains(
                      constant.animalType.indexOf(animalInfo['animalType']),
                    )
                      ? constant.animalBreedBuffaloFemaleMale
                      : ['not_known'.tr],
              label: 'animal_breed'.tr,
              hint: 'animal_breed'.tr,
              showSearchBox: true,
              onChanged: (String breed) {
                setState(() {
                  animalInfo['animalBreed'] = breed;
                });
              },
              dropdownSearchDecoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );

  Column animalAge() => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'animal_age'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: DropdownSearch<String>(
              mode: Mode.BOTTOM_SHEET,
              showSelectedItem: true,
              selectedItem: animalInfo['animalAge'],
              items: constant.animalAge,
              label: 'animal_age'.tr,
              hint: 'animal_age'.tr,
              onChanged: (String age) {
                setState(() {
                  animalInfo['animalAge'] = age;
                });
              },
              dropdownSearchDecoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );
  Column animalIsPregnant() => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'animal_is_pregnant'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: DropdownSearch<String>(
              mode: Mode.BOTTOM_SHEET,
              showSelectedItem: true,
              items: constant.pregnantMonth,
              label: 'animal_is_pregnant'.tr,
              hint: ''.tr,
              selectedItem: animalInfo['animalIsPregnant'],
              showSearchBox: true,
              onChanged: (String pregnant) {
                setState(() {
                  animalInfo['animalIsPregnant'] = pregnant;
                });
              },
              dropdownSearchDecoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );

  //milk
  Column animalMilkPerDay() => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'animal_milk_per_day'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5),
                Text(
                  '*',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: TextFormField(
                initialValue: animalInfo['animalMilk'],
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                onChanged: (String milk) {
                  setState(() {
                    animalInfo['animalMilk'] = milk;
                  });
                },
                decoration: InputDecoration(
                    hintText: 'milk_hint_text'.tr,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
              )),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );

  //milk capacity
  Column animalMilkPerDayCapacity() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              'animal_milk_per_day_capacity'.tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: TextFormField(
                initialValue: animalInfo['animalMilkCapacity'],
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                keyboardType: TextInputType.number,
                onChanged: (String milkCapacity) {
                  setState(() {
                    animalInfo['animalMilkCapacity'] = milkCapacity;
                  });
                },
                decoration: InputDecoration(
                    hintText: 'milk_hint_text'.tr,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
              )),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );

  //price
  Column animalPrice() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'animal_price'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'price_support_text'.tr,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500]),
                ),
                Text(
                  '*',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: TextFormField(
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: _controller,
                keyboardType: TextInputType.number,
                onChanged: (String price) {
                  String string = '${_formatNumber(
                    price.replaceAll(',', ''),
                  )}';
                  _controller.value = TextEditingValue(
                    text: _currency + string,
                    selection: TextSelection.collapsed(offset: string.length),
                  );

                  _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length));

                  setState(() {
                    animalInfo['animalPrice'] = price;
                  });
                },
                decoration: InputDecoration(
                    hintText: 'price_hint_text'.tr,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
              )),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );

  Padding imageStructure1(double width) => Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
        child: GestureDetector(
          onTap: () => chooseOption('1'),
          child: Stack(
            children: [
              DottedBorder(
                strokeWidth: 2,
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                padding: EdgeInsets.all(6),
                color: Colors.grey[500],
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                  child: Container(
                    height: 150,
                    width: width * 0.3,
                    child: Visibility(
                      visible: imagesUpload['image1'] != null &&
                          imagesUpload['image1'].isNotEmpty,
                      child: Image.memory(
                        base64Decode(imagesUpload['image1']),
                      ),
                      replacement: Column(children: [
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/photouploadfront.png',
                            height: 100,
                          ),
                        ),
                        RaisedButton(
                          onPressed: () => chooseOption('1'),
                          child: Text(
                            'choose_photo'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      ]),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: imagesUpload['image1'] != null &&
                    imagesUpload['image1'].isNotEmpty,
                child: Positioned(
                  top: -1,
                  right: -1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        imagesUpload['image1'] = '';
                      });
                    },
                    child: Icon(
                      Icons.cancel_rounded,
                      color: Colors.black,
                    ),
                  ),
                ),
                replacement: SizedBox.shrink(),
              )
            ],
          ),
        ),
      );
  Padding imageStructure2(double width) => Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: GestureDetector(
        onTap: () => chooseOption('2'),
        child: Stack(
          children: [
            DottedBorder(
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: Radius.circular(12),
              padding: EdgeInsets.all(6),
              color: Colors.grey[500],
              child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                  child: Container(
                    height: 150,
                    width: width * 0.3,
                    // color: Colors.amber,
                    child: Visibility(
                      visible: imagesUpload['image2'] != null &&
                          imagesUpload['image2'].isNotEmpty,
                      child: Image.memory(
                        base64Decode(imagesUpload['image2']),
                      ),
                      replacement: Column(children: [
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/photouploadback.png',
                            height: 100,
                          ),
                        ),
                        RaisedButton(
                          onPressed: () => chooseOption('2'),
                          child: Text(
                            'choose_photo'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      ]),
                    ),
                  )),
            ),
            Visibility(
              visible: imagesUpload['image2'] != null &&
                  imagesUpload['image2'].isNotEmpty,
              child: Positioned(
                top: -1,
                right: -1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imagesUpload['image2'] = '';
                    });
                  },
                  child: Icon(
                    Icons.cancel_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
              replacement: SizedBox.shrink(),
            )
          ],
        ),
      ));
  Padding imageStructure3(double width) => Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      child: GestureDetector(
        onTap: () => chooseOption('3'),
        child: Stack(
          children: [
            DottedBorder(
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: Radius.circular(12),
              padding: EdgeInsets.all(6),
              color: Colors.grey[500],
              child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                  child: Container(
                    height: 150,
                    width: width * 0.3,
                    // color: Colors.amber,
                    child: Visibility(
                      visible: imagesUpload['image3'] != null &&
                          imagesUpload['image3'].isNotEmpty,
                      child: Image.memory(
                        base64Decode(imagesUpload['image3']),
                      ),
                      replacement: Column(children: [
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/photouploadside.png',
                            height: 100,
                          ),
                        ),
                        RaisedButton(
                          onPressed: () => chooseOption('3'),
                          child: Text(
                            'choose_photo'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      ]),
                    ),
                  )),
            ),
            Visibility(
              visible: imagesUpload['image3'] != null &&
                  imagesUpload['image3'].isNotEmpty,
              child: Positioned(
                top: -1,
                right: -1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imagesUpload['image3'] = '';
                    });
                  },
                  child: Icon(
                    Icons.cancel_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
              replacement: SizedBox.shrink(),
            )
          ],
        ),
      ));

  Padding imageStructure4(double width) => Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: GestureDetector(
        onTap: () => chooseOption('4'),
        child: Stack(
          children: [
            DottedBorder(
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: Radius.circular(12),
              padding: EdgeInsets.all(6),
              color: Colors.grey[500],
              child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                  child: Container(
                    height: 150,
                    width: width * 0.3,
                    // color: Colors.amber,
                    child: Visibility(
                      visible: imagesUpload['image4'] != null &&
                          imagesUpload['image4'].isNotEmpty,
                      child: Image.memory(
                        base64Decode(imagesUpload['image4']),
                      ),
                      replacement: Column(children: [
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/images/photouploadside.png',
                            height: 100,
                          ),
                        ),
                        RaisedButton(
                          onPressed: () => chooseOption('4'),
                          child: Text(
                            'choose_photo'.tr,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      ]),
                    ),
                  )),
            ),
            Visibility(
              visible: imagesUpload['image4'] != null &&
                  imagesUpload['image4'].isNotEmpty,
              child: Positioned(
                top: -1,
                right: -1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imagesUpload['image4'] = '';
                    });
                  },
                  child: Icon(
                    Icons.cancel_rounded,
                    color: Colors.black,
                  ),
                ),
              ),
              replacement: SizedBox.shrink(),
            )
          ],
        ),
      ));

  Padding saveButton() => Padding(
        padding: EdgeInsets.all(15),
        child: SizedBox(
          width: double.infinity,
          child: RaisedButton(
            padding: EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 5,
            // color: themeColor,
            child: Text(
              'save_button'.tr,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () async {
              if (animalInfo['animalType'] == null)
                ReusableWidgets.showDialogBox(
                  context,
                  'error'.tr,
                  Text('animal_type_error'.tr),
                );
              else if (animalInfo['animalBreed'] == null)
                ReusableWidgets.showDialogBox(
                  context,
                  'error'.tr,
                  Text('animal_breed_error'.tr),
                );
              else if (animalInfo['animalAge'] == null)
                ReusableWidgets.showDialogBox(
                  context,
                  'error'.tr,
                  Text('animal_age_error'.tr),
                );
              else if ([0, 1].contains(
                    constant.animalType.indexOf(animalInfo['animalType']),
                  ) &&
                  (animalInfo['animalIsPregnant'] == null))
                ReusableWidgets.showDialogBox(
                  context,
                  'error'.tr,
                  Text('animal_pregnancy_error'.tr),
                );
              else if ([0, 1].contains(
                    constant.animalType.indexOf(animalInfo['animalType']),
                  ) &&
                  animalInfo['animalMilk'] == null)
                ReusableWidgets.showDialogBox(
                  context,
                  'error'.tr,
                  Text('animal_milk_error'.tr),
                );
              else if (animalInfo['animalPrice'] == null)
                ReusableWidgets.showDialogBox(
                  context,
                  'error'.tr,
                  Text('animal_price_error'.tr),
                );
              else if (imagesUpload['image1'].isEmpty &&
                  imagesUpload['image2'].isEmpty &&
                  imagesUpload['image3'].isEmpty &&
                  imagesUpload['image4'].isEmpty)
                ReusableWidgets.showDialogBox(
                  context,
                  'error'.tr,
                  Text('animal_image_error'.tr),
                );
              else {
                // await Firebase.initializeApp();
                //                   FirebaseFirestore.instance
                //     .collection("buyingAnimalList")
                //     .doc(FirebaseAuth.instance.currentUser.uid)
                //     .set({
                //   "userAnimalDescription": extraInfoData['moreInfo'],
                //   "userAnimalType": animalInfo['animalType'],
                //   "userAnimalAge": animalInfo['animalAge'],
                //   "userAddress": "",
                //   "userName": widget.userName,
                //   "userAnimalPrice": animalInfo['animalPrice'],
                //   "userAnimalBreed": animalInfo['animalBreed'],
                //   "userMobileNumber":
                //       FirebaseAuth.instance.currentUser.phoneNumber,
                //   "userAnimalMilk": animalInfo['animalMilk'],
                //   "userAnimalPregnancy": animalInfo['animalIsPregnant'],
                //   "userLatitude": prefs.getDouble('latitude'),
                //   "userLongitude": prefs.getDouble('longitude'),
                //   "image1": imagesUpload['image1'] == null ||
                //           imagesUpload['image1'] == ""
                //       ? ""
                //       : imagesUpload['image1'],
                //   "image2": imagesUpload['image2'] == null ||
                //           imagesUpload['image2'] == ""
                //       ? ""
                //       : imagesUpload['image2'],
                //   "image3": imagesUpload['image3'] == null ||
                //           imagesUpload['image3'] == ""
                //       ? ""
                //       : imagesUpload['image3'],
                //   "image4": imagesUpload['image4'] == null ||
                //           imagesUpload['image4'] == ""
                //       ? ""
                //       : imagesUpload['image4'],
                //   "dateOfSaving":
                //       ReusableWidgets.dateTimeToEpoch(DateTime.now())
                // }).then((value) {
                pr = new ProgressDialog(context,
                    type: ProgressDialogType.Normal, isDismissible: false);
                pr.style(message: 'progress_dialog_message'.tr);
                pr.show();

                String uuid = Uuid().v1().toString();

                FirebaseFirestore.instance
                    .collection("animalSellingInfo")
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .collection('sellingAnimalList')
                    .doc(uuid)
                    .set({
                  'animalInfo': animalInfo,
                  'animalImages': imagesUpload,
                  'extraInfo': extraInfoData,
                  'dateOfSaving':
                      ReusableWidgets.dateTimeToEpoch(DateTime.now()),
                  'uuid': uuid
                }).then((res) async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  FirebaseFirestore.instance
                      .collection("buyingAnimalList")
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .set({
                    "userAnimalDescription": extraInfoData['moreInfo'],
                    "userAnimalType": animalInfo['animalType'],
                    "userAnimalAge": animalInfo['animalAge'],
                    "userAddress": "",
                    "userName": widget.userName,
                    "userAnimalPrice": animalInfo['animalPrice'],
                    "userAnimalBreed": animalInfo['animalBreed'],
                    "userMobileNumber":
                        FirebaseAuth.instance.currentUser.phoneNumber,
                    "userAnimalMilk": animalInfo['animalMilk'],
                    "userAnimalPregnancy": animalInfo['animalIsPregnant'],
                    "userLatitude": prefs.getDouble('latitude'),
                    "userLongitude": prefs.getDouble('longitude'),
                    "image1": imagesUpload['image1'] == null ||
                            imagesUpload['image1'] == ""
                        ? ""
                        : imagesUpload['image1'],
                    "image2": imagesUpload['image2'] == null ||
                            imagesUpload['image2'] == ""
                        ? ""
                        : imagesUpload['image2'],
                    "image3": imagesUpload['image3'] == null ||
                            imagesUpload['image3'] == ""
                        ? ""
                        : imagesUpload['image3'],
                    "image4": imagesUpload['image4'] == null ||
                            imagesUpload['image4'] == ""
                        ? ""
                        : imagesUpload['image4'],
                    "dateOfSaving":
                        ReusableWidgets.dateTimeToEpoch(DateTime.now())
                  }).then((value) {
                    pr.hide();
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: Text('pashu_registered'.tr),
                              content: Text('new_animal'.tr),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text(
                                      'Ok'.tr,
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomeScreen(
                                              selectedIndex: 0,
                                            ),
                                          ));
                                    }),
                              ]);
                        });
                  });
                }).catchError(
                  (err) => print("err->" + err.toString()),
                );
              }
            },
          ),
        ),
      );

  Column animalAlreadyGivenBirth() => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'animal_already_pregnant'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5),
                Text(
                  'already_pregnant_supportive_text'.tr,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownSearch<String>(
                    mode: Mode.BOTTOM_SHEET,
                    showSelectedItem: true,
                    items: constant.yesNo,
                    // label: 'animal_age'.tr,
                    // hint: 'animal_age'.tr,
                    maxHeight: 120,
                    onChanged: (String yesOrNo) {
                      setState(() {
                        extraInfoData['alreadyPregnantYesNo'] = yesOrNo;
                      });
                    },
                    dropdownSearchDecoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        )),
                  ),
                ),
                extraInfoData['alreadyPregnantYesNo'] != null &&
                        extraInfoData['alreadyPregnantYesNo'].isNotEmpty &&
                        constant.yesNo.indexOf(
                                extraInfoData['alreadyPregnantYesNo']) ==
                            0
                    ? SizedBox(width: 5)
                    : SizedBox.shrink(),
                extraInfoData['alreadyPregnantYesNo'] != null &&
                        extraInfoData['alreadyPregnantYesNo'].isNotEmpty &&
                        constant.yesNo.indexOf(
                                extraInfoData['alreadyPregnantYesNo']) ==
                            0
                    ? Expanded(
                        flex: 3,
                        child: DropdownSearch<String>(
                          mode: Mode.BOTTOM_SHEET,
                          showSelectedItem: true,
                          items: constant.ifPregnant,
                          // label: 'animal_age'.tr,
                          // hint: 'animal_age'.tr,
                          onChanged: (String age) {
                            setState(() {
                              extraInfoData['animalAlreadyGivenBirth'] = age;
                            });
                          },
                          dropdownSearchDecoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              )),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );
  Column animalIsInPregnancy() => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'animal_if_pregnant'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 5),
                Text(
                  'animal_if_pregnant_supportive_text'.tr,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownSearch<String>(
                    mode: Mode.BOTTOM_SHEET,
                    showSelectedItem: true,
                    items: constant.yesNo,
                    // label: 'animal_age'.tr,
                    // hint: 'animal_age'.tr,
                    maxHeight: 120,
                    onChanged: (String yesOrNo) {
                      setState(() {
                        extraInfoData['isPregnantYesNo'] = yesOrNo;
                      });
                    },
                    dropdownSearchDecoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        )),
                  ),
                ),
                extraInfoData['isPregnantYesNo'] != null &&
                        extraInfoData['isPregnantYesNo'].isNotEmpty &&
                        constant.yesNo
                                .indexOf(extraInfoData['isPregnantYesNo']) ==
                            0
                    ? SizedBox(width: 5)
                    : SizedBox.shrink(),
                extraInfoData['isPregnantYesNo'] != null &&
                        extraInfoData['isPregnantYesNo'].isNotEmpty &&
                        constant.yesNo
                                .indexOf(extraInfoData['isPregnantYesNo']) ==
                            0
                    ? Expanded(
                        flex: 3,
                        child: DropdownSearch<String>(
                          mode: Mode.BOTTOM_SHEET,
                          showSelectedItem: true,
                          items: constant.isPregnant,
                          // label: 'animal_age'.tr,
                          // hint: 'animal_age'.tr,
                          onChanged: (String time) {
                            setState(() {
                              extraInfoData['animalIfPregnant'] = time;
                            });
                          },
                          dropdownSearchDecoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              )),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );

  Padding extraInfo() => Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showData = !_showData;
            });
          },
          child: Card(
            color: backgroundColor,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "extra_info".tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Icon(Icons.arrow_downward)
                ],
              ),
            ),
          ),
        ),
      );

  Column animalHasChild() => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'any_child_with_animal'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: DropdownSearch<String>(
              mode: Mode.BOTTOM_SHEET,
              showSelectedItem: true,
              items: constant.isBaby,
              maxHeight: 200,
              onChanged: (String baby) {
                setState(() {
                  extraInfoData['animalHasBaby'] = baby;
                });
              },
              dropdownSearchDecoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      );

  moreInfoTextArea() {
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: [
            Text(
              'more_info'.tr,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'more_info_placeholder_text'.tr,
            contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onChanged: (String text) {
            setState(() {
              extraInfoData['moreInfo'] = text;
            });
          },
        ),
      )
    ]);
  }

  extraINfoData() {
    return Column(
      children: [
        animalAlreadyGivenBirth(),
        animalIsInPregnancy(),
        animalHasChild(),
        moreInfoTextArea()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      // appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
      body: GestureDetector(
        onTap: () {
          return WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text(
                'tell_about_animal'.tr,
                style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold),
              )),
              animalType(),
              animalBreed(),
              animalAge(),
              [0, 1].contains(
                constant.animalType.indexOf(animalInfo['animalType']),
              )
                  ? animalIsPregnant()
                  : SizedBox.shrink(),
              [0, 1].contains(
                constant.animalType.indexOf(animalInfo['animalType']),
              )
                  ? animalMilkPerDay()
                  : SizedBox.shrink(),
              [0, 1].contains(
                constant.animalType.indexOf(animalInfo['animalType']),
              )
                  ? animalMilkPerDayCapacity()
                  : SizedBox.shrink(),
              animalPrice(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      'upload_image_text'.tr,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '*',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ],
                ),
              ),
              Row(
                children: [imageStructure1(width), imageStructure2(width)],
              ),
              Row(
                children: [imageStructure3(width), imageStructure4(width)],
              ),
              extraInfo(),
              AnimatedOpacity(
                opacity: _showData ? 1 : 0,
                duration: Duration(seconds: 2),
                child: _showData
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: [0, 1].contains(
                          constant.animalType.indexOf(animalInfo['animalType']),
                        )
                            ? extraINfoData()
                            : moreInfoTextArea(),
                      )
                    : SizedBox.shrink(),
              ),
              saveButton()
            ],
          ),
        ),
      ),
    );
  }
}
