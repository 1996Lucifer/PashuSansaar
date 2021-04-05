import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import '../home_screen.dart';
import '../utils/constants.dart' as constant;
import 'package:dotted_border/dotted_border.dart';
import 'package:intl/intl.dart';
import 'package:geoflutterfire/geoflutterfire.dart' as geoFire;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SellAnimalEditForm extends StatefulWidget {
  final int index;
  final String userName;
  final String userMobileNumber;
  SellAnimalEditForm(
      {Key key,
      @required this.index,
      @required this.userName,
      @required this.userMobileNumber})
      : super(key: key);

  @override
  _SellAnimalEditFormState createState() => _SellAnimalEditFormState();
}

class _SellAnimalEditFormState extends State<SellAnimalEditForm>
    with AutomaticKeepAliveClientMixin {
  final geo = geoFire.Geoflutterfire();
  var animalInfo = {}, extraInfoData = {};
  String _base64Image;
  ImagePicker _picker;
  ProgressDialog pr;
  Color backgroundColor = Colors.red[50];
  bool _showData = false;
  // final _storage = new FlutterSecureStorage();
  SharedPreferences prefs;
  String uniqueId = '',
      isValidUser = '',
      userId = '',
      videoUrl = '',
      videoPath = '';
  VideoPlayerController _videoController;

  Map<String, dynamic> imagesUpload = {
    'image1': '',
    'image2': '',
    'image3': '',
    'image4': ''
  };

  TextEditingController _controller;
  static const _locale = 'en_IN';
  Subscription _subscription;
  double _progressState = 0;
  bool _isInitialised = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _controller = TextEditingController();
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      setState(() {
        _progressState = progress;
      });
    });

    super.initState();
    inititalValues();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
    _videoController.dispose();
  }

  inititalValues() async {
    prefs = await SharedPreferences.getInstance();
    var data;
    data = prefs.get('animalDetails');
    var jsonData = jsonDecode(data);

    if (jsonData.length > 0) {
      setState(() {
        animalInfo = jsonData[widget.index]['animalInfo'];
        // imagesUpload = jsonData[widget.index]['animalImages'];

        uniqueId = jsonData[widget.index]['uniqueId'];
        userId = jsonData[widget.index]['userId'];
        isValidUser = jsonData[widget.index]['isValidUser'];
        extraInfoData = jsonData[widget.index]['extraInfo'];

        _controller = TextEditingController(
            text: _currency +
                '${_formatNumber(animalInfo['animalPrice'].replaceAll(',', ''))}');
      });
    }
  }

  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(
        int.parse(s),
      );
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

  Future<void> uploadFile(String filePath) async {
    await VideoCompress.compressVideo(
      filePath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    ).then((info) async {
      return _progressState.toStringAsFixed(2) == '100.00'
          ? await firebase_storage.FirebaseStorage.instance
              .ref('${FirebaseAuth.instance.currentUser.uid}/$uniqueId.mp4')
              .putFile(info.file)
          : CircularProgressIndicator();
    });

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('${FirebaseAuth.instance.currentUser.uid}/$uniqueId.mp4')
        .getDownloadURL();

    setState(() {
      videoUrl = downloadURL;
    });
  }

  Future<void> _choose(index) async {
    try {
      if (_picker == null) {
        _picker = ImagePicker();
      }
      var pickedFile = await _picker.getVideo(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          maxDuration: Duration(minutes: 1));

      switch (pickedFile) {
        case null:
          return null;
          break;
        default:
          File file = File(pickedFile.path);
          setState(() {
            videoPath = file.path;
          });

          _videoController = VideoPlayerController.file(File(videoPath));

          _videoController.addListener(() {
            setState(() {});
          });
          _videoController.setLooping(true);
          _videoController.initialize().then((_) {
            setState(() {
              _isInitialised = true;
            });
          });

          _videoController.play();
      }
    } catch (e) {}
  }

  Future<void> _chooseFromGallery(String index) async {
    try {
      if (_picker == null) {
        _picker = ImagePicker();
      }
      var pickedFile = await _picker.getVideo(
          source: ImageSource.gallery,
          preferredCameraDevice: CameraDevice.rear,
          maxDuration: Duration(minutes: 1));
      switch (pickedFile) {
        case null:
          return null;
          break;
        default:
          File file = File(pickedFile.path);
          setState(() {
            videoPath = file.path;
          });
      }

      _videoController = VideoPlayerController.file(File(videoPath));

      _videoController.addListener(() {
        setState(() {});
      });
      _videoController.setLooping(true);
      _videoController.initialize().then((_) {
        setState(() {
          _isInitialised = true;
        });
      });

      _videoController.play();
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
              items: [0, 2].contains(
                constant.animalType.indexOf(animalInfo['animalType']),
              )
                  ? constant.animalBreedCowOx
                  : [1, 3].contains(
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
                  String string = '${_formatNumber(price.replaceAll(',', ''))}';
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

  _videoStructure(width) {
    return Padding(
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
                      height: 200,
                      width: width * 0.9,
                      // color: Colors.amber,
                      child: Visibility(
                          visible: _videoController == null && !_isInitialised,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    'वीडियो चुने',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                )
                              ]),
                          replacement: Visibility(
                            visible: _isInitialised,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                    width: width * 0.9,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        VideoPlayer(_videoController),
                                      ],
                                    )),
                                Visibility(
                                  visible: _isInitialised,
                                  child: Positioned(
                                    top: -1,
                                    right: -1,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          videoPath = '';
                                          _videoController.pause();
                                          _isInitialised = false;
                                        });
                                      },
                                      child: Icon(
                                        Icons.cancel_rounded,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  replacement: SizedBox.shrink(),
                                ),
                                _videoController == null
                                    ? SizedBox.shrink()
                                    : ValueListenableBuilder(
                                        valueListenable: _videoController,
                                        builder: (context,
                                                VideoPlayerValue value,
                                                child) =>
                                            Row(
                                          children: [
                                            IconButton(
                                                icon: Icon(
                                                  _videoController
                                                          .value.isPlaying
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                ),
                                                onPressed: () => setState(() {
                                                      _videoController
                                                              .value.isPlaying
                                                          ? _videoController
                                                              .pause()
                                                          : _videoController
                                                              .play();
                                                    })),
                                            Container(
                                              width: width * 0.5,
                                              child: VideoProgressIndicator(
                                                  _videoController,
                                                  allowScrubbing: true),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                '0' +
                                                    value.position.inMinutes
                                                        .toString() +
                                                    ':' +
                                                    value.position.inSeconds
                                                        .toString(),
                                                style: TextStyle(
                                                    color: primaryColor))

                                            //       Row(
                                            // children: [
                                            // ],
                                            // )
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                            replacement: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      'वीडियो चुने',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  )
                                ]),
                          )),
                    )),
              ),
            ],
          ),
        ));
  }

  _descriptionText() {
    String animalBreedCheck = (animalInfo['animalBreed'] == 'not_known'.tr)
        ? ""
        : animalInfo['animalBreed'];
    String animalTypeCheck = (animalInfo['animalType'] == 'other_animal'.tr)
        ? animalInfo['animalTypeOther']
        : animalInfo['animalType'];

    String desc = '';

    String stmn2 = 'यह ${extraInfoData['animalAlreadyGivenBirth']} ब्यायी है ';
    String stmn3 = 'और अभी ${extraInfoData['animalIfPregnant']} है। ';
    String stmn41 = 'इसके साथ में बच्चा नहीं है। ';
    String stmn42 = 'इसके साथ में ${extraInfoData['animalHasBaby']}। ';
    String stmn5 =
        'पिछले बार के हिसाब से दूध कैपेसिटी ${animalInfo['animalMilk']} लीटर है। ';

    if (animalInfo['animalType'] == 'buffalo_male'.tr ||
        animalInfo['animalType'] == 'ox'.tr ||
        animalInfo['animalType'] == 'other_animal'.tr) {
      desc =
          'ये $animalBreedCheck $animalTypeCheck ${animalInfo['animalAge']} साल की है। ';
    } else {
      desc =
          'ये ${animalInfo['animalBreed']} ${animalInfo['animalType']} ${animalInfo['animalAge']} साल का है। ';
      if (extraInfoData['animalAlreadyGivenBirth'] != null) desc = desc + stmn2;
      if (extraInfoData['animalIfPregnant'] != null) desc = desc + stmn3;
      desc = desc +
          (extraInfoData['animalHasBaby'] == null ||
                  extraInfoData['animalHasBaby'] == 'nothing'.tr
              ? stmn41
              : stmn42);
      desc = desc + stmn5;
    }

    return desc + (extraInfoData['moreInfo'] ?? '');
  }

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
              else if ([0, 3].contains(
                    constant.animalType.indexOf(animalInfo['animalType']),
                  ) &&
                  (animalInfo['animalIsPregnant'] == null))
                ReusableWidgets.showDialogBox(
                  context,
                  'error'.tr,
                  Text('animal_pregnancy_error'.tr),
                );
              else if ([0, 3].contains(
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
                pr = new ProgressDialog(context,
                    type: ProgressDialogType.Normal, isDismissible: false);
                pr.style(message: 'progress_dialog_message'.tr);
                pr.show();

                FirebaseFirestore.instance
                    .collection("animalSellingInfo")
                    .doc(userId)
                    .collection('sellingAnimalList')
                    .doc(uniqueId)
                    .update({
                  'animalInfo': animalInfo,
                  'animalImages': imagesUpload,
                  'extraInfo': extraInfoData,
                  'dateOfSaving':
                      ReusableWidgets.dateTimeToEpoch(DateTime.now()),
                  'uniqueId': uniqueId,
                  'isValidUser': isValidUser,
                  'userId': userId,
                  "animalDescription": _descriptionText(),
                }).then((res) async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var addresses = await Geocoder.local
                      .findAddressesFromCoordinates(Coordinates(
                          prefs.getDouble('latitude'),
                          prefs.getDouble('longitude')));
                  var first = addresses.first;
                  FirebaseFirestore.instance
                      .collection("buyingAnimalList")
                      .doc(uniqueId + userId)
                      .update({
                    "userAnimalDescription": _descriptionText(),
                    "userAnimalType": animalInfo['animalType'] ?? "",
                    "userAnimalTypeOther": animalInfo['animalTypeOther'] ?? "",
                    "userAnimalAge": animalInfo['animalAge'] ?? "",
                    "userAddress": first.addressLine ??
                        (first.adminArea + ', ' + first.countryName),
                    "userName": widget.userName,
                    "userAnimalPrice": animalInfo['animalPrice'] ?? "0",
                    "userAnimalBreed": animalInfo['animalBreed'] ?? "",
                    "userMobileNumber": '${widget.userMobileNumber}',
                    "userAnimalMilk": animalInfo['animalMilk'] ?? "",
                    "userAnimalPregnancy": animalInfo['animalIsPregnant'] ?? "",
                    "userLatitude": prefs.getDouble('latitude'),
                    "userLongitude": prefs.getDouble('longitude'),
                    'position': geo
                        .point(
                            latitude: prefs.getDouble('latitude'),
                            longitude: prefs.getDouble('longitude'))
                        .data,
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
                        ReusableWidgets.dateTimeToEpoch(DateTime.now()),
                    'uniqueId': uniqueId,
                    'isValidUser': isValidUser,
                    'userId': userId,
                    'extraInfo': extraInfoData
                  }).then((value) {
                    pr.hide();
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: Text('pashu_re_registered'.tr),
                              content: Text('updated_animal'.tr),
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
                    selectedItem: extraInfoData['alreadyPregnantYesNo'],
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
                          selectedItem:
                              extraInfoData['animalAlreadyGivenBirth'],
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
                    selectedItem: extraInfoData['isPregnantYesNo'],
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
                          selectedItem: extraInfoData['animalIfPregnant'],
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
              selectedItem: extraInfoData['animalHasBaby'],
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
        child: TextFormField(
          initialValue: extraInfoData['moreInfo'],
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
              [0, 3].contains(
                constant.animalType.indexOf(animalInfo['animalType']),
              )
                  ? animalIsPregnant()
                  : SizedBox.shrink(),
              [0, 3].contains(
                constant.animalType.indexOf(animalInfo['animalType']),
              )
                  ? animalMilkPerDay()
                  : SizedBox.shrink(),
              [0, 3].contains(
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
