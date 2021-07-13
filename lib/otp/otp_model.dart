class OtpModel {
  bool success;
  String authorizationToken;
  String name;
  int zipCode;

  OtpModel({this.success, this.authorizationToken, this.name, this.zipCode});

  OtpModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    authorizationToken = json['authorizationToken'];
    name = json['name'];
    zipCode = json['zipCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['authorizationToken'] = this.authorizationToken;
    data['name'] = this.name;
    data['zipCode'] = this.zipCode;
    return data;
  }
}