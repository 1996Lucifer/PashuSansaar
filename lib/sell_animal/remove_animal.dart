import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../home_screen.dart';

class RemoveAnimal extends StatefulWidget {
  final String listId, price;
  RemoveAnimal({Key key, @required this.listId, @required this.price})
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
                  style: TextStyle(color: primaryColor),
                )
              : _isError
                  ? Text(
                      'removal_price_error'.tr,
                      style: TextStyle(color: primaryColor),
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
                  Text(data['userName'].isEmpty
                      ? 'tell_price'.tr
                      : 'tell_price_with_name'.trParams({
                          'name': '${data['userName']}',
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
                onPressed: () {
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
                    if (data['userName'].isEmpty) {
                      userMap = {'soldFromApp': true, 'price': _price};
                    } else {
                      userMap = {
                        'soldFromApp': true,
                        'id': data['userIdCurrent'],
                        'name': data['userName'],
                        'price': _price
                      };
                    }

                    FirebaseFirestore.instance
                        .collection("animalSellingInfo")
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .collection('sellingAnimalList')
                        .doc(widget.listId)
                        .update(
                            {'animalRemove': userMap, 'isValidUser': 'Removed'})
                        .then((value) => FirebaseFirestore.instance
                                .collection('buyingAnimalList1')
                                .doc(widget.listId +
                                    FirebaseAuth.instance.currentUser.uid)
                                .update({
                              'animalRemove': userMap,
                              'isValidUser': 'Removed'
                            }).then((value) {
                              pr.hide();
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
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                Get.off(() => HomeScreen(
                                                      selectedIndex: 0,
                                                    ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, true),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RaisedButton(
              onPressed: () => _showPriceDialog(''),
              child: Text(
                'sold_outside_pashusansaar'.tr,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
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
            Expanded(
              child: PaginateFirestore(
                  physics: NeverScrollableScrollPhysics(),
                  itemsPerPage: 10,
                  initialLoader: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: primaryColor,
                    ),
                  ),
                  bottomLoader: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: primaryColor,
                    ),
                  ),
                  emptyDisplay: Center(
                    child: Text(
                      'किसी ग्राहक ने अभी तक संपर्क नहीं किया है',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  itemBuilderType:
                      PaginateBuilderType.listView, // listview and gridview
                  itemBuilder: (index, context, documentSnapshot) =>
                      documentSnapshot.data() == null
                          ? Center(
                              child: Text(
                              'किसी ग्राहक ने अभी तक संपर्क नहीं किया है',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ))
                          : Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
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
                                                  documentSnapshot
                                                      .data()['userName'],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons.clock,
                                                  color: Colors.grey[500],
                                                  size: 13,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    ReusableWidgets
                                                        .epochToDateTime(
                                                            documentSnapshot
                                                                    .data()[
                                                                'dateOfSaving']),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400)),
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
                                                      documentSnapshot.data()[
                                                          'userAddress'],
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                    Expanded(
                                      flex: 2,
                                      child: RaisedButton(
                                        onPressed: () => _showPriceDialog(
                                          documentSnapshot.data(),
                                        ),
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
                              ),
                            ),
                  // orderBy is compulsary to enable pagination
                  query: FirebaseFirestore.instance
                      .collection('callingInfo')
                      .doc(widget.listId)
                      .collection('interestedBuyers')
                      .orderBy('dateOfSaving'),
                  isLive: false // to fetch real-time data
                  ),
            )
          ],
        ),
      ),
    );
  }
}
