class BuyAnimalModel {
  bool success;
  List<Result> result;
  int page;

  BuyAnimalModel({this.success, this.result, this.page});

  BuyAnimalModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result.add(new Result.fromJson(v));
      });
    }
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.result != null) {
      data['result'] = this.result.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String sId;
  int animalType;
  String animalBreed;
  int animalAge;
  int animalBayat;
  int animalMilk;
  int animalMilkCapacity;
  int animalPrice;
  bool isRecentBayat;
  int recentBayatTime;
  int animalHasBaby;
  bool isPregnant;
  int pregnantTime;
  String moreInfo;
  List<Files> files;
  String userId;
  double longitude;
  double latitude;
  String userName;
  String createdAt;
  int iV;
  String userAddress;
  int mobile;

  Result({
    this.sId,
    this.animalType,
    this.animalBreed,
    this.animalAge,
    this.animalBayat,
    this.animalMilk,
    this.animalMilkCapacity,
    this.animalPrice,
    this.isRecentBayat,
    this.recentBayatTime,
    this.animalHasBaby,
    this.isPregnant,
    this.pregnantTime,
    this.moreInfo,
    this.files,
    this.userId,
    this.longitude,
    this.latitude,
    this.userName,
    this.createdAt,
    this.iV,
    this.userAddress,
    this.mobile,
  });

  Result.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    animalType = json['animalType'];
    animalBreed = json['animalBreed'];
    animalAge = json['animalAge'];
    animalBayat = json['animalBayat'];
    animalMilk = json['animalMilk'];
    animalMilkCapacity = json['animalMilkCapacity'];
    animalPrice = json['animalPrice'];
    isRecentBayat = json['isRecentBayat'];
    recentBayatTime = json['recentBayatTime'];
    animalHasBaby = json['animalHasBaby'];
    isPregnant = json['isPregnant'];
    pregnantTime = json['pregnantTime'];
    moreInfo = json['moreInfo'];
    if (json['files'] != null) {
      files = <Files>[];
      json['files'].forEach((v) {
        files.add(new Files.fromJson(v));
      });
    }
    userId = json['userId'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    userName = json['userName'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    userAddress = json['userAddress'];
    mobile = json['mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['animalType'] = this.animalType;
    data['animalBreed'] = this.animalBreed;
    data['animalAge'] = this.animalAge;
    data['animalBayat'] = this.animalBayat;
    data['animalMilk'] = this.animalMilk;
    data['animalMilkCapacity'] = this.animalMilkCapacity;
    data['animalPrice'] = this.animalPrice;
    data['isRecentBayat'] = this.isRecentBayat;
    data['recentBayatTime'] = this.recentBayatTime;
    data['animalHasBaby'] = this.animalHasBaby;
    data['isPregnant'] = this.isPregnant;
    data['pregnantTime'] = this.pregnantTime;
    data['moreInfo'] = this.moreInfo;
    if (this.files != null) {
      data['files'] = this.files.map((v) => v.toJson()).toList();
    }
    data['userId'] = this.userId;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['userName'] = this.userName;
    data['createdAt'] = this.createdAt;
    data['__v'] = this.iV;
    data['userAddress'] = this.userAddress;
    data['mobile'] = this.mobile;
    return data;
  }
}

class Files {
  String fileName;
  String fileType;
  String fileUrl;

  Files({this.fileName, this.fileType, this.fileUrl});

  Files.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    fileType = json['fileType'];
    fileUrl = json['fileUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['fileType'] = this.fileType;
    data['fileUrl'] = this.fileUrl;
    return data;
  }
}
