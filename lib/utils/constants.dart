import 'package:get/get.dart';

List<String> animalType = [
  'cow'.tr,
  'buffalo_female'.tr,
  'buffalo_male'.tr,
  'ox'.tr,
  'other_animal'.tr,
];

List<List<String>> animalType1 = [
  ['0', 'cow'.tr],
  ['1', 'buffalo_male'.tr],
  ['2', 'ox'.tr],
  ['3', 'buffalo_female'.tr],
  ['4', 'other_animal'.tr]
];

List<String> animalTypeOther = [
  'dog_male'.tr,
  'camel_female'.tr,
  'camel_male'.tr,
  'horse_female'.tr,
  'horse_male'.tr,
  'elephant_female'.tr,
  'elephant_male'.tr,
];

List<String> animalBreedBuffaloFemaleMale = [
  'not_known'.tr,
  'murrah'.tr,
  'murrah_cross'.tr,
  'haryanvi'.tr,
  'desi'.tr,
  'desi_cross'.tr,
  'kali'.tr,
  'kundi'.tr,
  'kundi_cross'.tr,
  'jaffrabadi'.tr,
  'banni'.tr,
  'kumbhi'.tr,
  'kumbhi_cross'.tr,
  'kunni'.tr,
  'nili_ravi'.tr,
  'bhadawari'.tr,
  'gujarati'.tr,
  'godavari'.tr,
  'surti'.tr,
  'mehsana'.tr,
  'pandharpuri'.tr,
  'nagpuri'.tr,
];
List<String> animalBreedBuffaloMale = [
  'not_known'.tr,
  'murrah'.tr,
  'murrah_cross'.tr,
  'haryanvi'.tr,
  'desi'.tr,
  'desi_cross'.tr,
  'kali'.tr,
  'kundi'.tr,
  'kundi_cross'.tr,
  'jaffrabadi'.tr,
  'banni'.tr,
  'kumbhi'.tr,
  'kumbhi_cross'.tr,
  'kunni'.tr,
  'nili_ravi'.tr,
  'bhadawari'.tr,
  'gujarati'.tr,
  'godavari'.tr,
  'surti'.tr,
  'mehsana'.tr,
  'pandharpuri'.tr,
  'nagpuri'.tr,
];

List<String> animalBreedCowOx = [
  'not_known'.tr,
  'gir'.tr,
  'gir_cross'.tr,
  'sahiwal'.tr,
  'sahiwal_cross'.tr,
  'desi_cow'.tr,
  'desi_cross_cow'.tr,
  'holstein_friesian'.tr,
  'holstein_friesian_cross'.tr,
  'jersey'.tr,
  'jersey_cross'.tr,
  'american'.tr,
  'american_cross'.tr,
  'dogali'.tr,
  'rathi'.tr,
  'rathi_cross'.tr,
  'tharparkar'.tr,
  'haryanvi_cow'.tr,
  'marwari'.tr,
  'kankrej'.tr,
  'kapila'.tr,
  'ayrshire'.tr,
  'harpashusansaar'.tr,
  'nagori'.tr,
  'gujarati_cow'.tr,
  'red_sindhi'.tr,
  'red_sindhi_cross'.tr,
  'deoni'.tr,
  'red_dane'.tr,
  'red_dane_cross'.tr,
  'brown_swiss'.tr,
  'tharparkar_cross'.tr,
  'sanchori'.tr,
  'malvi'.tr,
];

List<String> pregnantMonth = [
  'zero'.tr,
  'first'.tr,
  'second'.tr,
  'third'.tr,
  'fourth'.tr,
  'fifth'.tr,
  'sixth'.tr,
  'seventh'.tr,
];

List<String> animalAge = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12',
];

List<String> isPregnant = [
  '1_months_pregnant'.tr,
  '2_months_pregnant'.tr,
  '3_months_pregnant'.tr,
  '4_months_pregnant'.tr,
  '5_months_pregnant'.tr,
  '6_months_pregnant'.tr,
  '7_months_pregnant'.tr,
  '8_months_pregnant'.tr,
  '9_months_pregnant'.tr,
  '10_months_pregnant'.tr,
];

List<String> ifPregnant = [
  'this_week_only'.tr,
  '1_week_before'.tr,
  '2_week_before'.tr,
  '3_week_before'.tr,
  '1_month_before'.tr,
  '2_month_before'.tr,
  '3_month_before'.tr,
  '4_month_before'.tr,
  '5_month_before'.tr,
  '6_month_before'.tr,
  '1_year_ago'.tr,
  '2_year_ago'.tr,
  '5_year_ago'.tr,
  'more_than_5_year_ago'.tr,
];

List<String> yesNo = ['yes'.tr, 'no'.tr];
List<String> isBaby = ['bachhra'.tr, 'bacchri'.tr, 'nothing'.tr];

List<String> filterMilkValue = [
  '0-10 ' + 'litre_milk'.tr,
  '11-15 ' + 'litre_milk'.tr,
  '16-20 ' + 'litre_milk'.tr,
  '> 20 ' + 'litre_milk'.tr
];
List<String> radius = [
  '25 ' + 'km'.tr,
  '50 ' + 'km'.tr,
  '75 ' + 'km'.tr,
  '100 ' + 'km'.tr
];

Map<String, String> hindiToEnglishDistrictMapping = {
  "हमीरपुर": "Hamirpur",
  "सीतापुर": "Sitapur",
  "सहारनपुर": "Saharanpur",
  "शामली": "Shamli",
  "शाजापुर": "Shajapur",
  "वाराणसी": "Varanasi",
  "मैनपुरी": "Mainpuri",
  "मिर्ज़ापुर": "Mirzapur",
  "मंदसौर": "Mandsaur",
  "भोपाल": "Bhopal",
  "बहराइच": "Bahraich",
  "बदायूं": "Badaun",
  "प्रतापगढ़": "Pratapgarh",
  "पानीपत": "Panipat",
  "नीमुच": "Neemuch",
  "नागौर": "Nagaur",
  "देवास": "Dewas",
  "टीकमगढ़": "Tikamgarh",
  "जौनपुर": "Jaunpur",
  "जोधपुर": "Jodhpur",
  "चित्तोडगढ": "Chittaurgarh",
  "गोरखपुर": "Gorakhpur",
  "ग़ाज़ियाबाद": "Ghaziabad",
  "कन्नौज": "Kannauj",
  "कटनी": "Katni",
  "उन्नाव": "Unnao",
  "उज्जैन": "Ujjain",
  "अमरोहा": "Amroha"
};

Map<String, int> animalTypeMapping = {
  "cow".tr: 1,
  'buffalo_female'.tr: 2,
  'ox'.tr: 3,
  'buffalo_male'.tr: 4,
};

Map<String, int> animalOtherTypeMapping = {
  'dog_male'.tr: 5,
  'camel_female'.tr: 6,
  'camel_male'.tr: 7,
  'horse_female'.tr: 8,
  'horse_male'.tr: 9,
  'elephant_female'.tr: 10,
  'elephant_male'.tr: 11,
  // 'notKnown'.tr: 12,
  // 'notKnown'.tr: 13,
};

Map<int, String> intToAnimalTypeMapping = {
  1: 'cow'.tr,
  2: 'buffalo_female'.tr,
  3: 'ox'.tr,
  4: 'buffalo_male'.tr,
};
Map<int, String> intToAnimalOtherTypeMapping = {
  5: 'dog_male'.tr,
  6: 'camel_female'.tr,
  7: 'camel_male'.tr,
  8: 'horse_female'.tr,
  9: 'horse_male'.tr,
  10: 'elephant_female'.tr,
  11: 'elephant_male'.tr,
  // 12: 'notKnown'.tr,
  // 13: 'notKnown'.tr,
};

Map<String, int> animalBayaatMapping = {
  'zero'.tr: 0,
  'first'.tr: 1,
  'second'.tr: 2,
  'third'.tr: 3,
  'fourth'.tr: 4,
  'fifth'.tr: 5,
  'sixth'.tr: 6,
  'seventh'.tr: 7,
};

Map<int, String> intToAnimalBayaatMapping = {
  0: 'zero'.tr,
  1: 'first'.tr,
  2: 'second'.tr,
  3: 'third'.tr,
  4: 'fourth'.tr,
  5: 'fifth'.tr,
  6: 'sixth'.tr,
  7: 'seventh'.tr,
};

Map<int, String> intToRecentBayaatTime = {
  0: 'this_week_only'.tr,
  1: '1_week_before'.tr,
  2: '2_week_before'.tr,
  3: '3_week_before'.tr,
  10: '1_month_before'.tr,
  20: '2_month_before'.tr,
  30: '3_month_before'.tr,
  40: '4_month_before'.tr,
  50: '5_month_before'.tr,
  60: '6_month_before'.tr,
  100: '1_year_ago'.tr,
  200: '2_year_ago'.tr,
  500: '5_year_ago'.tr,
  1000: 'more_than_5_year_ago'.tr,
};
Map<String, int> stringToRecentBayaatTime = {
  'this_week_only'.tr: 0,
  '1_week_before'.tr: 1,
  '2_week_before'.tr: 2,
  '3_week_before'.tr: 3,
  '1_month_before'.tr: 10,
  '2_month_before'.tr: 20,
  '3_month_before'.tr: 30,
  '4_month_before'.tr: 40,
  '5_month_before'.tr: 50,
  '6_month_before'.tr: 60,
  '1_year_ago'.tr: 100,
  '2_year_ago'.tr: 200,
  '5_year_ago'.tr: 500,
  'more_than_5_year_ago'.tr: 1000,
};

Map<int, String> intToPregnantTime = {
  1: '1_months_pregnant'.tr,
  2: '2_months_pregnant'.tr,
  3: '3_months_pregnant'.tr,
  4: '4_months_pregnant'.tr,
  5: '5_months_pregnant'.tr,
  6: '6_months_pregnant'.tr,
  7: '7_months_pregnant'.tr,
  8: '8_months_pregnant'.tr,
  9: '9_months_pregnant'.tr,
  10: '10_months_pregnant'.tr,
};
Map<String, int> stringToPregnantTime = {
  '1_months_pregnant'.tr: 1,
  '2_months_pregnant'.tr: 2,
  '3_months_pregnant'.tr: 3,
  '4_months_pregnant'.tr: 4,
  '5_months_pregnant'.tr: 5,
  '6_months_pregnant'.tr: 6,
  '7_months_pregnant'.tr: 7,
  '8_months_pregnant'.tr: 8,
  '9_months_pregnant'.tr: 9,
  '10_months_pregnant'.tr: 10,
};

Map<int, String> intToAnimalHasBaby = {
  0: 'nothing'.tr,
  1: 'bachhra'.tr,
  2: 'bacchri'.tr,
};
Map<String, int> stringToAnimalHasBaby = {
  'nothing'.tr: 0,
  'bachhra'.tr: 1,
  'bacchri'.tr: 2,
};

Map<String, int> stringToYesNo = {
  'yes'.tr: 0,
  'no'.tr: 1,
};
Map<int, String> intToYesNo = {
  0: 'yes'.tr,
  1: 'no'.tr,
};


const String videoType = "video/mp4";