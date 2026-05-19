class ResourceData {
  String? id;
  String title;
  String url;

  ResourceData({this.id, required this.title, required this.url});

  factory ResourceData.fromJson(Map<String, dynamic> json) {
    return ResourceData(
      id: json['id'] as String?,
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'url': url};
  }
}
