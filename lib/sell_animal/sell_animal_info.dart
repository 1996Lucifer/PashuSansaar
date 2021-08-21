import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:pashusansaar/intersted_buyers/interestedBuyerController.dart';
import 'package:pashusansaar/my_animals/myAnimalController.dart';
import 'package:pashusansaar/my_animals/myAnimalModel.dart';
import 'package:pashusansaar/refresh_token/refresh_token_controller.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/constants.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pashusansaar/utils/urls.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen.dart';
import '../interested_buyer.dart';
import 'remove_animal.dart';
import 'sell_animal_edit_form.dart';
import 'sell_animal_form.dart';

class SellingAnimalInfo extends StatefulWidget {
  final List<MyAnimals> animalInfo;
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _list.files.length != 0
                            ? _list.files[_list.files.length - 1].fileName
                            : _list.videoFiles[1].fileName,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: Image.asset(
                            'assets/images/loader.gif',
                            height: 40,
                            width: 40,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, size: 30),
                      ),
                      _list.videoFiles.isNotEmpty
                          ? Icon(
                              Icons.play_circle_outline_sharp,
                              size: 50,
                              color: appPrimaryColor,
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0, left: 12, top: 15),
                child: Text(
                  ReusableWidgets.descriptionText(_list),
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
            text: ReusableWidgets.utcToDateTime(_list.createdAt) + ' ',
            children: <InlineSpan>[
              TextSpan(
                text: ' (' +
                    ReusableWidgets.dateDifference(_list.createdAt) +
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
                            : (_list.animalType <= 4
                                ? intToAnimalTypeMapping[_list.animalType]
                                : intToAnimalOtherTypeMapping[
                                    _list.animalType])) +
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
  final InterestedBuyerController interestedBuyerController =
      Get.put(InterestedBuyerController());

  List interestedBuyers = [];
  getInitialInfo(_list) async {
    prefs = await SharedPreferences.getInstance();
    bool status;

    try {
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
    } catch (e) {
      ReusableWidgets.loggerFunction(
          fileName: 'sell_animal_info_refreshToken',
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

    try {
      List data = await interestedBuyerController.interstedBuyers(
        animalId: _list.sId,
        userId: prefs.getString('userId'),
        token: prefs.getString('accessToken'),
        page: 1,
      );

      setState(() {
        interestedBuyers = data;
      });
    } catch (e) {
      ReusableWidgets.loggerFunction(
          fileName: 'sell_animal_info_gettingInterestedBuyers',
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
  }

  _openAddEntryDialog(_list) async {
    await getInitialInfo(_list);
    interestedBuyers.length == null || interestedBuyers.isEmpty
        ? _showPriceDialog(_list)
        : Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (BuildContext context) {
              return RemoveAnimal(
                listId: _list.sId,
                price: _list.animalPrice.toString(),
                interestedBuyersNew: interestedBuyers,
              );
            },
            fullscreenDialog: true));
  }

  _priceTextBox() => Column(
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
        ],
      );

  _showPriceDialog(_list) => showDialog(
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
                  Text(
                    'tell_price'.tr,
                  ),
                  SizedBox(height: 5),
                  _priceTextBox()
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
                onPressed: () async {
                  if (_price.isEmpty) {
                    setState(() {
                      _isError = false;
                      _isErrorEmpty = true;
                    });
                  }
                  if ((int.parse(_price) <
                          (int.parse(_list.animalPrice.toString()) ~/ 2)) ||
                      (int.parse(_price) >
                          int.parse(_list.animalPrice.toString()))) {
                    setState(() {
                      _isErrorEmpty = false;
                      _isError = true;
                    });
                  } else {
                    pr = new ProgressDialog(context,
                        type: ProgressDialogType.Normal, isDismissible: false);
                    pr.style(message: 'progress_dialog_message'.tr);
                    pr.show();

                    Map<String, dynamic> userMap = Map();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    userMap = {
                      "animalId": _list.sId,
                      "userId": prefs.getString('userId'),
                      "soldFromApp": 0,
                      "sellingPrice": _price,
                    };

                    print('my map is this $userMap');

                    try {
                      var response = await Dio().post(
                        GlobalUrl.baseUrl + GlobalUrl.animalSold,
                        data: json.encode(userMap),
                        options: Options(
                          headers: {
                            "Authorization": prefs.getString('accessToken'),
                          },
                        ),
                      );

                      if (response.data != null) {
                        print(
                            'response statuscode  the animal sold is ${response.statusCode}');
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          pr.hide();
                          print(
                              ' 3 response data of the animal sold is ${response.data}');

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
                                      style: TextStyle(color: appPrimaryColor),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Get.offAll(
                                          () => HomeScreen(selectedIndex: 0));
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        }
                      }
                    } catch (e) {
                      print("Getting error in removing animal _______$e");
                      pr.hide();
                      Navigator.of(context).pop();
                    }
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
                    'addAnimal'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                    cacheExtent: 999,
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
                                                    animalInfo: widget
                                                        .animalInfo[index],
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
                                                        animalInfo:
                                                            widget.animalInfo,
                                                      ))),
                                          child: Row(
                                            children: [
                                              Text(
                                                'interestedBuyer'.tr,
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
                                                  listId: widget
                                                          .animalInfo[index]
                                                          .sId ??
                                                      '',
                                                  index: index,
                                                  animalInfo: widget.animalInfo,
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      height: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('seeInterestedBuyer'.tr,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                            )
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
            ),
    );
  }
}
