class MeditationData {
  String? id;
  String? title;
  String? thumbnail;
  String? url;
  bool? free;
  double? price;
  double? offer;
  double get sale => (offer! > 0 && offer! <= price!) ? offer! : price!;

  MeditationData({
    this.id,
    this.title,
    this.thumbnail,
    this.url,
    this.free,
    this.price,
    this.offer,
  });

  factory MeditationData.fromJson(Map<String, dynamic> json) {
    return MeditationData(
      id: json['id'] as String?,
      title: json['title'] as String?,
      thumbnail: json['thumbnail'] as String?,
      url: json['url'] as String?,
      free: json['free'] as bool?,
      price: double.parse(json['price']),
      offer: double.parse(json['offer']),
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'url': url,
      'free': free,
      'price': price,
      'offer': offer,
    };
  }
}
