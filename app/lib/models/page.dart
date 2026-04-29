class PageData {
  String? id;
  String title;
  String body;
  PageData({this.id, required this.title, required this.body});

  factory PageData.fromJson(Map<String, dynamic> json) {
    return PageData(
      id: json['id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'body': body};
  }
}
