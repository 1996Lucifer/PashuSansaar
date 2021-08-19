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
import 'package:intl/intl.dart' as intl;
import 'package:dio/dio.dart' as dio;
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class SellAnimalEditForm extends StatefulWidget {
  final MyAnimals animalInfo;
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
  bool _showData = false, _isInitialised = false;
  SharedPreferences prefs;
  String isValidUser = '',
      userId = '',
      desc = '',
      fileUrl = '',
      videoPath = '',
      thumbNail = '';
  File filePath;
  VideoPlayerController _videoController, _videoController1;
  List _imageToBeUploaded = [], _videoToBeUploaded = [];
  Subscription _subscription;
  double _progressState = 0;

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

  Map<String, dynamic> videoUpload = {
    'Video': {},
    'thumbnail': {},
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
    _subscription = VideoCompress.compressProgress$.subscribe((progress) {
      setState(() {
        _progressState = progress;
      });
      print('_progressState=Edit==' + _progressState.toString());
    });
    super.initState();
    inititalValues();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
    _videoController.dispose();
    _videoController1.dispose();
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
        },
        _videosUpload = {
          'Video': {},
          'thumbnail': {},
        },
        _editVideosUpload = {
          'Video': {},
          'thumbnail': {},
        };
    List imageToBeUploaded = [], videoToBeUploaded = [];

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

    try {
      for (int i = 0; i < widget.animalInfo.files.length; i++) {
        String _imageName =
            widget.animalInfo.files[i].fileName.split('/')[4].split('_')[1];
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
    } on Exception catch (e) {
      print('edit image==' + e.toString());
    }
    try {
      for (int i = 0; i < widget.animalInfo.videoFiles.length; i++) {
        String _videoName = widget.animalInfo.videoFiles[i].fileName
            .split('/')[4]
            .split('_')[1];
        _editVideosUpload[_videoName] =
            widget.animalInfo?.videoFiles[i]?.fileName ?? '';
        _videosUpload[_videoName] = {
          "fileName": widget.animalInfo?.videoFiles[i]?.fileType?.split('^')[1],
          "fileType": widget.animalInfo?.videoFiles[i]?.fileType?.split('^')[0]
        };
        videoToBeUploaded.add({
          "fileName": widget.animalInfo?.videoFiles[i]?.fileType?.split('^')[1],
          "fileType": widget.animalInfo?.videoFiles[i]?.fileType?.split('^')[0]
        });
      }
    } on Exception catch (e) {
      print('edit video==' + e.toString());
    }
    setState(() {
      animalUpdationData = _animalUpdationData;
      editImagesUpload = _editImagesUpload;
      imagesUpload = _imagesUpload;
      _imageToBeUploaded = imageToBeUploaded;
      videoPath = widget.animalInfo.videoFiles[0].fileName;
      thumbNail = widget.animalInfo.videoFiles[1].fileName;
      _videoToBeUploaded = videoToBeUploaded;
      _controller = TextEditingController(
          text: _currency +
              '${_formatNumber(widget.animalInfo.animalPrice.toString().replaceAll(',', ''))}');
      _videoController = VideoPlayerController.network(videoPath);

      _videoController.setLooping(false);
      _videoController.initialize().then((_) {
        setState(() {
          _isInitialised = true;
        });
      });

      _videoController.pause();
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

      if (ReusableWidgets.convertStringToInt(index) == 5) {
        var pickedFile = await _picker.getVideo(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          maxDuration: Duration(
            minutes: 1,
          ),
        );

        switch (pickedFile) {
          case null:
            return null;
            break;
          default:
            MediaInfo mediaInfo = await VideoCompress.compressVideo(
              pickedFile.path,
              quality: VideoQuality.LowQuality,
            );

            final thumbnailFile =
                await VideoCompress.getFileThumbnail(pickedFile.path,
                    quality: 50, // default(100)
                    position: -1 // default(-1)
                    );

            setState(() {
              videoPath = mediaInfo.path;
              thumbNail = thumbnailFile.path;
              videoUpload['Video'] = {
                "fileName": "Video",
                "fileType": ReusableWidgets.mimeType(mediaInfo.path),
              };
              videoUpload['thumbnail'] = {
                "fileName": "thumbnail",
                "fileType": ReusableWidgets.mimeType(thumbnailFile.path),
              };
            });

            _videoController = VideoPlayerController.file(File(videoPath));

            // _videoController.addListener(() {
            //   setState(() {});
            // });
            _videoController.setLooping(false);
            _videoController.initialize().then((_) {
              setState(() {
                _isInitialised = true;
              });
            });

            _videoController.play();
        }
      } else {
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
              final mimeType = ReusableWidgets.mimeType(file.path);

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
      if (ReusableWidgets.convertStringToInt(index) == 5) {
        var pickedFile = await _picker.getVideo(
            source: ImageSource.gallery,
            preferredCameraDevice: CameraDevice.rear,
            maxDuration: Duration(minutes: 1));

        switch (pickedFile) {
          case null:
            return null;
            break;
          default:
            MediaInfo mediaInfo = await VideoCompress.compressVideo(
              pickedFile.path,
              quality: VideoQuality.LowQuality,
            );

            final thumbnailFile =
                await VideoCompress.getFileThumbnail(pickedFile.path,
                    quality: 50, // default(100)
                    position: -1 // default(-1)
                    );

            setState(() {
              videoPath = mediaInfo.path;
              thumbNail = thumbnailFile.path;

              videoUpload['Video'] = {
                "fileName": "Video",
                "fileType": ReusableWidgets.mimeType(mediaInfo.path),
              };
              videoUpload['thumbnail'] = {
                "fileName": "thumbnail",
                "fileType": ReusableWidgets.mimeType(thumbnailFile.path),
              };
            });

            _videoController = VideoPlayerController.file(File(videoPath));
            _videoController.setLooping(false);
            _videoController.initialize().then((_) {
              setState(() {
                _isInitialised = true;
              });
            });

            _videoController.play();
        }
      } else {
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

              final mimeType = ReusableWidgets.mimeType(file.path);

              setState(() {
                imagesFileUpload['Image$index'] = compressedFile.path;
                editImagesUpload['Image$index'] = '';
                imagesUpload['Image$index'] = {
                  "fileName": "Image$index",
                  "fileType": mimeType
                };
              });
            });
        }
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
              selectedItem: widget.animalInfo.animalType > 4
                  ? intToAnimalOtherTypeMapping[widget.animalInfo.animalType]
                  : intToAnimalTypeMapping[widget.animalInfo.animalType],
              dropdownSearchDecoration: InputDecoration(
                  fillColor: Colors.grey,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  )),
            ),
          ),
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

  animalAge() => Column(
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
                  if (price.isEmpty) {
                    price = '0';
                  } else {
                    String string =
                        '${_formatNumber(price.replaceAll(',', ''))}';
                    _controller.value = TextEditingValue(
                      text: _currency + string,
                      selection: TextSelection.collapsed(offset: string.length),
                    );

                    _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length));
                  }
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
  _videoStructure(width) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: GestureDetector(
          onTap: () => chooseOption('5'),
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
                      child: _progressState != 0 && _progressState != 100.0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 5),
                                Text(
                                  'video_loading_text'.tr,
                                  style: TextStyle(
                                    color: appPrimaryColor,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            )
                          : Visibility(
                              visible:
                                  _videoController == null && !_isInitialised,
                              child: Column(
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
                                      color: appPrimaryColor,
                                      onPressed: () => chooseOption('5'),
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.cancel_rounded,
                                              color: appPrimaryColor,
                                              size: 30,
                                            ),
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
                                                    onPressed:
                                                        () => setState(() {
                                                              if (!_videoController
                                                                      .value
                                                                      .isPlaying &&
                                                                  value.position
                                                                          .compareTo(
                                                                              value.duration) ==
                                                                      0) {
                                                                _videoController
                                                                    .initialize();
                                                              }
                                                              _videoController
                                                                      .value
                                                                      .isPlaying
                                                                  ? _videoController
                                                                      .pause()
                                                                  : _videoController
                                                                      .play();
                                                            })),
                                                Container(
                                                  width: width * 0.5,
                                                  child: VideoProgressIndicator(
                                                    _videoController,
                                                    allowScrubbing: true,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  ReusableWidgets.printDuration(
                                                          value.position)
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: appPrimaryColor,
                                                  ),
                                                )
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
                                        color: appPrimaryColor,
                                        onPressed: () => chooseOption('5'),
                                        child: Text(
                                          'वीडियो चुने',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
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

      if (key.split('_')[1] == "Video" || key.split('_')[1] == 'thumbnail') {
        setState(() {
          _videoToBeUploaded.add({'fileName': key, 'fileType': fileType});
        });
      } else {
        _imageToBeUploaded.removeWhere((element) {
          print('element===>' + element.toString());
          return element['fileName'].contains(key.split('_')[1]);
        });
        setState(() {
          _imageToBeUploaded.add({'fileName': key, 'fileType': fileType});
        });
      }

      return true;
    } catch (e) {
      print('=-=-==>>' + e.toString());
      return false;
    }
  }

  _sampleVideo() => Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: 'upload_video_text'.tr,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text: 'video_supportive_text'.tr,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500])),
                  TextSpan(
                      text: ' *',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _videoController1 = VideoPlayerController.network(
                  'https://firebasestorage.googleapis.com/v0/b/pashusansaar-6e910.appspot.com/o/sample_video%2Fsample_video.mp4?alt=media&token=77ec82d0-5ce7-4a4b-84d9-a0f65915401b',
                );
                _videoController1.setLooping(false);
                _videoController1.initialize();
                _videoController1.pause();

                return Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: true,
                    pageBuilder: (BuildContext context, _, __) => WillPopScope(
                        onWillPop: () async {
                          setState(() {
                            _videoController1.pause();
                          });
                          return true;
                        },
                        child: StatefulBuilder(
                            builder: (context, setState) => Stack(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  children: [
                                    Center(
                                        child: StreamBuilder<Object>(
                                            stream: null,
                                            builder: (context, snapshot) {
                                              return VideoPlayer(
                                                  _videoController1);
                                            })),
                                    _videoController1 == null
                                        ? SizedBox.shrink()
                                        : ValueListenableBuilder(
                                            valueListenable: _videoController1,
                                            builder: (context,
                                                    VideoPlayerValue value,
                                                    child) =>
                                                Row(
                                              children: [
                                                Card(
                                                  color: Colors.transparent,
                                                  child: IconButton(
                                                      icon: Icon(
                                                        _videoController1
                                                                .value.isPlaying
                                                            ? Icons.pause
                                                            : Icons.play_arrow,
                                                      ),
                                                      color: Colors.white,
                                                      onPressed:
                                                          () => setState(() {
                                                                if (!_videoController1
                                                                        .value
                                                                        .isPlaying &&
                                                                    value.position
                                                                            .compareTo(value.duration) ==
                                                                        0) {
                                                                  _videoController1
                                                                      .initialize();
                                                                }
                                                                _videoController1
                                                                        .value
                                                                        .isPlaying
                                                                    ? _videoController1
                                                                        .pause()
                                                                    : _videoController1
                                                                        .play();
                                                              })),
                                                ),
                                                Card(
                                                  color: Colors.transparent,
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    child: VideoProgressIndicator(
                                                        _videoController1,
                                                        colors:
                                                            VideoProgressColors(
                                                                playedColor:
                                                                    Colors
                                                                        .white),
                                                        allowScrubbing: true),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Card(
                                                  color: Colors.transparent,
                                                  child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 11.0,
                                                          horizontal: 5),
                                                      child: Text(
                                                        ReusableWidgets
                                                                .printDuration(
                                                                    value
                                                                        .position)
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15),
                                                      )),
                                                )
                                              ],
                                            ),
                                          ),
                                  ],
                                ))),
                  ),
                );
              },
              child: Text('sample_video'.tr,
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            )
          ],
        ),
      );

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
                else if (animalUpdationData['animalPrice'] == null ||
                    animalUpdationData['animalPrice'] == 0)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_price_error'.tr),
                  );
                // else if ((editImagesUpload['Image1'].isEmpty &&
                //         imagesFileUpload['Image1'].isEmpty) &&
                //     (editImagesUpload['Image2'].isEmpty &&
                //         imagesFileUpload['Image2'].isEmpty) &&
                //     (editImagesUpload['Image3'].isEmpty &&
                //         imagesFileUpload['Image3'].isEmpty) &&
                //     (editImagesUpload['Image4'].isEmpty &&
                //         imagesFileUpload['Image4'].isEmpty))
                //   ReusableWidgets.showDialogBox(
                //     context,
                //     'error'.tr,
                //     Text('animal_image_error'.tr),
                //   );
                else if (videoPath.isEmpty)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_video_error'.tr),
                  );
                else if (_videoController != null &&
                    _videoController.value.duration.inSeconds > 60.0)
                  ReusableWidgets.showDialogBox(
                      context, 'error'.tr, Text('time_duration'.tr));
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
                        ReusableWidgets.loggerFunction(
                          fileName: 'sell_animal_edit_form_refreshToken',
                          error: e.toString(),
                          myNum: widget.userMobileNumber,
                          userId: prefs.getString('userId'),
                        );
                      }
                    }
                  } catch (e) {
                    ReusableWidgets.loggerFunction(
                      fileName: 'sell_animal_edit_form_refreshToken',
                      error: e.toString(),
                      myNum: widget.userMobileNumber,
                      userId: prefs.getString('userId'),
                    );

                    ReusableWidgets.showDialogBox(
                      context,
                      'warning'.tr,
                      Text(
                        'global_error'.tr,
                      ),
                    );
                  }

                  List videoResult = [];
                  if (videoUpload['Video'].length != 0) {
                    videoResult.add(videoUpload['Video']);
                    videoResult.add(videoUpload['thumbnail']);
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

                  List imageUploadingStatus = [];
                  try {
                    imageUploadingStatus =
                        await _uploadImageController.uploadImage(
                      userId: prefs.getString('userId'),
                      files: result,
                      videoFiles: videoResult,
                      token: prefs.getString('accessToken'),
                    );
                  } catch (e) {
                    ReusableWidgets.loggerFunction(
                      fileName: 'sell_animal_edit_form_uploadImage',
                      error: e.toString(),
                      myNum: widget.userMobileNumber,
                      userId: prefs.getString('userId'),
                    );
                    ReusableWidgets.showDialogBox(
                      context,
                      'warning'.tr,
                      Text(
                        'global_error'.tr,
                      ),
                    );
                  }

                  if (imageUploadingStatus.length == 0) {
                    ReusableWidgets.showDialogBox(context, 'error'.tr,
                        Text('issue uploading image or video'));
                  } else {
                    try {
                      if (imageUploadingStatus[0].videoUrls != null) {
                        for (int i = 0;
                            i < imageUploadingStatus[0].videoUrls?.length;
                            i++) {
                          bool uploadStatus = await _upload(
                            path: videoUpload[imageUploadingStatus[0]
                                        .videoUrls[i]
                                        .fields
                                        .key
                                        .split('_')[1]]['fileName'] ==
                                    "Video"
                                ? videoPath
                                : thumbNail,
                            fileName:
                                imageUploadingStatus[0].videoUrls[i].fields.key,
                            url: imageUploadingStatus[0].videoUrls[i].url,
                            key:
                                imageUploadingStatus[0].videoUrls[i].fields.key,
                            bucket: imageUploadingStatus[0]
                                .videoUrls[i]
                                .fields
                                .bucket,
                            xAmzAlgorithm: imageUploadingStatus[0]
                                .videoUrls[i]
                                .fields
                                .xAmzAlgorithm,
                            xAmzCredential: imageUploadingStatus[0]
                                .videoUrls[i]
                                .fields
                                .xAmzCredential,
                            xAmzDate: imageUploadingStatus[0]
                                .videoUrls[i]
                                .fields
                                .xAmzDate,
                            policy: imageUploadingStatus[0]
                                .videoUrls[i]
                                .fields
                                .policy,
                            xAmzSignature: imageUploadingStatus[0]
                                .videoUrls[i]
                                .fields
                                .xAmzSignature,
                            fileType: videoResult[i]['fileType'],
                          );

                          print('][]==' + uploadStatus.toString());
                        }
                      }
                    } catch (e) {
                      setState(() {
                        _videoToBeUploaded = _videoToBeUploaded;
                      });
                    }

                    try {
                      for (int i = 0; i < imageUploadingStatus.length; i++) {
                        if (imageUploadingStatus[i].fields == null ||
                            imageUploadingStatus[i].url == null) {
                          continue;
                        } else {
                          bool uploadStatus1 = await _upload(
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

                          print('][]' + uploadStatus1.toString());
                        }
                      }
                    } catch (e) {
                      setState(() {
                        _imageToBeUploaded = _imageToBeUploaded;
                      });
                    }
                  }

                  print('animalUpdationData=====' +
                      animalUpdationData.toString());

                  bool saveAnimalData = false;
                  if (_imageToBeUploaded.length > 0) {
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
                          recentBayatTime:
                              animalUpdationData['recentBayatTime'],
                          isPregnant: animalUpdationData['isPregnant'],
                          pregnantTime: animalUpdationData['pregnantTime'],
                          animalHasBaby: animalUpdationData['animalHasBaby'],
                          userId: prefs.getString('userId'),
                          animalId: widget.animalInfo.sId,
                          moreInfo: animalUpdationData['moreInfo'],
                          files: _imageToBeUploaded,
                          videoFiles: _videoToBeUploaded,
                          token: prefs.getString("accessToken"),
                        );
                      } catch (e) {
                        pr.hide();

                        ReusableWidgets.loggerFunction(
                            fileName: 'sell_animal_edit_form_updateAnimal1',
                            error: e.toString(),
                            myNum: widget.userMobileNumber,
                            userId: prefs.getString('userId'));
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
                          videoFiles: _videoToBeUploaded,
                          token: prefs.getString("accessToken"),
                        );
                      } catch (e) {
                        pr.hide();

                        ReusableWidgets.loggerFunction(
                          fileName: 'sell_animal_edit_form_updateAnimal2',
                          error: e.toString(),
                          myNum: widget.userMobileNumber,
                          userId: prefs.getString('userId'),
                        );
                        ReusableWidgets.showDialogBox(
                          context,
                          'warning'.tr,
                          Text(
                            'global_error'.tr,
                          ),
                        );
                      }
                    }
                  } else {
                    pr.hide();

                    ReusableWidgets.showDialogBox(
                      context,
                      'warning'.tr,
                      Text('upload_image_error'.tr),
                    );
                  }

                  print('][]==' + _imageToBeUploaded.toString());

                  if (saveAnimalData) {
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
                        context, 'error'.tr, Text('animalSaveError'.tr));
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
                  widget.animalInfo.animalType == 2) ...[
                animalIsPregnant(),
              ],
              if (widget.animalInfo.animalType == 1 ||
                  widget.animalInfo.animalType == 2) ...[
                animalMilkPerDay(),
              ],
              if (widget.animalInfo.animalType == 1 ||
                  widget.animalInfo.animalType == 2) ...[
                animalMilkPerDayCapacity()
              ],
              animalPrice(),
              _sampleVideo(),
              _videoStructure(width),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  'upload_image_text'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
