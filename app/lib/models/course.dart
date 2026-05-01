class CourseData {
  String? id;
  String? title;
  String? description;
  String? about;
  String? duration;
  int? validity;
  String? thumbnail;
  String? url;
  bool? certified;
  bool? short;
  String? level;
  bool? free;
  String? currency;
  double? price = 0.0;
  double? offer = 0.0;
  String? status;
  int? reviews;
  double? rating;
  dynamic modules;
  CourseData({
    this.id,
    this.title,
    this.description,
    this.about,
    this.duration,
    this.validity,
    this.thumbnail,
    this.url,
    this.level,
    this.certified,
    this.short,
    this.free,
    this.currency,
    this.price,
    this.offer,
    this.reviews,
    this.rating,
    this.modules,
  });

  factory CourseData.fromJson(Map<String, dynamic> json) {
    return CourseData(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      about: json['about'] as String?,
      duration: json['duration'] as String?,
      validity: json['validity'] as int?,
      thumbnail: json['thumbnail'] as String?,
      url: json['url'] as String?,
      level: json['level'] as String?,
      short: json['short'] as bool?,
      certified: json['certified'] as bool?,
      free: json['free'] as bool?,
      currency: json['currency'] as String?,
      price: double.parse(json['price']),
      offer: double.parse(json['offer']),
      reviews: json['review']['reviews'],
      rating: double.parse(json['review']['rating']),
      modules: json['modules'],
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (about != null) 'about': about,
      if (duration != null) 'duration': duration,
      if (validity != null) 'validity': validity,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (url != null) 'url': url,
      if (level != null) 'level': url,
      if (certified != null) 'certified': certified,
      if (short != null) 'short': short,
      if (free != null) 'free': free,
      if (currency != null) 'currency': currency,
      if (price != null) 'price': price,
      if (offer != null) 'offer': offer,
    };
  }
}
