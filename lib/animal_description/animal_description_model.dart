class AnimalDescriptionModel {
  bool success;
  Animal animal;

  AnimalDescriptionModel({this.success, this.animal});

  AnimalDescriptionModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    animal =
    json['animal'] != null ? new Animal.fromJson(json['animal']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.animal != null) {
      data['animal'] = this.animal.toJson();
    }
    return data;
  }
}

class Animal {
  Location location;
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
  bool isPregnant;
  int pregnantTime;
  int animalHasBaby;
  String moreInfo;
  List<Files> files;
  String userId;
  int animalStatus;
  String verificationStatus;
  double longitude;
  double latitude;
  String userName;
  int zipCode;
  int mobile;
  String createdAt;
  String updatedAt;
  int iV;

  Animal(
      {this.location,
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
        this.isPregnant,
        this.pregnantTime,
        this.animalHasBaby,
        this.moreInfo,
        this.files,
        this.userId,
        this.animalStatus,
        this.verificationStatus,
        this.longitude,
        this.latitude,
        this.userName,
        this.zipCode,
        this.mobile,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Animal.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
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
    isPregnant = json['isPregnant'];
    pregnantTime = json['pregnantTime'];
    animalHasBaby = json['animalHasBaby'];
    moreInfo = json['moreInfo'];
    if (json['files'] != null) {
      files = new List<Files>();
      json['files'].forEach((v) {
        files.add(new Files.fromJson(v));
      });
    }
    userId = json['userId'];
    animalStatus = json['animalStatus'];
    verificationStatus = json['verificationStatus'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    userName = json['userName'];
    zipCode = json['zipCode'];
    mobile = json['mobile'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
    data['animalBayat'] = this.animalBayat;
    data['animalMilk'] = this.animalMilk;
    data['animalMilkCapacity'] = this.animalMilkCapacity;
    data['animalPrice'] = this.animalPrice;
    data['isRecentBayat'] = this.isRecentBayat;
    data['recentBayatTime'] = this.recentBayatTime;
    data['isPregnant'] = this.isPregnant;
    data['pregnantTime'] = this.pregnantTime;
    data['animalHasBaby'] = this.animalHasBaby;
    data['moreInfo'] = this.moreInfo;
    if (this.files != null) {
      data['files'] = this.files.map((v) => v.toJson()).toList();
    }
    data['userId'] = this.userId;
    data['animalStatus'] = this.animalStatus;
    data['verificationStatus'] = this.verificationStatus;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['userName'] = this.userName;
    data['zipCode'] = this.zipCode;
    data['mobile'] = this.mobile;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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