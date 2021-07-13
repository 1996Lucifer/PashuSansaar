class MyAnimalModel {
  bool success;
  List<MyAnimals> myAnimals;
  int page;

  MyAnimalModel({this.success, this.myAnimals, this.page});

  MyAnimalModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['myAnimals'] != null) {
      myAnimals = new List<MyAnimals>();
      json['myAnimals'].forEach((v) {
        myAnimals.add(new MyAnimals.fromJson(v));
      });
    }
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.myAnimals != null) {
      data['myAnimals'] = this.myAnimals.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    return data;
  }
}

class MyAnimals {
  Location location;
  String sId;
  int animalType;
  String animalBreed;
  int animalAge;
  int animalPrice;
  List<Files> files;
  String userId;
  String moreInfo;
  double longitude;
  double latitude;
  String district;
  int zipCode;
  String userAddress;
  String userName;
  String createdAt;
  String updatedAt;
  int iV;
  int mobile;
  String animalStatus;
  int pregnantTime;
  int recentBayatTime;
  int animalBayat;
  int animalMilk;
  int animalMilkCapacity;
  bool isRecentBayat;
  bool isPregnant;
  String verificationStatus;

  MyAnimals(
      {this.location,
        this.sId,
        this.animalType,
        this.animalBreed,
        this.animalAge,
        this.animalPrice,
        this.files,
        this.userId,
        this.moreInfo,
        this.longitude,
        this.latitude,
        this.district,
        this.zipCode,
        this.userAddress,
        this.userName,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.mobile,
        this.animalStatus,
        this.pregnantTime,
        this.recentBayatTime,
        this.animalBayat,
        this.animalMilk,
        this.animalMilkCapacity,
        this.isRecentBayat,
        this.isPregnant,
        this.verificationStatus});

  MyAnimals.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    animalType = json['animalType'];
    animalBreed = json['animalBreed'];
    animalAge = json['animalAge'];
    animalPrice = json['animalPrice'];
    if (json['files'] != null) {
      files = new List<Files>();
      json['files'].forEach((v) {
        files.add(new Files.fromJson(v));
      });
    }
    userId = json['userId'];
    moreInfo = json['moreInfo'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    district = json['district'];
    zipCode = json['zipCode'];
    userAddress = json['userAddress'];
    userName = json['userName'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    mobile = json['mobile'];
    animalStatus = json['animalStatus'];
    pregnantTime = json['pregnantTime'];
    recentBayatTime = json['recentBayatTime'];
    animalBayat = json['animalBayat'];
    animalMilk = json['animalMilk'];
    animalMilkCapacity = json['animalMilkCapacity'];
    isRecentBayat = json['isRecentBayat'];
    isPregnant = json['isPregnant'];
    verificationStatus = json['verificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location.toJson();
    }
    data['_id'] = this.sId;
    data['animalType'] = this.animalType;
    data['animalBreed'] = this.animalBreed;
    data['animalAge'] = this.animalAge;
    data['animalPrice'] = this.animalPrice;
    if (this.files != null) {
      data['files'] = this.files.map((v) => v.toJson()).toList();
    }
    data['userId'] = this.userId;
    data['moreInfo'] = this.moreInfo;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['district'] = this.district;
    data['zipCode'] = this.zipCode;
    data['userAddress'] = this.userAddress;
    data['userName'] = this.userName;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['mobile'] = this.mobile;
    data['animalStatus'] = this.animalStatus;
    data['pregnantTime'] = this.pregnantTime;
    data['recentBayatTime'] = this.recentBayatTime;
    data['animalBayat'] = this.animalBayat;
    data['animalMilk'] = this.animalMilk;
    data['animalMilkCapacity'] = this.animalMilkCapacity;
    data['isRecentBayat'] = this.isRecentBayat;
    data['isPregnant'] = this.isPregnant;
    data['verificationStatus'] = this.verificationStatus;
    return data;
  }
}

class Location {
  List<double> coordinates;
  String type;

  Location({this.coordinates, this.type});

  Location.fromJson(Map<String, dynamic> json) {
    coordinates = json['coordinates'].cast<double>();
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['coordinates'] = this.coordinates;
    data['type'] = this.type;
    return data;
  }
}

class Files {
  String fileName;
  String fileType;

  Files({this.fileName, this.fileType});

  Files.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    fileType = json['fileType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['fileType'] = this.fileType;
    return data;
  }
}