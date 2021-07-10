import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:pashusansaar/utils/colors.dart';
import 'package:pashusansaar/utils/reusable_widgets.dart';
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../home_screen.dart';
import '../utils/constants.dart' as constant;

class AnimalInfoForm extends StatefulWidget {
  final String userMobileNumber, userName;
  AnimalInfoForm({
    Key key,
    @required this.userMobileNumber,
    @required this.userName,
  }) : super(key: key);

  @override
  _AnimalInfoFormState createState() => _AnimalInfoFormState();
}

class _AnimalInfoFormState extends State<AnimalInfoForm> {
  Map<String, dynamic> animalInfo = {};
  TextEditingController _budgetController;
  String _formatNumber(String s) =>
      NumberFormat.decimalPattern('en_IN').format(int.parse(s));
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: 'en_IN').currencySymbol;
  ProgressDialog pr;

  @override
  void initState() {
    _budgetController = TextEditingController();

    super.initState();
  }

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

  Column animalMilkPerDay() => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'दूध',
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

  Column animalBudget() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'आपका बजट क्या हैं (₹)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.deny(RegExp(r'^0+'))
              ],
              controller: _budgetController,
              keyboardType: TextInputType.number,
              onChanged: (String price) {
                String string = '${_formatNumber(price.replaceAll(',', ''))}';

                _budgetController.value = TextEditingValue(
                  text: _currency + string,
                  selection: TextSelection.collapsed(offset: string.length),
                );

                _budgetController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _budgetController.text.length));

                setState(() {
                  animalInfo['animalBudget'] = price;
                });
              },
              decoration: InputDecoration(
                hintText: 'price_hint_text'.tr,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
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
  Column zipCodeField() => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Text(
                  'ज़िपकोड'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (String zipcode) {
                setState(() {
                  animalInfo['zipCode'] = zipcode;
                });
              },
              decoration: InputDecoration(
                counterText: '',
                hintText: 'ज़िपकोड दर्ज करें'.tr,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
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
              child: Text(
                'save_button'.tr,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                String countryCode = '';
                try {
                  var addresses = await Geocoder.local
                      .findAddressesFromQuery(animalInfo['zipCode']);
                  var first = addresses.first;
                  countryCode = first.countryCode;
                } catch (e) {
                  countryCode = 'XYZ';
                }

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
                else if ([0, 1].contains(
                      constant.animalType.indexOf(animalInfo['animalType']),
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
                else if (animalInfo['animalBudget'] == null ||
                    animalInfo['animalBudget'].isEmpty)
                  ReusableWidgets.showDialogBox(
                    context,
                    'error'.tr,
                    Text('animal_price_error'.tr),
                  );
                else if (animalInfo['zipCode'] == null) {
                  ReusableWidgets.showDialogBox(
                      context, 'error'.tr, Text("error_empty_zipcode".tr));
                } else if (int.parse(animalInfo['zipCode']) < 6) {
                  ReusableWidgets.showDialogBox(
                      context, 'error'.tr, Text("error_length_zipcode".tr));
                } else if (countryCode != "IN" || countryCode == 'XYZ') {
                  ReusableWidgets.showDialogBox(
                      context, 'error'.tr, Text("invalid_zipcode_error".tr));
                } else {
                  print(animalInfo);
                  pr = new ProgressDialog(context,
                      type: ProgressDialogType.Normal, isDismissible: false);
                  pr.style(message: 'progress_dialog_message'.tr);
                  pr.show();

                  try {
                    await FirebaseFirestore.instance
                        .collection("buyerRequirementForm")
                        .doc(ReusableWidgets.randomIDGenerator() +
                            ReusableWidgets.randomCodeGenerator())
                        .set(
                      {
                        "animalType": animalInfo['animalType'],
                        "animalBreed":
                            ReusableWidgets.removeEnglisgDataFromName(
                                animalInfo['animalBreed']),
                        "animalMilk": animalInfo['animalMilk'],
                        "animalBudget": animalInfo['animalBudget'],
                        'mobile': widget.userMobileNumber,
                        'userName': widget.userName,
                        'userId': FirebaseAuth.instance.currentUser.uid,
                        "zipCode": animalInfo['zipCode'],
                        "dateOfSaving": DateFormat()
                            .add_yMMMd()
                            .add_jm()
                            .format(DateTime.now())
                      },
                    ).then((value) {
                      pr.hide();
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text('info'.tr),
                                content: Text('animal_info_saved'.tr),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text(
                                        'Ok'.tr,
                                        style: TextStyle(color: primaryColor),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Get.offAll(() => HomeScreen(
                                              selectedIndex: 0,
                                            ));
                                      }),
                                ]);
                          });
                    });
                  } catch (e) {
                    pr.hide();
                    FirebaseFirestore.instance
                        .collection('logger')
                        .doc(widget.userMobileNumber)
                        .collection('sell-profile')
                        .doc()
                        .set({
                      'issue': e.toString(),
                      'userId': FirebaseAuth.instance.currentUser == null
                          ? ''
                          : FirebaseAuth.instance.currentUser.uid,
                      'mobile': widget.userMobileNumber,
                      'date': DateFormat()
                          .add_yMMMd()
                          .add_jm()
                          .format(DateTime.now()),
                    });
                  }
                }
              },
            )),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReusableWidgets.getAppBar(context, "app_name".tr, true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'animal_info_header'.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 3,
              ),
              animalType(),
              animalBreed(),
              animalMilkPerDay(),
              animalBudget(),
              zipCodeField(),
              saveButton()
            ],
          ),
        ),
      ),
    );
  }
}
