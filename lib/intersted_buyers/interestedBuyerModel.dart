class InterestedBuyerModel {
  bool success;
  List<InterestedBuyers> interestedBuyers;
  int page;

  InterestedBuyerModel({this.success, this.interestedBuyers, this.page});

  InterestedBuyerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['interestedBuyers'] != null) {
      interestedBuyers = new List<InterestedBuyers>();
      json['interestedBuyers'].forEach((v) {
        interestedBuyers.add(new InterestedBuyers.fromJson(v));
      });
    }
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.interestedBuyers != null) {
      data['interestedBuyers'] =
          this.interestedBuyers.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    return data;
  }
}

class InterestedBuyers {
  UserId userId;

  InterestedBuyers({this.userId});

  InterestedBuyers.fromJson(Map<String, dynamic> json) {
    userId =
    json['userId'] != null ? new UserId.fromJson(json['userId']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userId != null) {
      data['userId'] = this.userId.toJson();
    }
    return data;
  }
}

class UserId {
  String sId;
  int mobile;
  String name;
  double longitude;
  double latitude;
  String userAddress;

  UserId(
      {this.sId,
        this.mobile,
        this.name,
        this.longitude,
        this.latitude,
        this.userAddress});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mobile = json['mobile'];
    name = json['name'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    userAddress = json['userAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['mobile'] = this.mobile;
    data['name'] = this.name;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['userAddress'] = this.userAddress;
    return data;
  }
}