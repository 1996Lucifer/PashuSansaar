class AuthTokenModel {
  bool success;
  String accessToken;
  String refreshToken;
  String userId;
  int expires;

  AuthTokenModel(
      {this.success,
      this.accessToken,
      this.refreshToken,
      this.userId,
      this.expires});

  AuthTokenModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    userId = json['userId'];
    expires = json['expires'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['userId'] = this.userId;
    data['expires'] = this.expires;
    return data;
  }
}
