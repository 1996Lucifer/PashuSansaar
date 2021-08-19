class MyCallsModel {
  bool success;
  List<MyCalls> myCalls;
  int page;

  MyCallsModel({this.success, this.myCalls, this.page});

  MyCallsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['myCalls'] != null) {
      myCalls = <MyCalls>[];
      json['myCalls'].forEach((v) {
        myCalls.add(new MyCalls.fromJson(v));
      });
    }
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.myCalls != null) {
      data['myCalls'] = this.myCalls.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    return data;
  }
}

class MyCalls {
  AnimalId animalId;
  String updatedAt;

  MyCalls({this.animalId, this.updatedAt});

  MyCalls.fromJson(Map<String, dynamic> json) {
    animalId = json['animalId'] != null
        ? new AnimalId.fromJson(json['animalId'])
        : null;
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.animalId != null) {
      data['animalId'] = this.animalId.toJson();
    }
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class AnimalId {
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
  String moreInfo;
  List<Files> files;
  List<VideoFiles> videoFiles;
  double longitude;
  double latitude;
  String userAddress;
  String userName;
  int mobile;
  int animalHasBaby;

  AnimalId(
      {this.sId,
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
      this.moreInfo,
      this.files,
      this.videoFiles,
      this.longitude,
      this.latitude,
      this.userAddress,
      this.userName,
      this.mobile,
      this.animalHasBaby});

  AnimalId.fromJson(Map<String, dynamic> json) {
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
    longitude = json['longitude'];
    latitude = json['latitude'];
    userAddress = json['userAddress'];
    userName = json['userName'];
    mobile = json['mobile'];
    animalHasBaby = json['animalHasBaby'];
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
    data['isPregnant'] = this.isPregnant;
    data['pregnantTime'] = this.pregnantTime;
    data['moreInfo'] = this.moreInfo;
    if (this.files != null) {
      data['files'] = this.files.map((v) => v.toJson()).toList();
    }
    if (this.videoFiles != null) {
      data['videoFiles'] = this.videoFiles.map((v) => v.toJson()).toList();
    }
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['userAddress'] = this.userAddress;
    data['userName'] = this.userName;
    data['mobile'] = this.mobile;
    data['animalHasBaby'] = this.animalHasBaby;
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
