class CountryData {
  int? id;
  String? name;

  CountryData({this.id, this.name});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(id: json['id'] as int?, name: json['name'] as String?);
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class StateData {
  int? id;
  String? name;

  StateData({this.id, this.name});

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(id: json['id'] as int?, name: json['name'] as String?);
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class CityData {
  int? id;
  String? name;

  CityData({this.id, this.name});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(id: json['id'] as int?, name: json['name'] as String?);
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
