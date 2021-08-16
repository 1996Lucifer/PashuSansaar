class MyAnimalModel {
  bool success;
  List<MyAnimals> myAnimals;
  int page;

  MyAnimalModel({this.success, this.myAnimals, this.page});

  MyAnimalModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['myAnimals'] != null) {
      myAnimals = <MyAnimals>[];
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
  List<VideoFiles> videoFiles;
  String userId;
  int animalStatus;
  String verificationStatus;
  double longitude;
  double latitude;
  String userName;
  String district;
  int zipCode;
  String userAddress;
  int mobile;
  String createdAt;
  String updatedAt;
  int iV;

  MyAnimals(
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
      this.videoFiles,
      this.userId,
      this.animalStatus,
      this.verificationStatus,
      this.longitude,
      this.latitude,
      this.userName,
      this.district,
      this.zipCode,
      this.userAddress,
      this.mobile,
      this.createdAt,
      this.updatedAt,
      this.iV});

  MyAnimals.fromJson(Map<String, dynamic> json) {
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
    moreInfo = json['moreInfo'];
    if (json['files'] != null) {
      files = <Files>[];
      json['files'].forEach((v) {
        files.add(new Files.fromJson(v));
      });
    }
    if (json['videoFiles'] != null) {
      videoFiles = <VideoFiles>[];
      json['videoFiles'].forEach((v) {
        videoFiles.add(new VideoFiles.fromJson(v));
      });
    }
    userId = json['userId'];
    animalStatus = json['animalStatus'];
    verificationStatus = json['verificationStatus'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    userName = json['userName'];
    district = json['district'];
    zipCode = json['zipCode'];
    userAddress = json['userAddress'];
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
    if (this.videoFiles != null) {
      data['videoFiles'] = this.videoFiles.map((v) => v.toJson()).toList();
    }
    data['userId'] = this.userId;
    data['animalStatus'] = this.animalStatus;
    data['verificationStatus'] = this.verificationStatus;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['userName'] = this.userName;
    data['district'] = this.district;
    data['zipCode'] = this.zipCode;
    data['userAddress'] = this.userAddress;
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
class VideoFiles {
  String fileName;
  String fileType;

  VideoFiles({this.fileName, this.fileType});

  VideoFiles.fromJson(Map<String, dynamic> json) {
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