class RefreshTokenModel {
  bool success;
  String accessToken;
  String refreshToken;
  int expires;

  RefreshTokenModel(
      {this.success, this.accessToken, this.refreshToken, this.expires});

  RefreshTokenModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    expires = json['expires'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['expires'] = this.expires;
    return data;
  }
}
