class CountryData {
  String? id;
  String? name;

  CountryData({this.id, this.name});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class StateData {
  String? id;
  String? name;

  StateData({this.id, this.name});

  factory StateData.fromJson(Map<String, dynamic> json) {
    return StateData(id: json['id'] as String?, name: json['name'] as String?);
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class CityData {
  String? id;
  String? name;

  CityData({this.id, this.name});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(id: json['id'] as String?, name: json['name'] as String?);
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
