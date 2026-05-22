import 'package:app/models/course.dart';
import 'package:app/models/schedule.dart';

class EnrollData {
  String? courseId;
  CourseBasicData? course;
  String? scheduleId;
  ScheduleData? schedule;
  String? enrolledat;
  String? expiredat;
  String? status;
  dynamic qna;
  EnrollData({
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
    return EnrollData(
      courseId: json['first_name'] as String?,
      course: CourseBasicData.fromJson(json['course']),
      scheduleId: json['last_name'] as String?,
      schedule: ScheduleData.fromJson(json['schedule']),
      enrolledat: json['enrolledat'] as String?,
      expiredat: json['expiredat'] as String?,
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
