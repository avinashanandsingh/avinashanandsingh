class InquiryData {
  String? subject;
  String? message;
  InquiryData({this.subject, this.message});

  factory InquiryData.fromJson(Map<String, dynamic> json) {
    return InquiryData(
      subject: json['subject'] as String?,
      message: json['message'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {'subject': subject, 'message': message};
  }
}
