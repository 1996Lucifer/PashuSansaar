class AutoComplete {
  String id;
  String displayString;
  String name;
  String recordType;
  List<String> collection;
  String slug;
  String language;
  Place place;

  AutoComplete(
      {this.id,
        this.displayString,
        this.name,
        this.recordType,
        this.collection,
        this.slug,
        this.language,
        this.place});

  AutoComplete.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayString = json['displayString'];
    name = json['name'];
    recordType = json['recordType'];
    collection = json['collection'].cast<String>();
    slug = json['slug'];
    language = json['language'];
    place = json['place'] != null ? new Place.fromJson(json['place']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['displayString'] = this.displayString;
    data['name'] = this.name;
    data['recordType'] = this.recordType;
    data['collection'] = this.collection;
    data['slug'] = this.slug;
    data['language'] = this.language;
    if (this.place != null) {
      data['place'] = this.place.toJson();
    }
    return data;
  }
}

class Place {
  String type;
  Geometry geometry;
  Properties properties;

  Place({this.type, this.geometry, this.properties});

  Place.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    geometry = json['geometry'] != null
        ? new Geometry.fromJson(json['geometry'])
        : null;
    properties = json['properties'] != null
        ? new Properties.fromJson(json['properties'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.geometry != null) {
      data['geometry'] = this.geometry.toJson();
    }
    if (this.properties != null) {
      data['properties'] = this.properties.toJson();
    }
    return data;
  }
}

class Geometry {
  List<double> coordinates;
  String type;

  Geometry({this.coordinates, this.type});

  Geometry.fromJson(Map<String, dynamic> json) {
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

class Properties {
  String countryCode;
  String city;
  String type;

  Properties({this.countryCode, this.city, this.type});

  Properties.fromJson(Map<String, dynamic> json) {
    countryCode = json['countryCode'];
    city = json['city'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['countryCode'] = this.countryCode;
    data['city'] = this.city;
    data['type'] = this.type;
    return data;
  }
}