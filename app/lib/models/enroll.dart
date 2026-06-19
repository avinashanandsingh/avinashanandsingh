import 'package:app/models/course.dart';
import 'package:app/models/schedule.dart';

class EnrollData {
  String? id;
  String? courseId;
  CourseBasicData? course;
  String? scheduleId;
  ScheduleData? schedule;
  String? enrolledat;
  String? expiredat;
  String? status;
  dynamic qna;
  EnrollData({
    this.id,
    this.courseId,
    this.course,
    this.scheduleId,
    this.schedule,
    this.enrolledat,
    this.expiredat,
    this.status,
    this.qna,
  });

  factory EnrollData.fromJson(Map<String, dynamic> json) {
    ScheduleData? scheduleData;
    if (json['schedule'] != null) {
      scheduleData = ScheduleData.fromJson(json['schedule']);
    }
    return EnrollData(
      id: json['id'] as String?,
      courseId: json['first_name'] as String?,
      course: CourseBasicData.fromJson(json['course']),
      scheduleId: json['last_name'] as String?,
      schedule: scheduleData,
      enrolledat: json['enrolledat'] as String?,
      expiredat: json['expiredat'] as String?,
      qna: json['qna'],
      status: json['status'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'courseid': courseId,
      'scheduleid': scheduleId,
      'enrolledat': enrolledat,
      'expiredat': expiredat,
      'status': status,
      'qna': qna,
    };
  }
}
