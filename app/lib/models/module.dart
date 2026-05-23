import 'package:app/models/course.dart';
import 'package:app/models/schedule.dart';

class ModuleData {
  int? serial;
  String? id;
  String? courseId;
  CourseData? course;
  String? scheduleId;
  ScheduleData? schedule;
  String? title;
  String? duration;
  String? url;
  String? status;

  ModuleData({
    this.serial,
    this.id,
    this.courseId,
    this.course,
    this.scheduleId,
    this.schedule,
    this.title,
    this.duration,
    this.url,
    this.status,
  });

  factory ModuleData.fromJson(Map<String, dynamic> json) {
    return ModuleData(
      id: json['id'] as String?,
      courseId: json['courseid'] as String?,
      //course: CourseData.fromJson(json['course']),
      scheduleId: json['scheduleid'] as String?,
      //schedule: ScheduleData.fromJson(json['schedule']),
      title: json['title'] as String?,
      duration: json['duration'] as String?,
      url: json['url'] as String?,
      status: json['status'] as String?,
    );
  }

  // Object to JSON conversion
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (courseId != null) 'courseid': courseId,
      if (scheduleId != null) 'scheduleid': scheduleId,
      if (title != null) 'title': title,
      if (duration != null) 'duration': duration,
      if (url != null) 'url': url,
      if (status != null) 'status': status,
    };
  }
}
