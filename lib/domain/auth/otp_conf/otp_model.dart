
class OtpModel {
  OtpModel({
    this.success,
    this.authorizationToken,
  });

  bool success;
  String authorizationToken;

  factory OtpModel.fromJson(Map<String, dynamic> json) => OtpModel(
    success: json["success"],
    authorizationToken: json["authorizationToken"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "authorizationToken": authorizationToken,
  };
}