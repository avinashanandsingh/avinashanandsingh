class CourseData {
  String? id;
  String? title;
  String? description;
  String? duration;
  int? validity;
  String? thumbnail;
  String? url;
  bool? certified;
  bool? short;
  String? level;
  bool? free;
  String? currency;
  double? price;
  double? offer;
  String? status;
  int? reviews;
  double? rating;
  CourseData({
    this.id,
    this.title,
    this.description,
    this.duration,
    this.validity,
    this.thumbnail,
    this.url,
    this.level,
    this.certified,
    this.free,
    this.currency,
    this.price,
    this.offer,
    this.reviews,
    this.rating,
  });

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return CourseData(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      duration: json['duration'] as String?,
      validity: json['validity'] as int?,
      thumbnail: json['thumbnail'] as String?,
      url: json['url'] as String?,
      level: json['level'] as String?,
      certified: json['certified'] as bool?,
      free: json['free'] as bool?,
      currency: json['currency'] as String?,
      //price: double.parse(json['price']),
      //offer: double.parse(json['offer']),
      reviews: json['review']['reviews'] as int?,
      //rating: json['review']['rating'] as double?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (duration != null) 'duration': duration,
      if (validity != null) 'validity': validity,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (url != null) 'url': url,
      if (level != null) 'level': url,
      if (certified != null) 'certified': certified,
      if (free != null) 'free': free,
      if (currency != null) 'currency': currency,
      if (price != null) 'price': price,
      if (offer != null) 'offer': offer,
    };
  }
}
