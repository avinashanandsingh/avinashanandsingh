class BrandingData {
  String? id;
  dynamic type;
  String title;
  String? content;
  String? url;
  BrandingData({
    this.id,
    required this.type,
    required this.title,
    this.content,
    this.url,
  });

  factory BrandingData.fromJson(Map<String, dynamic> json) {
    return BrandingData(
      id: json['id'] as String?,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      url: json['url'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'url': url,
    };
  }
}
