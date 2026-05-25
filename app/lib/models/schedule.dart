class ScheduleData {
  String? id;
  String? title;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  ScheduleData({
    this.id,
    this.title,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      id: json['id'] as String?,
      title: json['title'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  @override
  String toString() {
    return title!;
  }
}
