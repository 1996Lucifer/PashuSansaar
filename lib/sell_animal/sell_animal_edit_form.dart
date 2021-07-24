import 'dart:convert';
import 'dart:io' show File;
import 'dart:math';

import 'package:pashusansaar/my_animals/myAnimalModel.dart';
import 'package:pashusansaar/refresh_token/refresh_token_controller.dart';
import 'package:pashusansaar/sell_animal/sell_animal_controller.dart';
import 'package:pashusansaar/sell_animal/update_animal_controller.dart';
import 'package:pashusansaar/upload_image/upload_image_controller.dart';
import 'package:pashusansaar/utils/colors.dart' show appPrimaryColor;
import 'package:pashusansaar/utils/constants.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart' show ReusableWidgets;
import 'package:dropdown_search/dropdown_search.dart' show DropdownSearch, Mode;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show
        FilteringTextInputFormatter,
        TextEditingValue,
        TextInputFormatter,
        TextInputType,
        TextPosition,
        TextSelection;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';
import '../utils/constants.dart' as constant;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:intl/intl.dart' as intl;
import 'package:dio/dio.dart' as dio;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:mime/mime.dart';

class SellAnimalEditForm extends StatefulWidget {
  MyAnimals animalInfo;
  final int index;
  final String userName;
  final String userMobileNumber;
  SellAnimalEditForm({
    Key key,
    @required this.animalInfo,
    @required this.index,
    @required this.userName,
    @required this.userMobileNumber,
  }) : super(key: key);

  @override
  _SellAnimalEditFormState createState() => _SellAnimalEditFormState();
}

class _SellAnimalEditFormState extends State<SellAnimalEditForm>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic> extraInfoData = {}, animalUpdationData = {};
  ImagePicker _picker;
  ProgressDialog pr;
  Color backgroundColor = Colors.red[50];
  bool _showData = false;
  SharedPreferences prefs;
  String isValidUser = '',
      userId = '',
      desc = '',
      fileUrl = '',
      _animalOtherType = '';
  File filePath;
  List _imageToBeUploaded = [];

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

  Map<String, dynamic> editImagesUpload = {
    'Image1': '',
    'Image2': '',
    'Image3': '',
    'Image4': ''
  };

  TextEditingController _controller;
  static const _locale = 'en_IN';
  final UploadImageController _uploadImageController =
      Get.put(UploadImageController());
  final RefreshTokenController refreshTokenController =
      Get.put(RefreshTokenController());
  final SellAnimalController sellAnimalController =
      Get.put(SellAnimalController());
  final UpdateAnimalController updateAnimalController =
      Get.put(UpdateAnimalController());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
    inititalValues();
  }

  inititalValues() async {
    prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> _animalUpdationData = {},
        _imagesUpload = {
          'Image1': {},
          'Image2': {},
          'Image3': {},
          'Image4': {}
        },
        _editImagesUpload = {
          'Image1': {},
          'Image2': {},
          'Image3': {},
          'Image4': {}
        };
    List imageToBeUploaded = [];

    _animalUpdationData = {
      "location": widget.animalInfo.location,
      "_id": widget.animalInfo.sId,
      "animalType": widget.animalInfo.animalType,
      "animalBreed": widget.animalInfo.animalBreed,
      "animalAge": widget.animalInfo.animalAge,
      "animalBayat": widget.animalInfo.animalBayat,
      "animalMilk": widget.animalInfo.animalMilk,
      "animalMilkCapacity": widget.animalInfo.animalMilkCapacity,
      "animalPrice": widget.animalInfo.animalPrice,
      "isRecentBayat": widget.animalInfo.isRecentBayat,
      "recentBayatTime": widget.animalInfo.recentBayatTime,
      "isPregnant": widget.animalInfo.isPregnant,
      "pregnantTime": widget.animalInfo.pregnantTime,
      "moreInfo": widget.animalInfo.moreInfo,
      "userId": widget.animalInfo.userId,
      "animalStatus": widget.animalInfo.animalStatus,
      "verificationStatus": widget.animalInfo.verificationStatus,
      "longitude": widget.animalInfo.longitude,
      "latitude": widget.animalInfo.latitude,
      "userName": widget.animalInfo.userName,
      "district": widget.animalInfo.district,
      "zipCode": widget.animalInfo.zipCode,
      "userAddress": widget.animalInfo.userAddress,
      "mobile": widget.animalInfo.mobile,
      "createdAt": widget.animalInfo.createdAt,
      "updatedAt": widget.animalInfo.updatedAt,
      "__v": widget.animalInfo.iV,
      "animalHasBaby": widget.animalInfo.animalHasBaby,
    };

    for (int i = 0; i < widget.animalInfo.files.length; i++) {
      String _imageName = widget.animalInfo.files[i].fileName
          .split('.')[4]
          .split('/')[2]
          .split('_')[1];
      _editImagesUpload[_imageName] =
          widget.animalInfo?.files[i]?.fileName ?? '';
      _imagesUpload[_imageName] = {
        "fileName": widget.animalInfo?.files[i]?.fileType?.split('^')[1],
        "fileType": widget.animalInfo?.files[i]?.fileType?.split('^')[0]
      };
      imageToBeUploaded.add({
        "fileName": widget.animalInfo?.files[i]?.fileType?.split('^')[1],
        "fileType": widget.animalInfo?.files[i]?.fileType?.split('^')[0]
      });
    }
    setState(() {
      animalUpdationData = _animalUpdationData;
      editImagesUpload = _editImagesUpload;
      imagesUpload = _imagesUpload;
      _imageToBeUploaded = imageToBeUploaded;
      if (widget.animalInfo.animalType > 4) {
        _animalOtherType = constant.animalType[4];
      }
      _controller = TextEditingController(
          text: _currency +
              '${_formatNumber(widget.animalInfo.animalPrice.toString().replaceAll(',', ''))}');
    });
  }

  String _formatNumber(String s) =>
      intl.NumberFormat.decimalPattern(_locale).format(
        int.parse(s),
      );
  String get _currency =>
      intl.NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

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
              editImagesUpload['Image$index'] = '';
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
              editImagesUpload['Image$index'] = '';
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

        IgnorePointer(
          ignoring: true,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: DropdownSearch<String>(
              mode: Mode.BOTTOM_SHEET,
              showSelectedItem: true,
              items: constant.animalType,
              label: 'animal_type'.tr,
              hint: 'animal_type'.tr,
              selectedItem: widget.animalInfo.animalType > 4
                  ? constant.animalType[4]
                  : intToAnimalTypeMapping[widget.animalInfo.animalType],
              onChanged: (String type) {
                setState(() {
                  animalUpdationData['animalType'] = animalTypeMapping[type];

                  if (animalUpdationData['animalType'] < 5) {
                    _animalOtherType = '';
                  } else {
                    _animalOtherType = type;
                  }
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
        ),
        if (_animalOtherType.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: DropdownSearch<String>(
              mode: Mode.BOTTOM_SHEET,
              showSelectedItem: true,
              items: constant.animalTypeOther,
              label: 'other_animal'.tr,
              hint: 'other_animal'.tr,
              selectedItem:
                  intToAnimalOtherTypeMapping[widget.animalInfo.animalType],
              onChanged: (String otherType) {
                setState(() {
                  animalUpdationData['animalType'] =
                      animalOtherTypeMapping[otherType];
                  if (animalUpdationData['animalType'] < 5) {
                    _animalOtherType = '';
                  }
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
        ],
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
              selectedItem: widget.animalInfo.animalBreed,
              items: widget.animalInfo.animalType == 1 ||
                      widget.animalInfo.animalType == 3
                  ? constant.animalBreedCowOx
                  : widget.animalInfo.animalType == 2 ||
                          widget.animalInfo.animalType == 4
                      ? constant.animalBreedBuffaloFemaleMale
                      : ['not_known'.tr],
              label: 'animal_breed'.tr,
              hint: 'animal_breed'.tr,
              showSearchBox: true,
              onChanged: (String breed) {
                setState(() {
                  animalUpdationData['animalBreed'] = breed;
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
              selectedItem: widget.animalInfo.animalAge.toString(),
              items: constant.animalAge,
              label: 'animal_age'.tr,
              hint: 'animal_age'.tr,
              onChanged: (String age) {
                setState(() {
                  animalUpdationData['animalAge'] =
                      ReusableWidgets.convertStringToInt(age);
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
              selectedItem:
                  intToAnimalBayaatMapping[widget.animalInfo.animalBayat],
              showSearchBox: true,
              onChanged: (String pregnant) {
                setState(() {
                  animalUpdationData['animalBayat'] =
                      animalBayaatMapping[pregnant];
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
                initialValue: widget.animalInfo.animalMilk.toString(),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  // FilteringTextInputFormatter.deny(RegExp(r'^0+'))
                ],
                keyboardType: TextInputType.number,
                onChanged: (String milk) {
                  setState(() {
                    animalUpdationData['animalMilk'] =
                        ReusableWidgets.convertStringToInt(
                            milk.replaceAll(new RegExp(r'^0+(?=.)'), ''));
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
                initialValue: widget.animalInfo.animalMilkCapacity.toString(),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.deny(RegExp(r'^0+'))
                ],
                keyboardType: TextInputType.number,
                onChanged: (String milkCapacity) {
                  setState(() {
                    animalUpdationData['animalMilkCapacity'] =
                        ReusableWidgets.convertStringToInt(milkCapacity);
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
                // initialValue:
                //     '${_formatNumber(widget.animalInfo.animalPrice.toString())}',
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
                    animalUpdationData['animalPrice'] =
                        ReusableWidgets.convertStringToInt(price);
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
                    child: editImagesUpload['Image1'].isNotEmpty
                        ? Visibility(
                            visible: editImagesUpload['Image1'] != null &&
                                editImagesUpload['Image1'].isNotEmpty,
                            child: Image.network(
                              editImagesUpload['Image1'],
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                            replacement: Column(
                              children: [
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Visibility(
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )
                            ]),
                          ),
                  ),
                ),
              ),
              editImagesUpload['Image1'].isNotEmpty
                  ? Visibility(
                      visible: editImagesUpload['Image1'] != null &&
                          editImagesUpload['Image1'].isNotEmpty,
                      child: Positioned(
                        top: -1,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              editImagesUpload['Image1'] = '';
                              _imageToBeUploaded.removeWhere((element) =>
                                  element['fileName'].contains('Image1'));
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
                  : Visibility(
                      visible: imagesFileUpload['Image1'] != null &&
                          imagesFileUpload['Image1'].isNotEmpty,
                      child: Positioned(
                        top: -1,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imagesFileUpload['Image1'] = '';
                              _imageToBeUploaded.removeWhere((element) =>
                                  element['fileName'].contains('Image1'));
                            });
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      replacement: SizedBox.shrink(),
                    ),
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
                    child: editImagesUpload['Image2'].isNotEmpty
                        ? Visibility(
                            visible: editImagesUpload['Image2'] != null &&
                                editImagesUpload['Image2'].isNotEmpty,
                            child: Image.network(
                              editImagesUpload['Image2'],
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                            replacement: Column(
                              children: [
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Visibility(
                            visible: imagesFileUpload['Image2'] != null &&
                                imagesFileUpload['Image2'].isNotEmpty,
                            child: Image.file(
                              File(imagesFileUpload['Image2']),
                            ),
                            replacement: Column(
                              children: [
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              editImagesUpload['Image2'].isNotEmpty
                  ? Visibility(
                      visible: editImagesUpload['Image2'] != null &&
                          editImagesUpload['Image2'].isNotEmpty,
                      child: Positioned(
                        top: -1,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              editImagesUpload['Image2'] = '';
                              _imageToBeUploaded.removeWhere((element) =>
                                  element['fileName'].contains('Image2'));
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
                  : Visibility(
                      visible: imagesFileUpload['Image2'] != null &&
                          imagesFileUpload['Image2'].isNotEmpty,
                      child: Positioned(
                        top: -1,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imagesFileUpload['Image2'] = '';
                              _imageToBeUploaded.removeWhere((element) =>
                                  element['fileName'].contains('Image2'));
                            });
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      replacement: SizedBox.shrink(),
                    ),
            ],
          ),
        ),
      );

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
                    child: editImagesUpload['Image3'].isNotEmpty
                        ? Visibility(
                            visible: editImagesUpload['Image3'] != null &&
                                editImagesUpload['Image3'].isNotEmpty,
                            child: Image.network(
                              editImagesUpload['Image3'],
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                            replacement: Column(
                              children: [
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Visibility(
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )
                            ]),
                          ),
                  ),
                ),
              ),
              editImagesUpload['Image3'].isNotEmpty
                  ? Visibility(
                      visible: editImagesUpload['Image3'] != null &&
                          editImagesUpload['Image3'].isNotEmpty,
                      child: Positioned(
                        top: -1,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              editImagesUpload['Image3'] = '';
                              _imageToBeUploaded.removeWhere((element) =>
                                  element['fileName'].contains('Image3'));
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
                  : Visibility(
                      visible: imagesFileUpload['Image3'] != null &&
                          imagesFileUpload['Image3'].isNotEmpty,
                      child: Positioned(
                        top: -1,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imagesFileUpload['Image3'] = '';
                              _imageToBeUploaded.removeWhere((element) =>
                                  element['fileName'].contains('Image3'));
                            });
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      replacement: SizedBox.shrink(),
                    ),
            ],
          ),
        ),
      );

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
                    child: editImagesUpload['Image4'].isNotEmpty
                        ? Visibility(
                            visible: editImagesUpload['Image4'] != null &&
                                editImagesUpload['Image4'].isNotEmpty,
                            child: Image.network(
                              editImagesUpload['Image4'],
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                            replacement: Column(
                              children: [
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Visibility(
                            visible: imagesFileUpload['Image4'] != null &&
                                imagesFileUpload['Image4'].isNotEmpty,
                            child: Image.file(
                              File(imagesFileUpload['Image4']),
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )
                            ]),
                          ),
                  ),
                ),
              ),
              editImagesUpload['Image4'].isNotEmpty
                  ? Visibility(
                      visible: editImagesUpload['Image4'] != null &&
                          editImagesUpload['Image4'].isNotEmpty,
                      child: Positioned(
                        top: -1,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              editImagesUpload['Image4'] = '';
                              _imageToBeUploaded.removeWhere((element) =>
                                  element['fileName'].contains('Image4'));
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
                  : Visibility(
                      visible: imagesFileUpload['Image4'] != null &&
                          imagesFileUpload['Image4'].isNotEmpty,
                      child: Positioned(
                        top: -1,
                        right: -1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              imagesFileUpload['Image4'] = '';
                              _imageToBeUploaded.removeWhere((element) =>
                                  element['fileName'].contains('Image4'));
                            });
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      replacement: SizedBox.shrink(),
                    ),
            ],
          ),
        ),
      );

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

      print('-Response=-=-=>>' + resp.toString());

      // if (key.contains(_imageToBeUploaded[i]['fileName'].split('_')[1])) {
      _imageToBeUploaded.removeWhere((element) {
        print('element===>' + element.toString());
        // return false;
        return element['fileName'].contains(key.split('_')[1]);
      });
      // }

      // print('-_imageToBeUploadedBefore=-=-=>>' + _imageToBeUploaded.toString());

      setState(() {
        _imageToBeUploaded.add({'fileName': key, 'fileType': fileType});
      });
      // print('-_imageToBeUploadedAfter=-=-=>>' + _imageToBeUploaded.toString());
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
              onPressed: () async {
                if (animalUpdationData['animalType'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_type_error'.tr),
                  );
                else if (animalUpdationData['animalBreed'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_breed_error'.tr),
                  );
                else if (animalUpdationData['animalAge'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_age_error'.tr),
                  );
                else if ((animalUpdationData['animalType'] == 1 ||
                        animalUpdationData['animalType'] == 2) &&
                    animalUpdationData['animalBayat'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_pregnancy_error'.tr),
                  );
                else if ((animalUpdationData['animalType'] == 1 ||
                        animalUpdationData['animalType'] == 2) &&
                    animalUpdationData['animalMilk'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_milk_error'.tr),
                  );
                else if ((animalUpdationData['animalType'] == 1 ||
                        animalUpdationData['animalType'] == 2) &&
                    animalUpdationData['animalMilk'] != null &&
                    animalUpdationData['animalMilk'] > 70)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('maximum_milk_length'.tr),
                  );
                else if (animalUpdationData['animalPrice'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_price_error'.tr),
                  );
                else if ((editImagesUpload['Image1'].isEmpty &&
                        imagesFileUpload['Image1'].isEmpty) &&
                    (editImagesUpload['Image2'].isEmpty &&
                        imagesFileUpload['Image2'].isEmpty) &&
                    (editImagesUpload['Image3'].isEmpty &&
                        imagesFileUpload['Image3'].isEmpty) &&
                    (editImagesUpload['Image4'].isEmpty &&
                        imagesFileUpload['Image4'].isEmpty))
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_image_error'.tr),
                  );
                else if ((animalUpdationData['animalType'] == 1 ||
                        animalUpdationData['animalType'] == 2) &&
                    animalUpdationData['isRecentBayat'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_pregnant_empty_error'.tr),
                  );
                else if ((animalUpdationData['animalType'] == 1 ||
                        animalUpdationData['animalType'] == 2) &&
                    animalUpdationData['isRecentBayat'] ==
                        constant.yesNo.first &&
                    animalUpdationData['recentBayatTime'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_pregnant_time_error'.tr),
                  );
                else if ((animalUpdationData['animalType'] == 1 ||
                        animalUpdationData['animalType'] == 2) &&
                    animalUpdationData['isPregnant'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_gayabhin_empty_error'.tr),
                  );
                else if ((animalUpdationData['animalType'] == 1 ||
                        animalUpdationData['animalType'] == 2) &&
                    animalUpdationData['isPregnant'] == constant.yesNo.first &&
                    animalUpdationData['animalIfPregnant'] == null)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_gayabhin_time_error'.tr),
                  );
                else {
                  // setState(() {
                  //   _imageToBeUploaded.clear();
                  // });
                  pr = new ProgressDialog(context,
                      type: ProgressDialogType.Normal, isDismissible: false);
                  pr.style(message: 'progress_dialog_message'.tr);
                  pr.show();

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  List result = [];

                  try {
                    if (ReusableWidgets.isTokenExpired(
                        prefs.getInt('expires') ?? 0)) {
                      bool status =
                          await refreshTokenController.getRefreshToken(
                              refresh: prefs.getString('refreshToken') ?? '');
                      if (status) {
                        setState(() {
                          prefs.setString('accessToken',
                              refreshTokenController.accessToken.value);
                          prefs.setString('refreshToken',
                              refreshTokenController.refreshToken.value);
                          prefs.setInt(
                              'expires', refreshTokenController.expires.value);
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

                  List imageUploadingStatus;
                  try {
                    imageUploadingStatus =
                        await _uploadImageController.uploadImage(
                      userId: prefs.getString('userId'),
                      files: result,
                      token: prefs.getString('accessToken'),
                    );
                  } catch (e) {
                    ReusableWidgets.showDialogBox(
                      context,
                      'warning'.tr,
                      Text(
                        'global_error'.tr,
                      ),
                    );
                  }

                  if (imageUploadingStatus.isBlank) {
                    ReusableWidgets.showDialogBox(
                        context, 'error'.tr, Text('issue uploading image'));
                  } else {
                    for (int i = 0; i < imageUploadingStatus.length; i++) {
                      bool uploadStatus = await _upload(
                        path: imagesFileUpload[
                            imageUploadingStatus[i].fields.key.split('_')[1]],
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
                    }
                  }

                  print('animalUpdationData=====' +
                      animalUpdationData.toString());

                  bool saveAnimalData = false;
                  if (animalUpdationData['animalType'] == 1 ||
                      animalUpdationData['animalType'] == 2) {
                    try {
                      saveAnimalData =
                          await updateAnimalController.updateAnimal(
                        animalType: animalUpdationData['animalType'],
                        animalBreed: animalUpdationData['animalBreed'],
                        animalAge: animalUpdationData['animalAge'],
                        animalBayat: animalUpdationData['animalBayat'],
                        animalPrice: animalUpdationData['animalPrice'],
                        animalMilk: animalUpdationData['animalMilk'],
                        animalMilkCapacity:
                            animalUpdationData['animalMilkCapacity'],
                        isRecentBayat: animalUpdationData['isRecentBayat'],
                        recentBayatTime: animalUpdationData['recentBayatTime'],
                        isPregnant: animalUpdationData['isPregnant'],
                        pregnantTime: animalUpdationData['pregnantTime'],
                        animalHasBaby: animalUpdationData['animalHasBaby'],
                        userId: prefs.getString('userId'),
                        animalId: widget.animalInfo.sId,
                        moreInfo: animalUpdationData['moreInfo'],
                        files: _imageToBeUploaded,
                        token: prefs.getString("accessToken"),
                      );
                    } catch (e) {
                      ReusableWidgets.showDialogBox(
                        context,
                        'warning'.tr,
                        Text(
                          'global_error'.tr,
                        ),
                      );
                    }
                  } else {
                    try {
                      saveAnimalData =
                          await updateAnimalController.updateAnimal(
                        animalType: animalUpdationData['animalType'],
                        animalBreed: animalUpdationData['animalBreed'],
                        animalAge: animalUpdationData['animalAge'],
                        animalBayat: animalUpdationData['animalBayat'],
                        animalPrice: animalUpdationData['animalPrice'],
                        userId: prefs.getString('userId'),
                        animalId: widget.animalInfo.sId,
                        moreInfo: animalUpdationData['moreInfo'],
                        files: _imageToBeUploaded,
                        token: prefs.getString("accessToken"),
                      );
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

                  print('][]==' + _imageToBeUploaded.toString());

                  if (saveAnimalData && _imageToBeUploaded.isNotEmpty) {
                    pr.hide();
                    return showDialog(
                        context: context,
                        barrierDismissible: false,
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
                                    'pashu_re_registered'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  // CloseButton(),
                                ],
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('updated_animal'.tr),
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
                                      style: TextStyle(color: appPrimaryColor),
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
                    selectedItem: widget.animalInfo.isRecentBayat
                        ? yesNo.first
                        : yesNo.last,
                    maxHeight: 120,
                    onChanged: (String yesOrNo) {
                      setState(() {
                        animalUpdationData['isRecentBayat'] =
                            yesOrNo == constant.yesNo.first;
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
                animalUpdationData['isRecentBayat'] != null &&
                        animalUpdationData['isRecentBayat']
                    ? SizedBox(width: 5)
                    : SizedBox.shrink(),
                animalUpdationData['isRecentBayat'] != null &&
                        animalUpdationData['isRecentBayat']
                    ? Expanded(
                        flex: 3,
                        child: DropdownSearch<String>(
                          mode: Mode.BOTTOM_SHEET,
                          showSelectedItem: true,
                          items: constant.ifPregnant,
                          selectedItem: intToRecentBayaatTime[
                              widget.animalInfo.recentBayatTime],
                          onChanged: (String age) {
                            setState(() {
                              animalUpdationData['recentBayatTime'] =
                                  stringToRecentBayaatTime[age];
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
                    selectedItem:
                        widget.animalInfo.isPregnant ? yesNo[0] : yesNo[1],
                    // label: 'animal_age'.tr,
                    // hint: 'animal_age'.tr,
                    maxHeight: 120,
                    onChanged: (String yesOrNo) {
                      setState(() {
                        animalUpdationData['isPregnant'] =
                            yesOrNo == constant.yesNo.first;
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
                animalUpdationData['isPregnant'] != null &&
                        animalUpdationData['isPregnant']
                    ? SizedBox(width: 5)
                    : SizedBox.shrink(),
                animalUpdationData['isPregnant'] != null &&
                        animalUpdationData['isPregnant']
                    ? Expanded(
                        flex: 3,
                        child: DropdownSearch<String>(
                          mode: Mode.BOTTOM_SHEET,
                          showSelectedItem: true,
                          items: constant.isPregnant,
                          selectedItem:
                              intToPregnantTime[widget.animalInfo.pregnantTime],
                          // label: 'animal_age'.tr,
                          // hint: 'animal_age'.tr,
                          onChanged: (String time) {
                            setState(() {
                              animalUpdationData['pregnantTime'] =
                                  stringToPregnantTime[time];
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
              selectedItem: intToAnimalHasBaby[widget.animalInfo.animalHasBaby],
              maxHeight: 200,
              onChanged: (String baby) {
                setState(() {
                  animalUpdationData['animalHasBaby'] =
                      stringToAnimalHasBaby[baby];
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
        child: TextFormField(
          initialValue: widget.animalInfo.moreInfo,
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
              animalUpdationData['moreInfo'] = text;
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
              if (widget.animalInfo.animalType == 1 ||
                  widget.animalInfo.animalType == 2) ...[animalIsPregnant()],
              if (widget.animalInfo.animalType == 1 ||
                  widget.animalInfo.animalType == 2) ...[animalMilkPerDay()],
              if (widget.animalInfo.animalType == 1 ||
                  widget.animalInfo.animalType == 2) ...[
                animalMilkPerDayCapacity()
              ],
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
                child: animalUpdationData['animalType'] == 1 ||
                        animalUpdationData['animalType'] == 2
                    ? extraINfoData()
                    : moreInfoTextArea(),
              ),
              saveButton()
            ],
          ),
        ),
      ),
    );
  }
}
