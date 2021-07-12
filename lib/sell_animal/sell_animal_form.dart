import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:pashusansaar/refresh_token/refresh_token_controller.dart';
import 'package:pashusansaar/upload_image/upload_image_controller.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/constants.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
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
import 'dart:math' as math;
import 'package:mime/mime.dart';

import 'sell_animal_controller.dart';

class SellAnimalForm extends StatefulWidget {
  String userName;
  String userMobileNumber;
  SellAnimalForm(
      {Key key, @required this.userName, @required this.userMobileNumber})
      : super(key: key);

  @override
  _SellAnimalFormState createState() => _SellAnimalFormState();
}

class _SellAnimalFormState extends State<SellAnimalForm>
    with AutomaticKeepAliveClientMixin {
  var animalInfo = {}, extraInfoData = {};
  ImagePicker _picker;
  ProgressDialog pr;
  Color backgroundColor = Colors.red[50];
  bool _showData = false, _isLoading = false;
  SharedPreferences prefs;
  String desc = '', fileUrl = '';
  File filePath;
  String uniqueId;

  Map<String, dynamic> imagesUpload = {
    'Image1': {},
    'Image2': {},
    'Image3': {},
    'Image4': {}
  };

  Map<String, dynamic> imagesFileUpload = {
    'Image1': '',
    'Image2': '',
    'Image3': '',
    'Image4': ''
  };

  List _imageToBeUploaded = [];
  TextEditingController _controller;
  static const _locale = 'en_IN';
  final UploadImageController _uploadImageController =
      Get.put(UploadImageController());
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());
  final SellAnimalController sellAnimalController =
      Get.put(SellAnimalController());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _controller = TextEditingController();
    uniqueId = ReusableWidgets.randomIDGenerator();

    super.initState();
  }

  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));
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
          await getFileSize(file.path, 1).then((val) async {
            double size = double.parse(val.split(' ')[0]);
            String type = val.split(' ')[1];
            File compressedFile;

            switch (type.compareTo('KB')) {
              case 0:
                if (size <= 300.0) {
                  compressedFile = await FlutterNativeImage.compressImage(
                      file.path,
                      quality: 100);
                } else if (size > 300.0 && size <= 600.0) {
                  compressedFile = await FlutterNativeImage.compressImage(
                      file.path,
                      quality: 85);
                } else if (size > 600.0 && size <= 1000.0) {
                  compressedFile = await FlutterNativeImage.compressImage(
                      file.path,
                      quality: 75);
                } else {
                  compressedFile = await FlutterNativeImage.compressImage(
                      file.path,
                      quality: 65);
                }
                break;
              case 1:
                compressedFile = await FlutterNativeImage.compressImage(
                    file.path,
                    quality: 60);
                break;
            }
            final mimeType = lookupMimeType(file.path);

            setState(() {
              imagesFileUpload['Image$index'] = compressedFile.path;
              imagesUpload['Image$index'] = {
                "fileName": "Image$index",
                "fileType": mimeType
              };
            });

            // await uploadFile(compressedFile, index);
          });
      }
    } catch (e) {}
  }

  getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
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
          await getFileSize(file.path, 1).then((val) async {
            double size = double.parse(val.split(' ')[0]);
            String type = val.split(' ')[1];
            File compressedFile;

            switch (type.compareTo('KB')) {
              case 0:
                if (size <= 300.0) {
                  compressedFile = await FlutterNativeImage.compressImage(
                      file.path,
                      quality: 100);
                } else if (size > 300.0 && size <= 600.0) {
                  compressedFile = await FlutterNativeImage.compressImage(
                      file.path,
                      quality: 85);
                } else if (size > 600.0 && size <= 1000.0) {
                  compressedFile = await FlutterNativeImage.compressImage(
                      file.path,
                      quality: 75);
                } else {
                  compressedFile = await FlutterNativeImage.compressImage(
                      file.path,
                      quality: 65);
                }
                break;
              case 1:
                compressedFile = await FlutterNativeImage.compressImage(
                    file.path,
                    quality: 60);
                break;
            }

            final mimeType = lookupMimeType(file.path);

            setState(() {
              imagesFileUpload['Image$index'] = compressedFile.path;
              imagesUpload['Image$index'] = {
                "fileName": "Image$index",
                "fileType": mimeType
              };
            });

            // await uploadFile(compressedFile, index);
          });
      }
    } catch (e) {}
  }

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
                  FilteringTextInputFormatter.digitsOnly,
                  // FilteringTextInputFormatter.deny(RegExp(r'^0+'))
                ],
                keyboardType: TextInputType.number,
                onChanged: (String milk) {
                  setState(() {
                    animalInfo['animalMilk'] =
                        milk.replaceAll(new RegExp(r'^0+(?=.)'), '');
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
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.deny(RegExp(r'^0+'))
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
                  FilteringTextInputFormatter.deny(RegExp(r'^0+'))
                ],
                controller: _controller,
                keyboardType: TextInputType.number,
                onChanged: (String price) {
                  // String string = '${_formatNumber(price)}';
                  String string = '${_formatNumber(price.replaceAll(',', ''))}';

                  _controller.value = TextEditingValue(
                    text: _currency + string,
                    selection: TextSelection.collapsed(offset: string.length),
                  );

                  // _controller.selection = TextSelection(
                  //     baseOffset: price.length, extentOffset: price.length);
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
                      visible: imagesFileUpload['Image1'] != null &&
                          imagesFileUpload['Image1'].isNotEmpty,
                      child: Image.file(
                        File(imagesFileUpload['Image1']),
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
                visible: imagesFileUpload['Image1'] != null &&
                    imagesFileUpload['Image1'].isNotEmpty,
                child: Positioned(
                  top: -1,
                  right: -1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        imagesFileUpload['Image1'] = '';
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
                      visible: imagesFileUpload['Image2'] != null &&
                          imagesFileUpload['Image2'].isNotEmpty,
                      child: Image.file(
                        File(imagesFileUpload['Image2']),
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
              visible: imagesFileUpload['Image2'] != null &&
                  imagesFileUpload['Image2'].isNotEmpty,
              child: Positioned(
                top: -1,
                right: -1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imagesFileUpload['Image2'] = '';
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
                      visible: imagesFileUpload['Image3'] != null &&
                          imagesFileUpload['Image3'].isNotEmpty,
                      child: Image.file(
                        File(imagesFileUpload['Image3']),
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
              visible: imagesFileUpload['Image3'] != null &&
                  imagesFileUpload['Image3'].isNotEmpty,
              child: Positioned(
                top: -1,
                right: -1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imagesFileUpload['Image3'] = '';
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
                      visible: imagesFileUpload['Image4'] != null &&
                          imagesFileUpload['Image4'].isNotEmpty,
                      child: Image.file(
                        File(imagesFileUpload['Image4']),
                      ),
                      // Image.file(
                      //   File(imagesFileUpload['Image3']),
                      // ),
                      replacement: Column(children: [
                        Opacity(
                          opacity: 0.5,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: Image.asset(
                              'assets/images/photouploadside.png',
                              height: 100,
                            ),
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
              visible: imagesFileUpload['Image4'] != null &&
                  imagesFileUpload['Image4'].isNotEmpty,
              child: Positioned(
                top: -1,
                right: -1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imagesFileUpload['Image4'] = '';
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

  _upload({
    String path,
    String fileName,
    String url,
    String key,
    String bucket,
    String xAmzAlgorithm,
    String xAmzCredential,
    String xAmzDate,
    String policy,
    String xAmzSignature,
    fileType,
  }) async {
    try {
      dio.FormData data = dio.FormData.fromMap({
        "key": key,
        "bucket": bucket,
        "X-Amz-Algorithm": xAmzAlgorithm,
        "X-Amz-Credential": xAmzCredential,
        "X-Amz-Date": xAmzDate,
        "Policy": policy,
        "X-Amz-Signature": xAmzSignature,
        "file": await dio.MultipartFile.fromFile(
          path,
        ),
      });

      dio.Response resp = await dio.Dio().post(
        url,
        data: data,
      );

      print('-=-=-=>>' + resp.toString());

      setState(() {
        _imageToBeUploaded.add({'fileName': key, 'fileType': fileType});
      });
      return true;
    } catch (e) {
      print('=-=-==>>' + e.toString());
      return false;
    }
  }

  saveButton() => Padding(
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
              onPressed: _isLoading
                  ? null
                  : () async {
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
                            constant.animalType
                                .indexOf(animalInfo['animalType']),
                          ) &&
                          (animalInfo['animalIsPregnant'] == null))
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('animal_pregnancy_error'.tr),
                        );
                      else if ([0, 1].contains(
                            constant.animalType
                                .indexOf(animalInfo['animalType']),
                          ) &&
                          (animalInfo['animalMilk'] == null ||
                              animalInfo['animalMilk'].isEmpty))
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('animal_milk_error'.tr),
                        );
                      else if ([0, 1].contains(constant.animalType
                              .indexOf(animalInfo['animalType'])) &&
                          (animalInfo['animalMilk'] != null ||
                              animalInfo['animalMilk'].isNotEmpty) &&
                          (int.parse(animalInfo['animalMilk']) > 70))
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('maximum_milk_length'.tr),
                        );
                      else if (animalInfo['animalPrice'] == null ||
                          animalInfo['animalPrice'].isEmpty)
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('animal_price_error'.tr),
                        );
                      else if (imagesFileUpload['Image1'].isEmpty &&
                          imagesFileUpload['Image2'].isEmpty &&
                          imagesFileUpload['Image3'].isEmpty &&
                          imagesFileUpload['Image4'].isEmpty)
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('animal_image_error'.tr),
                        );
                      else if (([0, 1].contains(constant.animalType
                              .indexOf(animalInfo['animalType']))) &&
                          extraInfoData['alreadyPregnantYesNo'] == null)
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('animal_pregnant_empty_error'.tr),
                        );
                      else if (([0, 1].contains(constant.animalType
                              .indexOf(animalInfo['animalType']))) &&
                          constant.yesNo.indexOf(
                                  extraInfoData['alreadyPregnantYesNo']) ==
                              0 &&
                          extraInfoData['animalAlreadyGivenBirth'] == null)
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('animal_pregnant_time_error'.tr),
                        );
                      else if (([0, 1].contains(constant.animalType
                              .indexOf(animalInfo['animalType']))) &&
                          extraInfoData['isPregnantYesNo'] == null)
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('animal_gayabhin_empty_error'.tr),
                        );
                      else if (([0, 1].contains(constant.animalType
                              .indexOf(animalInfo['animalType']))) &&
                          constant.yesNo
                                  .indexOf(extraInfoData['isPregnantYesNo']) ==
                              0 &&
                          extraInfoData['animalIfPregnant'] == null)
                        ReusableWidgets.showDialogBox(
                          context,
                          'error'.tr,
                          Text('animal_gayabhin_time_error'.tr),
                        );
                      else {
                        setState(() {
                          _imageToBeUploaded.clear();
                        });
                        pr = new ProgressDialog(context,
                            type: ProgressDialogType.Normal,
                            isDismissible: false);
                        pr.style(message: 'progress_dialog_message'.tr);
                        pr.show();

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        List result = [];

                        if (ReusableWidgets.isTokenExpired(
                            prefs.getInt('expires') ?? 0)) {
                          bool status =
                              await refreshTokenController.getRefreshToken(
                                  refresh:
                                      prefs.getString('refreshToken') ?? '');
                          if (status) {
                            setState(() {
                              prefs.setString('accessToken',
                                  refreshTokenController.accessToken.value);
                              prefs.setString('refreshToken',
                                  refreshTokenController.refreshToken.value);
                              prefs.setInt('expires',
                                  refreshTokenController.expires.value);
                            });
                          } else {
                            print('Error getting token==' + status.toString());
                          }
                        }

                        if (imagesUpload["Image1"].length != 0) {
                          result.add(imagesUpload["Image1"]);
                        }
                        if (imagesUpload["Image2"].length != 0) {
                          result.add(imagesUpload["Image2"]);
                        }
                        if (imagesUpload["Image3"].length != 0) {
                          result.add(imagesUpload["Image3"]);
                        }
                        if (imagesUpload["Image4"].length != 0) {
                          result.add(imagesUpload["Image4"]);
                        }

                        List imageUploadingStatus =
                            await _uploadImageController.uploadImage(
                          userId: prefs.getString('userId'),
                          files: result,
                          token: prefs.getString('accessToken'),
                        );

                        List<bool> _isImageUploaded = [];

                        if (imageUploadingStatus.isBlank) {
                          ReusableWidgets.showDialogBox(context, 'error'.tr,
                              Text('issue uploading image'));
                        } else {
                          for (int i = 0;
                              i < imageUploadingStatus.length;
                              i++) {
                            bool uploadStatus = await _upload(
                              path: imagesFileUpload[imageUploadingStatus[i]
                                  .fields
                                  .key
                                  .split('_')[1]],
                              fileName: imageUploadingStatus[i].fields.key,
                              url: imageUploadingStatus[i].url,
                              key: imageUploadingStatus[i].fields.key,
                              bucket: imageUploadingStatus[i].fields.bucket,
                              xAmzAlgorithm:
                                  imageUploadingStatus[i].fields.xAmzAlgorithm,
                              xAmzCredential:
                                  imageUploadingStatus[i].fields.xAmzCredential,
                              xAmzDate: imageUploadingStatus[i].fields.xAmzDate,
                              policy: imageUploadingStatus[i].fields.policy,
                              xAmzSignature:
                                  imageUploadingStatus[i].fields.xAmzSignature,
                              fileType: result[i]['fileType'],
                            );

                            print('][]' + uploadStatus.toString());
                            _isImageUploaded.add(uploadStatus);
                          }
                        }

                        bool saveAnimalData = false;
                        if (animalInfo['animalType'] == 'cow'.tr ||
                            animalInfo['animalType'] == 'buffalo_female'.tr) {
                          saveAnimalData =
                              await sellAnimalController.saveAnimal(
                            animalType:
                                animalTypeMapping[animalInfo['animalType']],
                            animalBreed:
                                ReusableWidgets.removeEnglisgDataFromName(
                                    animalInfo['animalBreed']),
                            animalAge: ReusableWidgets.convertStringToInt(
                                animalInfo['animalAge']),
                            animalBayat: animalBayaatMapping[
                                animalInfo['animalIsPregnant']],
                            animalPrice: ReusableWidgets.convertStringToInt(
                                animalInfo['animalPrice']),
                            animalMilk: ReusableWidgets.convertStringToInt(
                                animalInfo['animalMilk']),
                            animalMilkCapacity:
                                ReusableWidgets.convertStringToInt(
                                    animalInfo['animalMilkCapacity']),
                            isRecentBayat: stringToYesNo[
                                extraInfoData['alreadyPregnantYesNo']],
                            recentBayatTime: stringToRecentBayaatTime[
                                extraInfoData['animalAlreadyGivenBirth']],
                            isPregnant:
                                stringToYesNo[extraInfoData['isPregnantYesNo']],
                            pregnantTime: stringToPregnantTime[
                                extraInfoData['animalIfPregnant']],
                            userId: prefs.getString('userId'),
                            moreInfo: extraInfoData['moreInfo'],
                            files: _imageToBeUploaded,
                            token: prefs.getString("accessToken"),
                          );
                        } else {
                          saveAnimalData =
                              await sellAnimalController.saveAnimal(
                            animalType:
                                animalTypeMapping[animalInfo['animalType']],
                            animalBreed:
                                ReusableWidgets.removeEnglisgDataFromName(
                                    animalInfo['animalBreed']),
                            animalAge: ReusableWidgets.convertStringToInt(
                                animalInfo['animalAge']),
                            animalBayat: animalBayaatMapping[
                                animalInfo['animalIsPregnant']],
                            animalPrice: ReusableWidgets.convertStringToInt(
                                animalInfo['animalPrice']),
                            userId: prefs.getString('userId'),
                            moreInfo: extraInfoData['moreInfo'],
                            files: _imageToBeUploaded,
                            token: prefs.getString("accessToken"),
                          );
                        }

                        bool uploadStatus = _isImageUploaded
                            .every((element) => element == true);

                        // print('][]' + uploadStatus.toString());
                        print('][]==' + _imageToBeUploaded.toString());

                        if (saveAnimalData && _imageToBeUploaded.isNotEmpty) {
                          pr.hide();
                          return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'pashu_registered'.tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        CloseButton(),
                                      ],
                                    ),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('new_animal'.tr),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'सूचना -',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                ' ऑनलाइन पेमेंट के धोखे से बचने के लिए कभी भी ऑनलाइन एडवांस पेमेंट, एडवांस, जमा राशि, ट्रांसपोर्ट इत्यादि के नाम पे, किसी भी एप से न करें, खासकर कि गूगल पे, फ़ोन पे, वरना नुकसान हो सकता है |',
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
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
                                          }),
                                    ]);
                              });
                        } else {
                          pr.hide();
                          ReusableWidgets.showDialogBox(
                              context,
                              'error'.tr,
                              Text(
                                  'Save animal error+${_imageToBeUploaded.isNotEmpty.toString()}'));
                        }
                      }
                    }),
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
    super.build(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, false),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: [0, 1].contains(
                  constant.animalType.indexOf(animalInfo['animalType']),
                )
                    ? extraINfoData()
                    : moreInfoTextArea(),
              ),
              // AnimatedOpacity(
              //   opacity: 1,
              //   // opacity: _showData ? 1 : 0,
              //   duration: Duration(seconds: 2),
              //   child: _showData
              //       ? Padding(
              //           padding: const EdgeInsets.symmetric(
              //               vertical: 4, horizontal: 8),
              //           child: [0, 1].contains(
              //             constant.animalType.indexOf(animalInfo['animalType']),
              //           )
              //               ? extraINfoData()
              //               : moreInfoTextArea(),
              //         )
              //       : SizedBox.shrink(),
              // ),
              saveButton()
            ],
          ),
        ),
      ),
    );
  }
}
