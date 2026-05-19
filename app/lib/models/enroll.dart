class EnrollData {
  String? courseId;
  String? scheduleId;
  String? enrolledat;
  String? expiredat;
  String? status;
  dynamic qna;
  EnrollData({
    this.courseId,
    this.scheduleId,
    this.enrolledat,
    this.expiredat,
    this.status,
    this.qna,
  });

  factory EnrollData.fromJson(Map<String, dynamic> json) {
    return EnrollData(
      courseId: json['first_name'] as String?,
      scheduleId: json['last_name'] as String?,
      enrolledat: json['email'] as String?,
      expiredat: json['phone'] as String?,
      qna: json['qna'],
      status: json['status'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      'courseid': courseId,
      'scheduleid': scheduleId,
      'enrolledat': enrolledat,
      'expiredat': expiredat,
      'status': status,
      'qna': qna,
    };
  }
}
