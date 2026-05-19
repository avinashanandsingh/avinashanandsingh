class ShortData {
  String? id;
  String title;
  String? description;
  String url;
  int likes;
  int dislikes;
  int hits;
  ShortData({
    this.id,
    required this.title,
    this.description,
    required this.url,
    this.likes = 0,
    this.dislikes = 0,
    this.hits = 0,
  });

  factory ShortData.fromJson(Map<String, dynamic> json) {
    print(json);
    return ShortData(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      hits: json['hits'] ?? 0,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'likes': likes,
      'dislikes': dislikes,
      'hits': hits,
    };
  }
}
