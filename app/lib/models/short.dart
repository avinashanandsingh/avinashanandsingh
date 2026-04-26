class ShortData {
  String? id;
  String title;
  String thumbnail;
  String url;
  int? likes = 0;
  int? hits = 0;
  ShortData({
    this.id,
    required this.title,
    required this.thumbnail,
    required this.url,
    this.likes,
    this.hits,
  });

  factory ShortData.fromJson(Map<String, dynamic> json) {
    return ShortData(
      id: json['id'] as String?,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String,
      url: json['url'] as String,
      likes: int.parse(json['likes']),
      hits: int.parse(json['hits']),
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'url': url,
      'likes': likes,
      'hits': hits,
    };
  }
}
