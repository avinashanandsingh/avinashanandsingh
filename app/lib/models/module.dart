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
  bool? completed;
  DateTime? completedAt;
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
    this.completed,
    this.completedAt,
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
      completed: json['completed'] as bool?,
      completedAt: json['completedat'] != null
          ? DateTime.parse(json['completedat'])
          : null,
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
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completedat': completedAt,
      if (status != null) 'status': status,
    };
  }
}
