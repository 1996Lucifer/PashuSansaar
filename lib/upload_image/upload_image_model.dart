class UploadImageModel {
  bool success;
  List<Urls> urls;

  UploadImageModel({this.success, this.urls});

  UploadImageModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['urls'] != null) {
      urls = <Urls>[];
      json['urls'].forEach((v) {
        urls.add(new Urls.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.urls != null) {
      data['urls'] = this.urls.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Urls {
  List<VideoUrls> videoUrls;
  String url;
  Fields fields;

  Urls({this.videoUrls, this.url, this.fields});

  Urls.fromJson(Map<String, dynamic> json) {
    if (json['videoUrls'] != null) {
      videoUrls = <VideoUrls>[];
      json['videoUrls'].forEach((v) {
        videoUrls.add(new VideoUrls.fromJson(v));
      });
    }
    url = json['url'];
    fields =
        json['fields'] != null ? new Fields.fromJson(json['fields']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.videoUrls != null) {
      data['videoUrls'] = this.videoUrls.map((v) => v.toJson()).toList();
    }
    data['url'] = this.url;
    if (this.fields != null) {
      data['fields'] = this.fields.toJson();
    }
    return data;
  }
}

class VideoUrls {
  String url;
  Fields fields;

  VideoUrls({this.url, this.fields});

  VideoUrls.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    fields =
        json['fields'] != null ? new Fields.fromJson(json['fields']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    if (this.fields != null) {
      data['fields'] = this.fields.toJson();
    }
    return data;
  }
}

class Fields {
  String key;
  String bucket;
  String xAmzAlgorithm;
  String xAmzCredential;
  String xAmzDate;
  String policy;
  String xAmzSignature;

  Fields(
      {this.key,
      this.bucket,
      this.xAmzAlgorithm,
      this.xAmzCredential,
      this.xAmzDate,
      this.policy,
      this.xAmzSignature});

  Fields.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    bucket = json['bucket'];
    xAmzAlgorithm = json['X-Amz-Algorithm'];
    xAmzCredential = json['X-Amz-Credential'];
    xAmzDate = json['X-Amz-Date'];
    policy = json['Policy'];
    xAmzSignature = json['X-Amz-Signature'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['bucket'] = this.bucket;
    data['X-Amz-Algorithm'] = this.xAmzAlgorithm;
    data['X-Amz-Credential'] = this.xAmzCredential;
    data['X-Amz-Date'] = this.xAmzDate;
    data['Policy'] = this.policy;
    data['X-Amz-Signature'] = this.xAmzSignature;
    return data;
  }
}
