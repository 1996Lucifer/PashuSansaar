import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:get/get.dart';
import 'package:pashusansaar/utils/urls.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen.dart';

class RemoveAnimal extends StatefulWidget {
  final String listId, price;
  final List interestedBuyersNew;
  RemoveAnimal(
      {Key key,
        @required this.listId,
        @required this.price,
        @required this.interestedBuyersNew})
      : super(key: key);

  @override
  _RemoveAnimalState createState() => _RemoveAnimalState();
}

class _RemoveAnimalState extends State<RemoveAnimal> {
  static const _locale = 'en_IN';
  bool _isError = false, _isErrorEmpty = false;
  String _price = '';
  ProgressDialog pr;

  TextEditingController _controller = TextEditingController();
  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

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

  _showPriceDialog(data) => showDialog(
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
              Text(data == null
                  ? 'tell_price'.tr
                  : 'tell_price_with_name'.trParams({
                'name': '${data.name}',
              })),
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
              if ((int.parse(_price) < (int.parse(widget.price) ~/ 2)) ||
                  (int.parse(_price) > int.parse(widget.price))) {
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
                if (data == null) {
                  userMap = {
                    "animalId": widget.listId,
                    "userId": prefs.getString('userId'),
                    "soldFromApp": 0,
                    "sellingPrice": _price,
                  };
                } else {
                  userMap = {
                    "animalId": widget.listId,
                    "userId": prefs.getString('userId'),
                    "soldFromApp": 1,
                    "sellingPrice": _price,
                    "buyerName": data.name,
                    "buyerPhoneNumber": data.mobile,
                    "buyerAddress": data.userAddress,
                    "buyerUserId": data.sId,
                  };
                }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, true),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(10),
                onPressed: () => _showPriceDialog(null),
                child: Text(
                  'sold_outside_pashusansaar'.tr,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text('title_sold_inside_pashusansaar'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(
              height: 10,
            ),
            Container(
              height: MediaQuery.of(context).size.height - 300,
              child: widget.interestedBuyersNew.length == null ||
                  widget.interestedBuyersNew.isEmpty
                  ? Center(
                child: Text(
                  'noOneContactedYet'.tr,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
                  : ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: widget.interestedBuyersNew.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.userAlt,
                                    color: Colors.grey[500],
                                    size: 13,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.interestedBuyersNew[index]
                                        .userId.name,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.phone,
                                    color: Colors.grey[500],
                                    size: 13,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.interestedBuyersNew[index]
                                        .userId.mobile
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.grey[500],
                                    size: 13,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.interestedBuyersNew[index]
                                          .userId.userAddress,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onPressed: () => _showPriceDialog(
                                widget.interestedBuyersNew[index].userId),
                            child: Text(
                              'sold_to'.tr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
