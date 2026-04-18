class CourseData {
  String? id;
  String? title;
  String? description;
  String? thumbnail;
  String? url;
  bool? short;
  String? level;
  bool? free;
  String? currency;
  double? price;
  double? offer;
  String? status;
  CourseData({
    this.id,
    this.title,
    this.description,
    this.thumbnail,
    this.url,
    this.level,
    this.free,
    this.currency,
    this.price,
    this.offer,
  });

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return CourseData(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      url: json['url'] as String?,
      level: json['level'] as String?,
      free: json['free'] as bool?,
      currency: json['currency'] as String?,
      price: json['price'] as double?,
      offer: json['offer'] as double?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (url != null) 'url': url,
      if (level != null) 'level': url,
      if (free != null) 'free': free,
      if (currency != null) 'currency': currency,
      if (price != null) 'price': price,
      if (offer != null) 'offer': offer,
    };
  }
}
