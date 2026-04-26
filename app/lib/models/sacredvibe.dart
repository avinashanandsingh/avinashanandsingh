class SacredvibeData {
  String? id;
  String title;
  String url;
  String duration;
  SacredvibeData({
    this.id,
    required this.title,
    required this.url,
    required this.duration,
  });

  factory SacredvibeData.fromJson(Map<String, dynamic> json) {
    return SacredvibeData(
      id: json['id'] as String?,
      title: json['title'] as String,
      url: json['url'] as String,
      duration: json['duration'] as String,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'url': url, 'duration': duration};
  }
}
