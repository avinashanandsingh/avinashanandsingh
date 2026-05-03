class SettingData {
  String? id;
  String name;
  String value;
  SettingData({this.id, required this.name, required this.value});

  factory SettingData.fromJson(Map<String, dynamic> json) {
    return SettingData(
      id: json['id'] as String?,
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'value': value};
  }
}
