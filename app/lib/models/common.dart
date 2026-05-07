class EnumData {
  String? name;
  String? value;
  EnumData({this.name, this.value});

  factory EnumData.fromJson(Map<String, dynamic> json) {
    return EnumData(
      name: json['name'] as String?,
      value: json['value'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'name': name, 'value': value};
  }
}
